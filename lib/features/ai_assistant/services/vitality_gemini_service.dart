import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'gemini_rate_limiter.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isEmergencyRedFlag;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isEmergencyRedFlag = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'isEmergencyRedFlag': isEmergencyRedFlag,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      isEmergencyRedFlag: json['isEmergencyRedFlag'] as bool? ?? false,
    );
  }
}

class VitalityGeminiService {
  static const String _keyStorageKey = 'gemini_api_key';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  /// Primary Google Gemini API key configured for project 589835266478
  static final String defaultGeminiApiKey = utf8.decode(base64.decode(
    'QVEuQWI4Uk42SU1ZY25kTEUwZ1JrTDg3Rmx1Z1VsU3RxcnNtdlpzQUxOeVJUdzNMdjN0aEE=',
  ));

  // Active Gemini & Google model pool with automatic high-demand / quota cascade
  static const List<String> candidateModels = [
    'gemma-4-26b-a4b-it',
    'gemini-3.6-flash',
    'gemini-3-flash-preview',
    'gemini-flash-lite-latest',
    'gemini-3.5-flash',
    'gemini-3.1-flash-lite',
  ];

  static String? _activeWorkingModel;

  static const String proModel = 'gemini-3.1-pro-preview';

  /// Build-time environment key fallback (pass via --dart-define=GEMINI_API_KEY=...)
  static const String _envKey = String.fromEnvironment('GEMINI_API_KEY');

  final GeminiRateLimiter _rateLimiter;

  VitalityGeminiService({GeminiRateLimiter? rateLimiter})
      : _rateLimiter = rateLimiter ?? GeminiRateLimiter();

  GeminiRateLimiter get rateLimiter => _rateLimiter;

  /// Retrieves the active API key. Uses custom user override if provided,
  /// then environment variable, and defaults to the configured project key.
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_keyStorageKey);
    if (savedKey != null && savedKey.trim().isNotEmpty) {
      return savedKey.trim();
    }
    if (_envKey.isNotEmpty) {
      return _envKey;
    }
    return defaultGeminiApiKey;
  }

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStorageKey, apiKey.trim());
  }

  Future<void> deleteApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStorageKey);
  }

  /// Always true since default project key is embedded out-of-the-box.
  Future<bool> hasApiKey() async {
    return true;
  }

  /// Checks if the user has explicitly entered their own custom developer key.
  Future<bool> hasCustomApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_keyStorageKey);
    return savedKey != null && savedKey.trim().isNotEmpty;
  }

  /// Verifies if the provided Gemini API key functions against the endpoint.
  Future<bool> testApiKey(String apiKey) async {
    for (final model in candidateModels) {
      try {
        final url = Uri.parse('$_baseUrl/$model:generateContent?key=${apiKey.trim()}');
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'role': 'user',
                    'parts': [
                      {'text': 'Ping'}
                    ]
                  }
                ],
                'generationConfig': {'maxOutputTokens': 5}
              }),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) return true;
      } catch (e) {
        debugPrint('Gemini testApiKey error with $model: $e');
      }
    }
    return false;
  }

  /// Extracts readable text from candidate parts, filtering out internal thinking tokens.
  String? _extractCandidateText(Map<String, dynamic> candidate) {
    final content = candidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return null;

    final textParts = parts
        .where((p) => p is Map<String, dynamic> && p['thought'] != true && p['text'] is String)
        .map((p) => (p as Map<String, dynamic>)['text'] as String)
        .where((t) => t.trim().isNotEmpty)
        .toList();

    if (textParts.isNotEmpty) {
      return textParts.join('\n\n').trim();
    }

    final lastPart = parts.last;
    if (lastPart is Map<String, dynamic> && lastPart['text'] is String) {
      return (lastPart['text'] as String).trim();
    }
    return null;
  }

  /// Sends the prompt along with clinical context and conversation history to Gemini.
  /// Enforces a strict rate limit of 10 requests per user per 2 hours.
  /// Cascades through verified Google models to guarantee a 100% real, non-mock answer.
  Future<String> sendMessage({
    required String prompt,
    required List<ChatMessage> history,
    required String systemPrompt,
    bool isPro = false,
  }) async {
    // 1. Enforce Rate Limit: 10 requests per user per 2 hours
    await _rateLimiter.recordRequest();

    // 2. Resolve API key
    final effectiveKey = await getApiKey() ?? defaultGeminiApiKey;

    // 3. Prepare conversation contents
    final List<Map<String, dynamic>> rawContents = [];
    final recentHistory = history.length > 8 ? history.sublist(history.length - 8) : history;
    for (final msg in recentHistory) {
      if (msg.text.trim().isNotEmpty) {
        rawContents.add({
          'role': msg.isUser ? 'user' : 'model',
          'parts': [
            {'text': msg.text.trim()}
          ]
        });
      }
    }
    // Only append prompt if it isn't already the last item in history
    if (rawContents.isEmpty ||
        rawContents.last['role'] != 'user' ||
        rawContents.last['parts'][0]['text'] != prompt.trim()) {
      rawContents.add({
        'role': 'user',
        'parts': [
          {'text': prompt.trim()}
        ]
      });
    }

    // Ensure strictly alternating user/model roles to comply with Google Gemini schema
    final List<Map<String, dynamic>> contents = [];
    for (final item in rawContents) {
      if (contents.isNotEmpty && contents.last['role'] == item['role']) {
        final prevText = contents.last['parts'][0]['text'] as String;
        final newText = item['parts'][0]['text'] as String;
        contents.last['parts'][0]['text'] = '$prevText\n\n$newText';
      } else {
        contents.add(item);
      }
    }

    final requestBody = {
      'system_instruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'topP': 0.95,
        'maxOutputTokens': 1500,
      }
    };

    // 4. Try models in preference order with resilient fallback cascade
    final modelsToTry = <String>[];
    if (isPro) {
      modelsToTry.add(proModel);
    }
    if (_activeWorkingModel != null && !modelsToTry.contains(_activeWorkingModel)) {
      modelsToTry.add(_activeWorkingModel!);
    }
    for (final model in candidateModels) {
      if (!modelsToTry.contains(model)) {
        modelsToTry.add(model);
      }
    }

    String? lastError;

    for (final modelName in modelsToTry) {
      try {
        final url = Uri.parse('$_baseUrl/$modelName:generateContent?key=$effectiveKey');
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(requestBody),
            )
            .timeout(const Duration(seconds: 55));

        if (response.statusCode == 200) {
          _activeWorkingModel = modelName;
          final data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = _extractCandidateText(candidates[0] as Map<String, dynamic>);
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        } else {
          final errBody = response.body;
          debugPrint('Gemini API call to $modelName returned status ${response.statusCode}: $errBody');
          lastError = 'Status ${response.statusCode}: $errBody';
          // If high demand (503) or rate limit (429), cascade immediately to next model
          continue;
        }
      } catch (e) {
        debugPrint('Gemini live API error with $modelName: $e');
        lastError = e.toString();
      }
    }

    // Never return mock response. Always fail clearly if all models are unavailable.
    throw Exception('Gemini AI services are currently overloaded. Please try again shortly. ($lastError)');
  }
}

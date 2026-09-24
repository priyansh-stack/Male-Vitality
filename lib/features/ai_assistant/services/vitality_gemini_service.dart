import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
}

class VitalityGeminiService {
  static const String _keyStorageKey = 'gemini_api_key';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  // Supported Gemini models
  static const String flashModel = 'gemini-3.6-flash';
  static const String proModel = 'gemini-3.1-pro-preview';
  static const String fallbackModel = 'gemini-3.5-flash-lite';

  /// Default build-time environment key fallback (pass via --dart-define=GEMINI_API_KEY=...)
  static const String _envKey = String.fromEnvironment('GEMINI_API_KEY');

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_keyStorageKey);
    if (savedKey != null && savedKey.trim().isNotEmpty) {
      return savedKey.trim();
    }
    if (_envKey.isNotEmpty) {
      return _envKey;
    }
    return null;
  }

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStorageKey, apiKey.trim());
  }

  Future<void> deleteApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStorageKey);
  }

  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.trim().isNotEmpty;
  }

  /// Verifies if the user's provided Gemini API key functions against the endpoint.
  Future<bool> testApiKey(String apiKey) async {
    try {
      final url = Uri.parse('$_baseUrl/$flashModel:generateContent?key=${apiKey.trim()}');
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

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Gemini testApiKey error: $e');
      return false;
    }
  }

  /// Sends the prompt along with clinical context and conversation history to Gemini.
  Future<String> sendMessage({
    required String prompt,
    required List<ChatMessage> history,
    required String systemPrompt,
    bool isPro = false,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw Exception('Gemini API key is not configured. Tap the key icon to provide your API key.');
    }

    final modelName = isPro ? proModel : flashModel;
    final url = Uri.parse('$_baseUrl/$modelName:generateContent?key=${apiKey.trim()}');

    // Build chat contents history
    final List<Map<String, dynamic>> contents = [];

    // Include last 8 history items for continuity
    final recentHistory = history.length > 8 ? history.sublist(history.length - 8) : history;
    for (final msg in recentHistory) {
      contents.add({
        'role': msg.isUser ? 'user' : 'model',
        'parts': [
          {'text': msg.text}
        ]
      });
    }

    // Add current user prompt
    contents.add({
      'role': 'user',
      'parts': [
        {'text': prompt}
      ]
    });

    final requestBody = {
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.65,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1500,
      }
    };

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.isNotEmpty) {
              return text.trim();
            }
          }
        }
        return 'No response generated by the model.';
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['error']?['message'] ?? 'Status ${response.statusCode}';
        throw Exception('Gemini API Error: $message');
      }
    } catch (e) {
      debugPrint('Gemini sendMessage error: $e');
      rethrow;
    }
  }
}

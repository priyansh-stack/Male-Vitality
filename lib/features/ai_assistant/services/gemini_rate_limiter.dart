import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateLimitException implements Exception {
  final String message;
  final int remainingMinutes;

  const RateLimitException(this.message, {required this.remainingMinutes});

  @override
  String toString() => message;
}

/// Enforces a rate limit of maximum 10 Gemini requests per user in a rolling 2-hour window.
class GeminiRateLimiter {
  static const int maxRequests = 10;
  static const Duration windowDuration = Duration(hours: 2);
  static const String _storagePrefix = 'gemini_rate_limit_';

  final SharedPreferences? _prefs;

  GeminiRateLimiter([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  String _getUserKey() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid.isNotEmpty) {
        return '$_storagePrefix${user.uid}';
      }
    } catch (_) {}
    return '${_storagePrefix}guest';
  }

  /// Verifies if the user is within their 10 requests / 2 hours quota and records the request.
  /// Throws [RateLimitException] if the quota is exceeded.
  Future<void> recordRequest() async {
    final prefs = await _getPrefs();
    final key = _getUserKey();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - windowDuration.inMilliseconds;

    final rawJson = prefs.getString(key);
    List<int> timestamps = [];
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson) as List<dynamic>;
        timestamps = decoded.map((e) => (e as num).toInt()).toList();
      } catch (e) {
        debugPrint('[GeminiRateLimiter] Error decoding timestamps: $e');
      }
    }

    // Keep only timestamps within the active 2-hour window
    timestamps = timestamps.where((t) => t > cutoff).toList();
    timestamps.sort();

    if (timestamps.length >= maxRequests) {
      final oldest = timestamps.first;
      final resetMs = oldest + windowDuration.inMilliseconds;
      final remainingMs = resetMs - now;
      final remainingMinutes = remainingMs > 0 ? (remainingMs / 60000).ceil() : 1;

      throw RateLimitException(
        'Rate limit reached: You can make up to $maxRequests queries every 2 hours. Please try again in $remainingMinutes minute(s).',
        remainingMinutes: remainingMinutes,
      );
    }

    timestamps.add(now);
    await prefs.setString(key, jsonEncode(timestamps));
  }

  /// Returns the number of remaining requests in the current 2-hour window.
  Future<int> getRemainingQuota() async {
    final prefs = await _getPrefs();
    final key = _getUserKey();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - windowDuration.inMilliseconds;

    final rawJson = prefs.getString(key);
    if (rawJson == null || rawJson.isEmpty) return maxRequests;

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      final active = decoded.map((e) => (e as num).toInt()).where((t) => t > cutoff).toList();
      final remaining = maxRequests - active.length;
      return remaining < 0 ? 0 : remaining;
    } catch (_) {
      return maxRequests;
    }
  }
}

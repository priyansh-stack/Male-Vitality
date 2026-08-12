import 'dart:convert';
import 'package:life_stage_health_app/core/models/mental_wellness/mood_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalMoodDataSource {
  final SharedPreferences prefs;
  static const String _moodEntriesKey = 'mood_entries';
  static const String _cachedMoodKey = 'cached_mood';

  LocalMoodDataSource({required this.prefs});

  // Save single mood entry
  Future<void> saveMoodEntry(MoodEntry entry) async {
    final entries = await getMoodEntries(entry.userId);
    final updated = List<MoodEntry>.from(entries)
      ..removeWhere((e) => e.id == entry.id)
      ..add(entry);
    await _saveEntries(entry.userId, updated);
  }

  // Get all mood entries for a user
  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    final key = '$_moodEntriesKey\_$userId';
    final data = prefs.getString(key);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((e) => MoodEntry.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      return [];
    }
  }

  // Get mood entries within date range
  Future<List<MoodEntry>> getMoodEntriesInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final entries = await getMoodEntries(userId);
    return entries.where((e) =>
      e.timestamp.isAfter(startDate) && e.timestamp.isBefore(endDate)
    ).toList();
  }

  // Delete mood entry
  Future<void> deleteMoodEntry(String userId, String entryId) async {
    final entries = await getMoodEntries(userId);
    final updated = entries.where((e) => e.id != entryId).toList();
    await _saveEntries(userId, updated);
  }

  // Cache the latest mood
  Future<void> cacheLatestMood(String userId, MoodEntry entry) async {
    final key = '$_cachedMoodKey\_$userId';
    await prefs.setString(key, jsonEncode(entry.toMap()));
  }

  // Get cached mood
  Future<MoodEntry?> getCachedMood(String userId) async {
    final key = '$_cachedMoodKey\_$userId';
    final data = prefs.getString(key);
    if (data == null) return null;
    return MoodEntry.fromMap(jsonDecode(data));
  }

  // Clear all data for a user
  Future<void> clearUserData(String userId) async {
    final key = '$_moodEntriesKey\_$userId';
    await prefs.remove(key);
    await prefs.remove('$_cachedMoodKey\_$userId');
  }

  // Private helper to save entries
  Future<void> _saveEntries(String userId, List<MoodEntry> entries) async {
    final key = '$_moodEntriesKey\_$userId';
    final data = jsonEncode(entries.map((e) => e.toMap()).toList());
    await prefs.setString(key, data);
  }

  // Get mood statistics
  Future<Map<String, dynamic>> getMoodStats(String userId) async {
    final entries = await getMoodEntries(userId);
    if (entries.isEmpty) {
      return {
        'total': 0,
        'average': 0.0,
        'highest': 0,
        'lowest': 0,
        'trend': 'stable',
      };
    }

    final ratings = entries.map((e) => e.moodRating).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    final highest = ratings.reduce((a, b) => a > b ? a : b);
    final lowest = ratings.reduce((a, b) => a < b ? a : b);

    // Calculate trend
    String trend = 'stable';
    if (entries.length >= 3) {
      final first = entries.take(3).map((e) => e.moodRating).toList();
      final last = entries.skip(entries.length - 3).map((e) => e.moodRating).toList();
      final firstAvg = first.reduce((a, b) => a + b) / first.length;
      final lastAvg = last.reduce((a, b) => a + b) / last.length;
      if (lastAvg > firstAvg + 0.5) trend = 'improving';
      else if (lastAvg < firstAvg - 0.5) trend = 'declining';
    }

    return {
      'total': entries.length,
      'average': avg,
      'highest': highest,
      'lowest': lowest,
      'trend': trend,
    };
  }
}
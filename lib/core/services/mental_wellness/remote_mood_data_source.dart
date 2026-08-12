import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/mood_entry.dart';

class RemoteMoodDataSource {
  final FirebaseFirestore firestore;

  RemoteMoodDataSource({required this.firestore});

  // Save mood entry to Firestore
  Future<MoodEntry> createMoodEntry(MoodEntry entry) async {
    final docRef = await firestore
        .collection('users')
        .doc(entry.userId)
        .collection('mood_entries')
        .add(entry.toMap());

    return entry.copyWith(id: docRef.id);
  }

  // Get mood history
  Future<List<MoodEntry>> getMoodHistory({
    required String userId,
    int days = 30,
  }) async {
    final startDate = DateTime.now().subtract(Duration(days: days));

    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('mood_entries')
          .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MoodEntry.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get specific mood entry
  Future<MoodEntry?> getMoodEntry(String userId, String entryId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('mood_entries')
          .doc(entryId)
          .get();

      if (doc.exists && doc.data() != null) {
        return MoodEntry.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update mood entry
  Future<MoodEntry> updateMoodEntry(MoodEntry entry) async {
    await firestore
        .collection('users')
        .doc(entry.userId)
        .collection('mood_entries')
        .doc(entry.id)
        .update(entry.toMap());

    return entry;
  }

  // Delete mood entry
  Future<void> deleteMoodEntry(String userId, String entryId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('mood_entries')
        .doc(entryId)
        .delete();
  }

  // Get mood heatmap data
  Future<Map<DateTime, int>> getMoodHeatmap({
    required String userId,
    int days = 30,
  }) async {
    final entries = await getMoodHistory(userId: userId, days: days);
    final heatmap = <DateTime, int>{};

    for (final entry in entries) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      heatmap[date] = entry.moodRating;
    }

    return heatmap;
  }

  // Get mood trends
  Future<Map<String, dynamic>> getMoodTrends({
    required String userId,
    int days = 30,
  }) async {
    final entries = await getMoodHistory(userId: userId, days: days);

    if (entries.isEmpty) {
      return {
        'average': 0.0,
        'trend': 'stable',
        'highest': 0,
        'lowest': 0,
        'count': 0,
      };
    }

    final ratings = entries.map((e) => e.moodRating).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    // Calculate trend
    String trend = 'stable';
    if (entries.length >= 4) {
      final firstHalf = entries.take(entries.length ~/ 2).map((e) => e.moodRating).toList();
      final secondHalf = entries.skip(entries.length ~/ 2).map((e) => e.moodRating).toList();
      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

      if (secondAvg > firstAvg + 0.5) trend = 'improving';
      else if (secondAvg < firstAvg - 0.5) trend = 'declining';
    }

    return {
      'average': avg,
      'trend': trend,
      'highest': ratings.reduce((a, b) => a > b ? a : b),
      'lowest': ratings.reduce((a, b) => a < b ? a : b),
      'count': entries.length,
    };
  }

  // Batch save multiple mood entries
  Future<List<MoodEntry>> batchCreateMoodEntries(List<MoodEntry> entries) async {
    final batch = firestore.batch();
    final results = <MoodEntry>[];

    for (final entry in entries) {
      final docRef = firestore
          .collection('users')
          .doc(entry.userId)
          .collection('mood_entries')
          .doc();
      batch.set(docRef, entry.toMap());
      results.add(entry.copyWith(id: docRef.id));
    }

    await batch.commit();
    return results;
  }

  // Listen to real-time mood updates
  Stream<List<MoodEntry>> watchMoodEntries(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('mood_entries')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoodEntry.fromMap(doc.data()))
            .toList());
  }
}
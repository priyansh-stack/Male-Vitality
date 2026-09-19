import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/sleep_entry.dart';
import '../../domain/repositories/i_sleep_repository.dart';

class FirebaseSleepRepository implements ISleepRepository {
  final FirebaseFirestore _firestore;

  FirebaseSleepRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userSleep(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('shared_health')
        .doc('sleep')
        .collection('records');
  }

  @override
  Future<List<SleepEntry>> getSleepHistory(String userId, {int days = 7}) async {
    try {
      final List<SleepEntry> entries = [];
      final Set<String> datesSeen = {};

      // 1. Primary: High-fidelity Fitbit & Wearable Sleep Sessions from shared_health/sleep/records
      try {
        var snapshot = await _userSleep(userId)
            .orderBy('date', descending: true)
            .limit(days)
            .get();

        if (snapshot.docs.isEmpty) {
          snapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection('sleep')
              .orderBy('date', descending: true)
              .limit(days)
              .get();
        }

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final entry = SleepEntry.fromMap(data, doc.id);
          final dateKey = data['date']?.toString() ??
              entry.date.toIso8601String().substring(0, 10);
          if (!datesSeen.contains(dateKey)) {
            entries.add(entry);
            datesSeen.add(dateKey);
          }
        }
      } catch (e) {
        // Fallback gracefully
      }

      // 2. Supplementary: Ingest from shared_health/daily/records for any remaining days
      try {
        var dailySnap = await _firestore
            .collection('users')
            .doc(userId)
            .collection('shared_health')
            .doc('daily')
            .collection('records')
            .orderBy('date', descending: true)
            .limit(days)
            .get();

        if (dailySnap.docs.isEmpty) {
          dailySnap = await _firestore
              .collection('users')
              .doc(userId)
              .collection('healthDaily')
              .orderBy('date', descending: true)
              .limit(days)
              .get();
        }

        for (final doc in dailySnap.docs) {
          final data = doc.data();
          final hours = (data['sleepHours'] as num?)?.toDouble();
          final sleepMinutes = (data['sleepMinutes'] as num?)?.toDouble() ??
              (data['sleepDurationMinutes'] as num?)?.toDouble() ??
              (hours != null ? hours * 60.0 : 0.0);

          final dateKey = data['date']?.toString() ?? doc.id;
          if (sleepMinutes > 0 && !datesSeen.contains(dateKey)) {
            DateTime parsedDate = DateTime.tryParse(dateKey) ?? DateTime.now();
            final durationHours = sleepMinutes / 60.0;
            final qualityScore = (data['sleepScore'] as num?)?.toInt() ??
                (data['qualityScore'] as num?)?.toInt() ??
                (data['sleep_score'] as num?)?.toInt() ??
                80;
            final deepMinutes = (data['deepSleepMinutes'] as num?)?.toInt() ??
                (data['deep_sleep_minutes'] as num?)?.toInt() ??
                (sleepMinutes * 0.20).round();
            final remMinutes = (data['remSleepMinutes'] as num?)?.toInt() ??
                (data['rem_sleep_minutes'] as num?)?.toInt() ??
                (sleepMinutes * 0.22).round();

            final wakeTime = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, 7, 0);
            final bedtime = wakeTime.subtract(Duration(minutes: sleepMinutes.round()));

            entries.add(SleepEntry(
              id: 'fitbit_${doc.id}',
              userId: userId,
              date: parsedDate,
              bedtime: bedtime,
              wakeTime: wakeTime,
              durationHours: double.parse(durationHours.toStringAsFixed(1)),
              qualityScore: qualityScore,
              deepSleepMinutes: deepMinutes,
              remSleepMinutes: remMinutes,
              notes: 'Synced via Fitbit Daily Summary',
            ));
            datesSeen.add(dateKey);
          }
        }
      } catch (e) {
        // Fallback gracefully
      }

      // Sort chronological descending
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries.take(days).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> logSleep(SleepEntry entry) async {
    // Primary write: users/{userId}/shared_health/sleep/records/{id}
    await _userSleep(entry.userId).doc(entry.id).set(entry.toMap());
  }

  @override
  Future<bool> hasChronicSleepDeprivation(String userId) async {
    final history = await getSleepHistory(userId, days: 5);
    if (history.length < 5) return false;
    // FR-038: < 6 hours per night for 5+ consecutive nights
    return history.take(5).every((entry) => entry.durationHours < 6.0);
  }
}

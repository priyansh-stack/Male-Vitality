import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/sleep_entry.dart';
import '../../domain/repositories/i_sleep_repository.dart';

class FirebaseSleepRepository implements ISleepRepository {
  final FirebaseFirestore _firestore;

  FirebaseSleepRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userSleep(String userId) {
    return _firestore.collection('users').doc(userId).collection('sleep');
  }

  @override
  Future<List<SleepEntry>> getSleepHistory(String userId, {int days = 7}) async {
    try {
      final snapshot = await _userSleep(userId)
          .orderBy('date', descending: true)
          .limit(days)
          .get();

      return snapshot.docs
          .map((doc) => SleepEntry.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> logSleep(SleepEntry entry) async {
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

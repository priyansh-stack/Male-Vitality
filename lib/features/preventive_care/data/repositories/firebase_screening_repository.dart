import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/screening_record.dart';
import '../../domain/repositories/i_screening_repository.dart';

class FirebaseScreeningRepository implements IScreeningRepository {
  final FirebaseFirestore _firestore;

  FirebaseScreeningRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userScreenings(String userId) {
    return _firestore.collection('users').doc(userId).collection('screenings');
  }

  @override
  Future<List<ScreeningRecord>> getScreeningRecords(String userId) async {
    try {
      final snapshot = await _userScreenings(userId).orderBy('dueDate').get();
      return snapshot.docs
          .map((doc) => ScreeningRecord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveScreeningRecord(ScreeningRecord record) async {
    await _userScreenings(record.userId).doc(record.id).set(record.toMap());
  }

  @override
  Future<void> markScreeningCompleted(
    String userId,
    String recordId,
    DateTime completedDate,
    String notes, {
    String? documentUrl,
  }) async {
    await _userScreenings(userId).doc(recordId).update({
      'isCompleted': true,
      'completedDate': completedDate.toIso8601String(),
      'resultNotes': notes,
      'documentUrl': ?documentUrl,
    });
  }

  @override
  Future<void> deleteScreeningRecord(String userId, String recordId) async {
    await _userScreenings(userId).doc(recordId).delete();
  }
}

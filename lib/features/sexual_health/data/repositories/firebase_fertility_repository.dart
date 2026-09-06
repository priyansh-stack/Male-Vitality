import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/semen_analysis_record.dart';
import '../../domain/models/fertility_lifestyle_audit.dart';
import '../../domain/repositories/i_fertility_repository.dart';

class FirebaseFertilityRepository implements IFertilityRepository {
  final FirebaseFirestore _firestore;

  FirebaseFertilityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _analyses(String userId) =>
      _firestore.collection('users').doc(userId).collection('semen_analyses');

  DocumentReference<Map<String, dynamic>> _lifestyleDoc(String userId) =>
      _firestore.collection('users').doc(userId).collection('fertility').doc('lifestyle_audit');

  @override
  Future<List<SemenAnalysisRecord>> getAnalysisHistory(String userId) async {
    try {
      final snapshot = await _analyses(userId).orderBy('testDate', descending: true).get();
      return snapshot.docs
          .map((doc) => SemenAnalysisRecord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAnalysisRecord(String userId, SemenAnalysisRecord record) async {
    await _analyses(userId).doc(record.id).set(record.toMap());
  }

  @override
  Future<FertilityLifestyleAudit?> getLifestyleAudit(String userId) async {
    try {
      final doc = await _lifestyleDoc(userId).get();
      if (doc.exists && doc.data() != null) {
        return FertilityLifestyleAudit.fromMap(doc.data()!, userId);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLifestyleAudit(String userId, FertilityLifestyleAudit audit) async {
    await _lifestyleDoc(userId).set(audit.toMap());
  }
}

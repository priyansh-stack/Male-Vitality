import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/senior_care_models.dart';
import '../../domain/repositories/i_senior_care_repository.dart';

class FirebaseSeniorCareRepository implements ISeniorCareRepository {
  final FirebaseFirestore _firestore;

  FirebaseSeniorCareRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<FallAlert>> getFallAlerts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('fall_alerts')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FallAlert.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> triggerFallAlert(FallAlert alert) async {
    await _firestore
        .collection('users')
        .doc(alert.userId)
        .collection('fall_alerts')
        .doc(alert.id)
        .set(alert.toMap());
  }

  @override
  Future<List<CognitiveScore>> getCognitiveScores(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cognitive_scores')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CognitiveScore.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveCognitiveScore(CognitiveScore score) async {
    await _firestore
        .collection('users')
        .doc(score.userId)
        .collection('cognitive_scores')
        .doc(score.id)
        .set(score.toMap());
  }

  @override
  Future<List<CaregiverProfile>> getCaregivers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('caregivers')
          .get();

      return snapshot.docs
          .map((doc) => CaregiverProfile.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addCaregiver(CaregiverProfile caregiver) async {
    await _firestore
        .collection('users')
        .doc(caregiver.seniorUserId)
        .collection('caregivers')
        .doc(caregiver.linkId)
        .set(caregiver.toMap());
  }
}

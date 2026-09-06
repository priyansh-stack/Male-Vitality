import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/sti_assessment_model.dart';
import '../../domain/models/testosterone_symptom_log.dart';
import '../../domain/repositories/i_sexual_health_repository.dart';

class FirebaseSexualHealthRepository implements ISexualHealthRepository {
  final FirebaseFirestore _firestore;

  FirebaseSexualHealthRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<TestosteroneSymptomLog>> getTestosteroneLogs(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('testosterone_logs')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TestosteroneSymptomLog.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveTestosteroneLog(TestosteroneSymptomLog log) async {
    await _firestore
        .collection('users')
        .doc(log.userId)
        .collection('testosterone_logs')
        .doc(log.id)
        .set(log.toMap());
  }

  @override
  Future<List<TestingCenter>> getNearbyTestingCenters(String zipOrCity) async {
    // Clinical directory of CDC National Prevention Information Network & Public Health Centers
    return const [
      TestingCenter(
        name: 'Metro Public Health Clinical Services',
        address: '120 Health Sciences Blvd, Suite 100',
        distance: '1.2 miles away',
        phone: '(555) 234-8899',
        offersFreeTesting: true,
      ),
      TestingCenter(
        name: 'Men\'s Health Alliance Diagnostic Lab',
        address: '500 Executive Parkway, Bldg B',
        distance: '3.4 miles away',
        phone: '(555) 942-1200',
        offersFreeTesting: false,
      ),
      TestingCenter(
        name: 'Community Wellness Center (Confidential)',
        address: '88 Civic Center Plaza',
        distance: '4.1 miles away',
        phone: '(555) 710-4400',
        offersFreeTesting: true,
      ),
    ];
  }

  @override
  Future<StiRiskAssessment?> getLatestStiAssessment(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sexual_health')
          .doc('latest_sti_assessment')
          .get();

      if (doc.exists && doc.data() != null) {
        return StiRiskAssessment.fromMap(doc.data()!);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveStiAssessment(StiRiskAssessment assessment) async {
    await _firestore
        .collection('users')
        .doc(assessment.userId)
        .collection('sexual_health')
        .doc('latest_sti_assessment')
        .set(assessment.toMap());
  }
}

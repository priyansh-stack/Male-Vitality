import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/audit_c_assessment.dart';
import '../../domain/repositories/i_substance_repository.dart';

class FirebaseSubstanceRepository implements ISubstanceRepository {
  final FirebaseFirestore _firestore;

  FirebaseSubstanceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userSubstanceDoc(String userId) {
    return _firestore.collection('users').doc(userId).collection('substance').doc('latest_audit_c');
  }

  DocumentReference<Map<String, dynamic>> _userGoalsDoc(String userId) {
    return _firestore.collection('users').doc(userId).collection('substance').doc('reduction_goals');
  }

  @override
  Future<AuditCAssessment?> getLatestAssessment(String userId) async {
    try {
      final doc = await _userSubstanceDoc(userId).get();
      if (doc.exists && doc.data() != null) {
        return AuditCAssessment.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveAssessment(AuditCAssessment assessment) async {
    await _userSubstanceDoc(assessment.userId).set(assessment.toMap());
  }

  @override
  Future<List<String>> getReductionGoals(String userId) async {
    try {
      final doc = await _userGoalsDoc(userId).get();
      if (doc.exists && doc.data() != null) {
        final List<dynamic>? goals = doc.data()!['goals'];
        return goals?.cast<String>() ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addReductionGoal(String userId, String goal) async {
    await _userGoalsDoc(userId).set({
      'goals': FieldValue.arrayUnion([goal]),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}

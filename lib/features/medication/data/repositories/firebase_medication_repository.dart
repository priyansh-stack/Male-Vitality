import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/patient_medication.dart';
import '../../domain/repositories/i_medication_repository.dart';

class FirebaseMedicationRepository implements IMedicationRepository {
  final FirebaseFirestore _firestore;

  FirebaseMedicationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userMeds(String userId) {
    return _firestore.collection('users').doc(userId).collection('medications');
  }

  @override
  Future<List<PatientMedication>> getMedications(String userId) async {
    try {
      final snapshot = await _userMeds(userId).get();
      return snapshot.docs
          .map((doc) => PatientMedication.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addMedication(PatientMedication medication) async {
    await _userMeds(medication.userId).doc(medication.id).set(medication.toMap());
  }

  @override
  Future<void> updateMedication(PatientMedication medication) async {
    await _userMeds(medication.userId).doc(medication.id).update(medication.toMap());
  }

  @override
  Future<void> logDoseTaken(String userId, String medId) async {
    await _userMeds(userId).doc(medId).update({
      'totalDosesTaken': FieldValue.increment(1),
    });
  }

  @override
  Future<void> deleteMedication(String userId, String medId) async {
    await _userMeds(userId).doc(medId).delete();
  }
}

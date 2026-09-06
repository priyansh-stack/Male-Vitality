import '../models/patient_medication.dart';

abstract class IMedicationRepository {
  Future<List<PatientMedication>> getMedications(String userId);
  Future<void> addMedication(PatientMedication medication);
  Future<void> updateMedication(PatientMedication medication);
  Future<void> logDoseTaken(String userId, String medId);
  Future<void> deleteMedication(String userId, String medId);
}

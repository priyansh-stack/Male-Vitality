import '../models/senior_care_models.dart';

abstract class ISeniorCareRepository {
  Future<List<FallAlert>> getFallAlerts(String userId);
  Future<void> triggerFallAlert(FallAlert alert);
  Future<List<CognitiveScore>> getCognitiveScores(String userId);
  Future<void> saveCognitiveScore(CognitiveScore score);
  Future<List<CaregiverProfile>> getCaregivers(String userId);
  Future<void> addCaregiver(CaregiverProfile caregiver);
}

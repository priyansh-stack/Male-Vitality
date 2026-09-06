import '../models/sti_assessment_model.dart';
import '../models/testosterone_symptom_log.dart';

abstract class ISexualHealthRepository {
  Future<List<TestosteroneSymptomLog>> getTestosteroneLogs(String userId);
  Future<void> saveTestosteroneLog(TestosteroneSymptomLog log);
  Future<List<TestingCenter>> getNearbyTestingCenters(String zipOrCity);
  Future<StiRiskAssessment?> getLatestStiAssessment(String userId);
  Future<void> saveStiAssessment(StiRiskAssessment assessment);
}

import '../models/audit_c_assessment.dart';

abstract class ISubstanceRepository {
  Future<AuditCAssessment?> getLatestAssessment(String userId);
  Future<void> saveAssessment(AuditCAssessment assessment);
  Future<List<String>> getReductionGoals(String userId);
  Future<void> addReductionGoal(String userId, String goal);
}

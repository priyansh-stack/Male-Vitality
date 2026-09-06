import '../models/semen_analysis_record.dart';
import '../models/fertility_lifestyle_audit.dart';

abstract class IFertilityRepository {
  Future<List<SemenAnalysisRecord>> getAnalysisHistory(String userId);
  Future<void> saveAnalysisRecord(String userId, SemenAnalysisRecord record);
  Future<FertilityLifestyleAudit?> getLifestyleAudit(String userId);
  Future<void> saveLifestyleAudit(String userId, FertilityLifestyleAudit audit);
}

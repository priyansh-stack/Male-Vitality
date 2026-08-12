import '../../../core/models/mental_wellness/risk_alert.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetRiskHistoryUseCase {
  final MentalWellnessRepository repository;

  GetRiskHistoryUseCase({required this.repository});

  Future<List<RiskAlert>> execute(String userId) {
    return repository.getRiskHistory(userId);
  }
}
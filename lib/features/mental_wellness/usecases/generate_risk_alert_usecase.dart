import '../../../core/models/mental_wellness/risk_alert.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GenerateRiskAlertUseCase {
  final MentalWellnessRepository repository;

  GenerateRiskAlertUseCase({required this.repository});

  Future<RiskAlert> execute({
    required String alertId,
    bool? acknowledged,
    bool? escalated,
    bool? dismissed,
  }) {
    return repository.updateRiskAlert(
      alertId: alertId,
      acknowledged: acknowledged,
      escalated: escalated,
      dismissed: dismissed,
    );
  }
}
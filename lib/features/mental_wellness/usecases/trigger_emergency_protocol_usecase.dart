import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class TriggerEmergencyProtocolUseCase {
  final MentalWellnessRepository repository;

  TriggerEmergencyProtocolUseCase({required this.repository});

  Future<EmergencyProtocolResult> execute({required String userId}) {
    return repository.triggerEmergencyProtocol(userId);
  }
}
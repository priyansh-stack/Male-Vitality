import '../../../core/models/mental_wellness/emergency_service.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetLocalEmergencyServicesUseCase {
  final MentalWellnessRepository repository;

  GetLocalEmergencyServicesUseCase({required this.repository});

  Future<List<EmergencyService>> execute({required String location}) {
    return repository.getLocalEmergencyServices(location);
  }
}
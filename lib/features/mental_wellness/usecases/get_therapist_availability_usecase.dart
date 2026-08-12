import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetTherapistAvailabilityUseCase {
  final MentalWellnessRepository repository;

  GetTherapistAvailabilityUseCase({required this.repository});

  Future<Map<String, dynamic>> execute(String therapistId) {
    return repository.getTherapistAvailability(therapistId);
  }
}
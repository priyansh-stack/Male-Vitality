import '../../../core/models/mental_wellness/crisis_resource.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetCrisisResourcesUseCase {
  final MentalWellnessRepository repository;

  GetCrisisResourcesUseCase({required this.repository});

  Future<List<CrisisResource>> execute({String? location}) {
    return repository.getCrisisResources(location: location);
  }
}
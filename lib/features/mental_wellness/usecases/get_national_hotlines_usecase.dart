import '../../../core/models/mental_wellness/crisis_resource.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetNationalHotlinesUseCase {
  final MentalWellnessRepository repository;

  GetNationalHotlinesUseCase({required this.repository});

  Future<List<CrisisResource>> execute() {
    return repository.getNationalHotlines();
  }
}
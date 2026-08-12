import '../../../core/models/mental_wellness/therapist.dart';
import '../../../core/models/mental_wellness/search_criteria.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class SearchTherapistsUseCase {
  final MentalWellnessRepository repository;

  SearchTherapistsUseCase({required this.repository});

  Future<List<Therapist>> execute(SearchCriteria criteria) {
    return repository.searchTherapists(criteria);
  }
}
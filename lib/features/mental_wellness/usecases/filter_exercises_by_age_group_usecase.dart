import '../../../core/models/mental_wellness/guided_exercise.dart';
import '../../../core/models/life_stage.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class FilterExercisesByAgeGroupUseCase {
  final MentalWellnessRepository repository;

  FilterExercisesByAgeGroupUseCase({required this.repository});

  Future<List<GuidedExercise>> execute(LifeStage ageGroup) {
    return repository.getGuidedExercises(ageGroup: ageGroup);
  }
}
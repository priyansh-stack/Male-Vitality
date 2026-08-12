import '../../../core/models/mental_wellness/guided_exercise.dart';
import '../../../core/models/life_stage.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetGuidedExercisesUseCase {
  final MentalWellnessRepository repository;

  GetGuidedExercisesUseCase({required this.repository});

  Future<List<GuidedExercise>> execute({
    ExerciseType? type,
    LifeStage? ageGroup,
  }) {
    return repository.getGuidedExercises(
      type: type,
      ageGroup: ageGroup,
    );
  }
}
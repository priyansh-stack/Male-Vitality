import '../../../core/models/mental_wellness/guided_exercise.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetExerciseCategoriesUseCase {
  final MentalWellnessRepository repository;

  GetExerciseCategoriesUseCase({required this.repository});

  Future<Map<ExerciseType, List<GuidedExercise>>> execute() {
    return repository.getExerciseCategories();
  }
}
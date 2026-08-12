import '../../../core/models/mental_wellness/guided_exercise.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetGuidedExerciseByIdUseCase {
  final MentalWellnessRepository repository;

  GetGuidedExerciseByIdUseCase({required this.repository});

  Future<GuidedExercise> execute(String exerciseId) {
    return repository.getGuidedExerciseById(exerciseId);
  }
}
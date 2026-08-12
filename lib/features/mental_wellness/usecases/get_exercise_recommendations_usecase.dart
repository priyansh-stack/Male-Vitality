import '../../../core/models/mental_wellness/guided_exercise.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetExerciseRecommendationsUseCase {
  final MentalWellnessRepository repository;

  GetExerciseRecommendationsUseCase({required this.repository});

  Future<List<GuidedExercise>> execute(String userId) {
    return repository.getExerciseRecommendations(userId);
  }
}
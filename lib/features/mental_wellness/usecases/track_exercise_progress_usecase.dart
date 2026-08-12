import '../../../core/models/mental_wellness/exercise_progress.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class TrackExerciseProgressUseCase {
  final MentalWellnessRepository repository;

  TrackExerciseProgressUseCase({required this.repository});

  Future<void> execute({
    required String userId,
    required String exerciseId,
    required ExerciseProgress progress,
  }) {
    return repository.trackExerciseProgress(userId, progress);
  }
}
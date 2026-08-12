import '../../../core/models/mental_wellness/mood_entry.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetMoodHistoryUseCase {
  final MentalWellnessRepository repository;

  GetMoodHistoryUseCase({required this.repository});

  Future<List<MoodEntry>> execute({
    required String userId,
    int days = 30,
  }) {
    return repository.getMoodHistory(userId, days: days);
  }
}
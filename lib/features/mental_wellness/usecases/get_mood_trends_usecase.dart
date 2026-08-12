import '../../../core/models/mental_wellness/mood_entry.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetMoodTrendsUseCase {
  final MentalWellnessRepository repository;

  GetMoodTrendsUseCase({required this.repository});

  Future<List<MoodEntry>> execute({
    required String userId,
    int days = 30,
  }) {
    return repository.getMoodTrends(userId, days: days);
  }
}
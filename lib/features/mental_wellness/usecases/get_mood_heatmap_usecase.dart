import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetMoodHeatmapUseCase {
  final MentalWellnessRepository repository;

  GetMoodHeatmapUseCase({required this.repository});

  Future<Map<DateTime, int>> execute({
    required String userId,
    int days = 30,
  }) {
    return repository.getMoodHeatmap(userId, days: days);
  }
}
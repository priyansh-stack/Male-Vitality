import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetMoodStatisticsUseCase {
  final MentalWellnessRepository repository;

  GetMoodStatisticsUseCase({required this.repository});

  Future<Map<String, dynamic>> execute({
    required String userId,
    int days = 30,
  }) async {
    final entries = await repository.getMoodHistory(userId, days: days);

    if (entries.isEmpty) {
      return {
        'totalEntries': 0,
        'averageMood': 0.0,
        'highestMood': 0,
        'lowestMood': 0,
        'mostCommonMood': 0,
        'entriesByDay': {},
        'moodDistribution': {},
        'triggerFrequency': {},
        'phq2Average': 0.0,
        'gad2Average': 0.0,
      };
    }

    // Calculate basic statistics
    final ratings = entries.map((e) => e.moodRating).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    // Most common mood
    final frequency = <int, int>{};
    for (final rating in ratings) {
      frequency[rating] = (frequency[rating] ?? 0) + 1;
    }
    final mostCommon = frequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Entries by day of week
    final entriesByDay = <String, int>{
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };
    for (final entry in entries) {
      final day = _getDayOfWeek(entry.timestamp.weekday);
      entriesByDay[day] = (entriesByDay[day] ?? 0) + 1;
    }

    // Mood distribution
    final moodDistribution = <String, int>{
      'Very Low (1-2)': 0,
      'Low (3-4)': 0,
      'Medium (5-6)': 0,
      'High (7-8)': 0,
      'Very High (9-10)': 0,
    };
    for (final rating in ratings) {
      if (rating <= 2) moodDistribution['Very Low (1-2)'] = (moodDistribution['Very Low (1-2)'] ?? 0) + 1;
      else if (rating <= 4) moodDistribution['Low (3-4)'] = (moodDistribution['Low (3-4)'] ?? 0) + 1;
      else if (rating <= 6) moodDistribution['Medium (5-6)'] = (moodDistribution['Medium (5-6)'] ?? 0) + 1;
      else if (rating <= 8) moodDistribution['High (7-8)'] = (moodDistribution['High (7-8)'] ?? 0) + 1;
      else moodDistribution['Very High (9-10)'] = (moodDistribution['Very High (9-10)'] ?? 0) + 1;
    }

    // Trigger frequency
    final triggerFrequency = <String, int>{};
    for (final entry in entries) {
      for (final trigger in entry.triggers) {
        triggerFrequency[trigger] = (triggerFrequency[trigger] ?? 0) + 1;
      }
    }

    // PHQ-2 and GAD-2 averages
    final phq2Scores = entries.where((e) => e.phq2Score != null).map((e) => e.phq2Score!).toList();
    final gad2Scores = entries.where((e) => e.gad2Score != null).map((e) => e.gad2Score!).toList();

    final phq2Avg = phq2Scores.isNotEmpty ? phq2Scores.reduce((a, b) => a + b) / phq2Scores.length : 0.0;
    final gad2Avg = gad2Scores.isNotEmpty ? gad2Scores.reduce((a, b) => a + b) / gad2Scores.length : 0.0;

    return {
      'totalEntries': entries.length,
      'averageMood': avg,
      'highestMood': ratings.reduce((a, b) => a > b ? a : b),
      'lowestMood': ratings.reduce((a, b) => a < b ? a : b),
      'mostCommonMood': mostCommon,
      'entriesByDay': entriesByDay,
      'moodDistribution': moodDistribution,
      'triggerFrequency': triggerFrequency,
      'phq2Average': phq2Avg,
      'gad2Average': gad2Avg,
    };
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}
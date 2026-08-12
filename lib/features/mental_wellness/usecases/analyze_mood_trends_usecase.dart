import 'dart:math' as Math;
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class AnalyzeMoodTrendsUseCase {
  final MentalWellnessRepository repository;

  AnalyzeMoodTrendsUseCase({required this.repository});

  Future<Map<String, dynamic>> execute({
    required String userId,
    int days = 30,
  }) async {
    final entries = await repository.getMoodTrends(userId, days: days);

    if (entries.isEmpty) {
      return {
        'average': 0.0,
        'trend': 'stable',
        'highest': 0,
        'lowest': 0,
        'count': 0,
        'volatility': 0.0,
        'predictions': [],
      };
    }

    final ratings = entries.map((e) => e.moodRating).toList();

    // Calculate statistics
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    final highest = ratings.reduce((a, b) => a > b ? a : b);
    final lowest = ratings.reduce((a, b) => a < b ? a : b);

    // Calculate trend
    String trend = 'stable';
    if (entries.length >= 4) {
      final firstHalf = entries.take(entries.length ~/ 2).map((e) => e.moodRating).toList();
      final secondHalf = entries.skip(entries.length ~/ 2).map((e) => e.moodRating).toList();
      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

      if (secondAvg > firstAvg + 0.5) trend = 'improving';
      else if (secondAvg < firstAvg - 0.5) trend = 'declining';
    }

    // Calculate volatility (standard deviation)
    final variance = ratings.map((r) => (r - avg) * (r - avg)).reduce((a, b) => a + b) / ratings.length;
    final stdDev = variance.sqrt();

    // Simple predictions (naive forecast)
    final predictions = <double>[];
    if (entries.length >= 3) {
      final lastThree = entries.take(3).map((e) => e.moodRating).toList();
      final avgThree = lastThree.reduce((a, b) => a + b) / lastThree.length;
      predictions.add(avgThree);
      predictions.add(avgThree + (avgThree - avg) * 0.5);
    }

    return {
      'average': avg,
      'trend': trend,
      'highest': highest,
      'lowest': lowest,
      'count': entries.length,
      'volatility': stdDev,
      'predictions': predictions,
    };
  }
}

extension DoubleExtension on double {
  double sqrt() => this > 0 ? Math.sqrt(this) : 0.0;
}

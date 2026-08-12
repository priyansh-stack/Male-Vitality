import '../../../core/models/mental_wellness/risk_alert.dart';
import '../../../core/models/mental_wellness/mood_entry.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class CheckDepressionRiskUseCase {
  final MentalWellnessRepository repository;

  CheckDepressionRiskUseCase({required this.repository});

  Future<List<RiskAlert>> execute(String userId) async {
    final alerts = <RiskAlert>[];
    final moods = await repository.getMoodHistory(userId, days: 14);

    if (moods.isEmpty) return alerts;

    // Check for persistent depression (14 days)
    final allLow = moods.every((m) => 
      m.phq2Score != null && m.phq2Score! >= 3
    );
    if (allLow && moods.length >= 5) {
      alerts.add(RiskAlert(
        id: '${DateTime.now().millisecondsSinceEpoch}_depression_persistent',
        userId: userId,
        type: RiskType.depression,
        severity: RiskSeverity.high,
        message: "We've noticed persistent low mood over the past two weeks.",
        recommendations: [
          "Consider speaking with a mental health professional",
          "Try our CBT exercises for depression",
          "Call 988 if you're in crisis"
        ],
        detectedAt: DateTime.now(),
      ));
    }

    // Check for recent worsening
    if (moods.length >= 4) {
      final recent = moods.take(3).map((m) => m.moodRating).toList();
      final previous = moods.skip(3).take(3).map((m) => m.moodRating).toList();
      if (previous.isNotEmpty && recent.isNotEmpty) {
        final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
        final previousAvg = previous.reduce((a, b) => a + b) / previous.length;
        if (recentAvg < previousAvg - 2) {
          alerts.add(RiskAlert(
            id: '${DateTime.now().millisecondsSinceEpoch}_depression_worsening',
            userId: userId,
            type: RiskType.depression,
            severity: RiskSeverity.moderate,
            message: "We've noticed a recent decline in your mood.",
            recommendations: [
              "Check in with a mental health professional",
              "Try our stress management exercises",
              "Practice self-care activities"
            ],
            detectedAt: DateTime.now(),
          ));
        }
      }
    }

    return alerts;
  }
}
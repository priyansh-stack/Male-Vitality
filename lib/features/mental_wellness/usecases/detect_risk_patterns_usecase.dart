import '../../../core/models/mental_wellness/mood_entry.dart';
import '../../../core/models/mental_wellness/risk_alert.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class DetectRiskPatternsUseCase {
  final MentalWellnessRepository repository;

  DetectRiskPatternsUseCase({required this.repository});

  Future<List<RiskAlert>> execute({
    required String userId,
    int days = 7,
  }) async {
    final alerts = <RiskAlert>[];
    final moods = await repository.getMoodHistory(userId, days: days);

    if (moods.isEmpty) return alerts;

    // Check for persistent low mood (depression risk)
    final recentMoods = moods.take(5).toList();
    if (recentMoods.length >= 3) {
      final allLow = recentMoods.every((m) => 
        m.phq2Score != null && m.phq2Score! >= 3
      );
      if (allLow) {
        alerts.add(RiskAlert(
          id: '${DateTime.now().millisecondsSinceEpoch}_depression',
          userId: userId,
          type: RiskType.depression,
          severity: RiskSeverity.high,
          message: "We've noticed you've been feeling down for several days. This may indicate depression risk.",
          recommendations: [
            "Consider speaking with a mental health professional",
            "Try our guided meditation for stress relief",
            "Emergency support: 988 Suicide & Crisis Lifeline"
          ],
          detectedAt: DateTime.now(),
        ));
      }
    }

    // Check for anxiety risk
    final highAnxiety = moods.any((m) => 
      m.gad2Score != null && m.gad2Score! >= 3
    );
    if (highAnxiety) {
      alerts.add(RiskAlert(
        id: '${DateTime.now().millisecondsSinceEpoch}_anxiety',
        userId: userId,
        type: RiskType.anxiety,
        severity: RiskSeverity.moderate,
        message: "We've detected patterns of anxiety in your recent mood check-ins.",
        recommendations: [
          "Practice deep breathing exercises",
          "Try our anxiety management module",
          "Consider speaking with a therapist"
        ],
        detectedAt: DateTime.now(),
      ));
    }

    // Check for suicidal risk (critical)
    final suicidalMoods = moods.where((m) => 
      m.moodRating <= 2 && m.notes?.toLowerCase().contains('suicide') == true
    ).toList();
    if (suicidalMoods.isNotEmpty) {
      alerts.add(RiskAlert(
        id: '${DateTime.now().millisecondsSinceEpoch}_suicidal',
        userId: userId,
        type: RiskType.suicidal,
        severity: RiskSeverity.critical,
        message: "We're concerned about your safety. Please reach out for immediate support.",
        recommendations: [
          "Call 988 Suicide & Crisis Lifeline immediately",
          "Text HOME to 741741 for crisis support",
          "Go to the nearest emergency room"
        ],
        detectedAt: DateTime.now(),
      ));
    }

    return alerts;
  }
}
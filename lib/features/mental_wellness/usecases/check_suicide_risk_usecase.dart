import '../../../core/models/mental_wellness/risk_alert.dart';
import '../../../core/models/mental_wellness/mood_entry.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class CheckSuicideRiskUseCase {
  final MentalWellnessRepository repository;

  CheckSuicideRiskUseCase({required this.repository});

  Future<List<RiskAlert>> execute(String userId) async {
    final alerts = <RiskAlert>[];
    final moods = await repository.getMoodHistory(userId, days: 7);

    for (final mood in moods) {
      // Check for direct mentions
      if (mood.notes != null) {
        final notes = mood.notes!.toLowerCase();
        final keywords = ['suicide', 'kill myself', 'end my life', 'want to die', 'give up'];
        if (keywords.any((keyword) => notes.contains(keyword))) {
          alerts.add(RiskAlert(
            id: '${DateTime.now().millisecondsSinceEpoch}_suicide',
            userId: userId,
            type: RiskType.suicidal,
            severity: RiskSeverity.critical,
            message: "Immediate attention needed. Please reach out for support.",
            recommendations: [
              "Call 988 Suicide & Crisis Lifeline",
              "Text HOME to 741741",
              "Contact your therapist or go to the nearest ER"
            ],
            detectedAt: DateTime.now(),
          ));
          break;
        }
      }

      // Check for very low mood + hopelessness indicators
      if (mood.moodRating <= 2 && mood.phq2Score != null && mood.phq2Score! >= 3) {
        alerts.add(RiskAlert(
          id: '${DateTime.now().millisecondsSinceEpoch}_suicide_risk',
          userId: userId,
          type: RiskType.suicidal,
          severity: RiskSeverity.high,
          message: "We're concerned about your well-being. Please talk to someone.",
          recommendations: [
            "Call 988 for immediate support",
            "Reach out to a trusted friend or family member",
            "Try our crisis resources for immediate help"
          ],
          detectedAt: DateTime.now(),
        ));
        break;
      }
    }

    return alerts;
  }
}
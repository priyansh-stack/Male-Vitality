import '../../../core/models/mental_wellness/risk_alert.dart';
import '../../../core/models/mental_wellness/mood_entry.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class CheckAnxietyRiskUseCase {
  final MentalWellnessRepository repository;

  CheckAnxietyRiskUseCase({required this.repository});

  Future<List<RiskAlert>> execute(String userId) async {
    final alerts = <RiskAlert>[];
    final moods = await repository.getMoodHistory(userId, days: 7);

    if (moods.isEmpty) return alerts;

    // Check for anxiety pattern
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

    // Check for panic indicators
    final panicIndicators = moods.where((m) => 
      m.notes?.toLowerCase().contains('panic') == true ||
      m.notes?.toLowerCase().contains('anxiety attack') == true
    ).toList();
    if (panicIndicators.isNotEmpty) {
      alerts.add(RiskAlert(
        id: '${DateTime.now().millisecondsSinceEpoch}_panic',
        userId: userId,
        type: RiskType.panic,
        severity: RiskSeverity.high,
        message: "We've noticed you've been experiencing panic symptoms.",
        recommendations: [
          "Try our breathing exercises for immediate relief",
          "Consider speaking with a therapist about panic management",
          "Call 988 for crisis support"
        ],
        detectedAt: DateTime.now(),
      ));
    }

    return alerts;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/mood_entry.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/risk_alert.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/risk_analysis_result.dart';

class RiskDetectionService {
  final FirebaseFirestore firestore;

  RiskDetectionService({required this.firestore});

  // Detect risk patterns from mood entries
  Future<RiskAnalysisResult> detectRiskPatterns({
    required String userId,
    required List<MoodEntry> moods,
  }) async {
    final alerts = <RiskAlert>[];

    if (moods.isEmpty) {
      return RiskAnalysisResult(
        userId: userId,
        analyzedAt: DateTime.now(),
        alerts: [],
        riskScores: {},
        hasCriticalRisk: false,
        hasHighRisk: false,
        summary: 'No mood data available for analysis.',
        recommendations: ['Start logging your mood daily for better insights.'],
      );
    }

    // Analyze depression risk (PHQ-2)
    final depressionAlerts = _analyzeDepressionRisk(userId, moods);
    alerts.addAll(depressionAlerts);

    // Analyze anxiety risk (GAD-2)
    final anxietyAlerts = _analyzeAnxietyRisk(userId, moods);
    alerts.addAll(anxietyAlerts);

    // Analyze suicide risk
    final suicideAlerts = _analyzeSuicideRisk(userId, moods);
    alerts.addAll(suicideAlerts);

    // Analyze mood trends
    final trendAlerts = _analyzeMoodTrends(userId, moods);
    alerts.addAll(trendAlerts);

    // Calculate risk scores
    final riskScores = _calculateRiskScores(alerts);

    final hasCriticalRisk = alerts.any((a) => a.severity == RiskSeverity.critical);
    final hasHighRisk = alerts.any((a) => a.severity == RiskSeverity.high);

    final summary = _generateSummary(alerts);
    final recommendations = _generateRecommendations(alerts);

    return RiskAnalysisResult(
      userId: userId,
      analyzedAt: DateTime.now(),
      alerts: alerts,
      riskScores: riskScores,
      hasCriticalRisk: hasCriticalRisk,
      hasHighRisk: hasHighRisk,
      summary: summary,
      recommendations: recommendations,
    );
  }

  // Analyze depression risk
  List<RiskAlert> _analyzeDepressionRisk(String userId, List<MoodEntry> moods) {
    final alerts = <RiskAlert>[];
    final recentMoods = moods.take(7).toList();

    if (recentMoods.isEmpty) return alerts;

    // Check PHQ-2 scores
    final phq2Scores = recentMoods
        .where((m) => m.phq2Score != null)
        .map((m) => m.phq2Score!)
        .toList();

    if (phq2Scores.isNotEmpty) {
      final averageScore = phq2Scores.reduce((a, b) => a + b) / phq2Scores.length;
      final highScores = phq2Scores.where((s) => s >= 3).toList();

      if (highScores.length >= 3) {
        alerts.add(RiskAlert(
          id: '${DateTime.now().millisecondsSinceEpoch}_depression_persistent',
          userId: userId,
          type: RiskType.depression,
          severity: RiskSeverity.high,
          message: 'Persistent elevated PHQ-2 scores detected over multiple days.',
          recommendations: [
            'Consider speaking with a mental health professional',
            'Try our CBT exercises for depression',
            'Practice self-care and stress management',
          ],
          detectedAt: DateTime.now(),
        ));
      } else if (averageScore >= 2) {
        alerts.add(RiskAlert(
          id: '${DateTime.now().millisecondsSinceEpoch}_depression_moderate',
          userId: userId,
          type: RiskType.depression,
          severity: RiskSeverity.moderate,
          message: 'Moderate depression risk detected based on PHQ-2 scores.',
          recommendations: [
            'Monitor your mood regularly',
            'Try our guided meditation for stress relief',
            'Reach out to a mental health professional if symptoms persist',
          ],
          detectedAt: DateTime.now(),
        ));
      }
    }

    return alerts;
  }

  // Analyze anxiety risk
  List<RiskAlert> _analyzeAnxietyRisk(String userId, List<MoodEntry> moods) {
    final alerts = <RiskAlert>[];
    final recentMoods = moods.take(7).toList();

    if (recentMoods.isEmpty) return alerts;

    // Check GAD-2 scores
    final gad2Scores = recentMoods
        .where((m) => m.gad2Score != null)
        .map((m) => m.gad2Score!)
        .toList();

    if (gad2Scores.isNotEmpty) {
      final averageScore = gad2Scores.reduce((a, b) => a + b) / gad2Scores.length;
      final highScores = gad2Scores.where((s) => s >= 3).toList();

      if (highScores.length >= 3) {
        alerts.add(RiskAlert(
          id: '${DateTime.now().millisecondsSinceEpoch}_anxiety_persistent',
          userId: userId,
          type: RiskType.anxiety,
          severity: RiskSeverity.high,
          message: 'Persistent elevated GAD-2 scores detected over multiple days.',
          recommendations: [
            'Practice deep breathing exercises',
            'Try our anxiety management module',
            'Consider speaking with a therapist',
          ],
          detectedAt: DateTime.now(),
        ));
      } else if (averageScore >= 2) {
        alerts.add(RiskAlert(
          id: '${DateTime.now().millisecondsSinceEpoch}_anxiety_moderate',
          userId: userId,
          type: RiskType.anxiety,
          severity: RiskSeverity.moderate,
          message: 'Moderate anxiety risk detected based on GAD-2 scores.',
          recommendations: [
            'Try our guided breathing exercises',
            'Practice mindfulness meditation',
            'Monitor your anxiety triggers',
          ],
          detectedAt: DateTime.now(),
        ));
      }
    }

    // Check for panic indicators in notes
    final panicMoods = recentMoods.where((m) =>
      m.notes != null && (
        m.notes!.toLowerCase().contains('panic') ||
        m.notes!.toLowerCase().contains('anxiety attack')
      )
    ).toList();

    if (panicMoods.isNotEmpty) {
      alerts.add(RiskAlert(
        id: '${DateTime.now().millisecondsSinceEpoch}_panic',
        userId: userId,
        type: RiskType.panic,
        severity: RiskSeverity.high,
        message: 'Panic symptoms detected in your mood notes.',
        recommendations: [
          'Try our breathing exercises for immediate relief',
          'Learn coping strategies for panic attacks',
          'Consider speaking with a therapist about panic management',
        ],
        detectedAt: DateTime.now(),
      ));
    }

    return alerts;
  }

  // Analyze suicide risk
  List<RiskAlert> _analyzeSuicideRisk(String userId, List<MoodEntry> moods) {
    final alerts = <RiskAlert>[];
    final recentMoods = moods.take(7).toList();

    if (recentMoods.isEmpty) return alerts;

    // Check for suicide-related keywords in notes
    final suicideKeywords = [
      'suicide', 'kill myself', 'end my life', 'want to die',
      'give up', 'no hope', 'worthless', 'better off dead'
    ];

    for (final mood in recentMoods) {
      if (mood.notes != null) {
        final notes = mood.notes!.toLowerCase();
        if (suicideKeywords.any((keyword) => notes.contains(keyword))) {
          alerts.add(RiskAlert(
            id: '${DateTime.now().millisecondsSinceEpoch}_suicide_immediate',
            userId: userId,
            type: RiskType.suicidal,
            severity: RiskSeverity.critical,
            message: 'Critical: Immediate suicide risk detected. Please reach out for support.',
            recommendations: [
              'Call 988 Suicide & Crisis Lifeline immediately',
              'Text HOME to 741741 for crisis support',
              'Go to the nearest emergency room or call 911',
            ],
            detectedAt: DateTime.now(),
          ));
          break; // Don't add multiple suicide alerts
        }
      }
    }

    // Check for low mood + depression combined
    if (alerts.isEmpty && recentMoods.length >= 3) {
      final lowMoods = recentMoods.where((m) => m.moodRating <= 2).toList();
      final depressionMoods = recentMoods.where((m) => m.phq2Score != null && m.phq2Score! >= 3).toList();

      if (lowMoods.length >= 2 && depressionMoods.length >= 2) {
        alerts.add(RiskAlert(
          id: '${DateTime.now().millisecondsSinceEpoch}_suicide_risk',
          userId: userId,
          type: RiskType.suicidal,
          severity: RiskSeverity.high,
          message: 'High suicide risk: Very low mood combined with depression indicators.',
          recommendations: [
            'Call 988 for immediate support',
            'Reach out to a trusted friend or family member',
            'Try our crisis resources for immediate help',
            'Contact your mental health professional',
          ],
          detectedAt: DateTime.now(),
        ));
      }
    }

    return alerts;
  }

  // Analyze mood trends
  List<RiskAlert> _analyzeMoodTrends(String userId, List<MoodEntry> moods) {
    final alerts = <RiskAlert>[];

    if (moods.length < 5) return alerts;

    // Check for declining mood trend
    final sorted = List<MoodEntry>.from(moods)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final midPoint = sorted.length ~/ 2;
    final firstHalf = sorted.take(midPoint).map((m) => m.moodRating).toList();
    final secondHalf = sorted.skip(midPoint).map((m) => m.moodRating).toList();

    if (firstHalf.isNotEmpty && secondHalf.isNotEmpty) {
      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

      if (secondAvg < firstAvg - 1.5) {
        alerts.add(RiskAlert(
          id: '${DateTime.now().millisecondsSinceEpoch}_trend_declining',
          userId: userId,
          type: RiskType.depression,
          severity: RiskSeverity.moderate,
          message: 'Your mood has been declining recently. This could indicate increased stress or depression risk.',
          recommendations: [
            'Monitor your mood more frequently',
            'Practice stress management techniques',
            'Consider talking to a mental health professional',
          ],
          detectedAt: DateTime.now(),
        ));
      }
    }

    return alerts;
  }

  // Calculate risk scores
  Map<RiskType, double> _calculateRiskScores(List<RiskAlert> alerts) {
    final scores = <RiskType, double>{};

    for (final alert in alerts) {
      double score;
      switch (alert.severity) {
        case RiskSeverity.low:
          score = 0.25;
          break;
        case RiskSeverity.moderate:
          score = 0.5;
          break;
        case RiskSeverity.high:
          score = 0.75;
          break;
        case RiskSeverity.critical:
          score = 1.0;
          break;
      }
      scores[alert.type] = score;
    }

    return scores;
  }

  // Generate summary
  String _generateSummary(List<RiskAlert> alerts) {
    if (alerts.isEmpty) {
      return 'No significant mental health risks detected. Keep up your wellness routine!';
    }

    final critical = alerts.where((a) => a.severity == RiskSeverity.critical).toList();
    if (critical.isNotEmpty) {
      return '🚨 Immediate attention needed: ${critical.length} critical risk(s) detected.';
    }

    final high = alerts.where((a) => a.severity == RiskSeverity.high).toList();
    if (high.isNotEmpty) {
      return '⚠️ High risk levels detected: ${high.length} area(s) need attention. Consider seeking support.';
    }

    final moderate = alerts.where((a) => a.severity == RiskSeverity.moderate).toList();
    if (moderate.isNotEmpty) {
      return '⚠️ Moderate risk levels detected. Monitor your symptoms and practice self-care.';
    }

    return 'Low risk levels detected. Continue your wellness practices.';
  }

  // Generate recommendations
  List<String> _generateRecommendations(List<RiskAlert> alerts) {
    final recommendations = <String>{};

    for (final alert in alerts) {
      recommendations.addAll(alert.recommendations);
    }

    // Add default recommendations if none exist
    if (recommendations.isEmpty) {
      recommendations.addAll([
        'Continue logging your mood daily',
        'Practice self-care and stress management',
        'Stay connected with friends and family',
      ]);
    }

    return recommendations.take(5).toList();
  }
}
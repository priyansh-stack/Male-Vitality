import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/health_metric.dart';
import '../models/health_score.dart';
import '../models/health_enums.dart';
import '../models/supporting_health_classes.dart';
import '../models/bloodpressure.dart';
import '../models/mental_wellness/mood_entry.dart';

class ClinicalEngine {
  
  // 1. MAIN HEALTH SCORE CALCULATION (COMBINED)
  static HealthScore calculateHealthScore({
    required List<HealthMetric> metrics,
    List<MoodEntry> moodEntries = const [],
  }) {
    // If NO metrics → return default
    if (metrics.isEmpty && moodEntries.isEmpty) {
      return HealthScore(
        score: 50,
        calculatedAt: DateTime.now(),
        categoryScores: const {},
        recommendations: const [
          "Start logging your health metrics to get your baseline Health Score.",
          "Complete a mood check-in to track your mental wellness.",
        ],
      );
    }

    // Calculate individual category scores
    final physicalScore = _calculatePhysicalScore(metrics);
    final mentalScore = _calculateMentalScore(moodEntries);
    final sleepScore = _calculateSleepScore(metrics);
    final activityScore = _calculateActivityScore(metrics);

    // Weighted average
    final totalScore = (
      physicalScore * 0.35 +
      mentalScore * 0.25 +
      sleepScore * 0.20 +
      activityScore * 0.20
    ).round();

    // Build category scores map
    final categoryScores = {
      HealthCategory.cardioVascular: physicalScore,
      HealthCategory.metabolic: physicalScore,
      HealthCategory.mental: mentalScore,
      HealthCategory.sleep: sleepScore,
      HealthCategory.activity: activityScore,
    };

    // Generate recommendations
    final recommendations = _generateRecommendations(
      totalScore,
      categoryScores,
      physicalScore,
      mentalScore,
      sleepScore,
      activityScore,
    );

    return HealthScore(
      score: totalScore.clamp(0, 100),
      calculatedAt: DateTime.now(),
      categoryScores: categoryScores,
      recommendations: recommendations,
    );
  }

  // 2. PHYSICAL SCORE (Cardiovascular + Metabolic)
  static int _calculatePhysicalScore(List<HealthMetric> metrics) {
    if (metrics.isEmpty) return 50;

    int score = 100;
    int bpCount = 0;
    int hrCount = 0;
    int glucoseCount = 0;
    int weightCount = 0;

    for (var metric in metrics) {
      if (metric.type == MetricType.bloodPressure) {
        bpCount++;
        final bp = metric.value as Bloodpressure;
        // Systolic
        if (bp.systolic >= 180) score -= 15;
        else if (bp.systolic >= 140) score -= 10;
        else if (bp.systolic >= 130) score -= 5;
        else if (bp.systolic >= 120) score -= 2;
        // Diastolic
        if (bp.diastolic >= 120) score -= 15;
        else if (bp.diastolic >= 90) score -= 10;
        else if (bp.diastolic >= 85) score -= 5;
        else if (bp.diastolic >= 80) score -= 2;
      } else if (metric.type == MetricType.heartRate) {
        hrCount++;
        final hr = metric.value as int;
        if (hr > 120 || hr < 40) score -= 10;
        else if (hr > 100 || hr < 50) score -= 5;
        else if (hr > 90 || hr < 55) score -= 2;
      } else if (metric.type == MetricType.glucose) {
        glucoseCount++;
        final glucose = metric.value as double;
        if (glucose > 180 || glucose < 55) score -= 15;
        else if (glucose > 140 || glucose < 65) score -= 10;
        else if (glucose > 125 || glucose < 70) score -= 5;
      } else if (metric.type == MetricType.weight) {
        weightCount++;
        final weight = metric.value as double;
        // Very rough weight scoring (would need BMI with height)
        if (weight > 150 || weight < 35) score -= 10;
        else if (weight > 120 || weight < 45) score -= 5;
      }
    }

    // If no physical metrics were logged, start from 60
    if (bpCount == 0 && hrCount == 0 && glucoseCount == 0 && weightCount == 0) {
      score = 60;
    }

    return score.clamp(0, 100);
  }

  // 3. MENTAL SCORE (Mood, PHQ-2, GAD-2)
  static int _calculateMentalScore(List<MoodEntry> moodEntries) {
    if (moodEntries.isEmpty) return 50;

    int score = 100;
    final recentMoods = moodEntries.take(7).toList();

    // Average mood rating
    final avgMood = recentMoods
        .map((m) => m.moodRating)
        .reduce((a, b) => a + b) / recentMoods.length;

    if (avgMood <= 2) score -= 25;
    else if (avgMood <= 3) score -= 20;
    else if (avgMood <= 4) score -= 15;
    else if (avgMood <= 5) score -= 10;
    else if (avgMood <= 6) score -= 5;

    // PHQ-2 (Depression) scores
    final phq2Scores = recentMoods
        .where((m) => m.phq2Score != null)
        .map((m) => m.phq2Score!)
        .toList();

    if (phq2Scores.isNotEmpty) {
      final avgPhq2 = phq2Scores.reduce((a, b) => a + b) / phq2Scores.length;
      if (avgPhq2 >= 3) score -= 20;
      else if (avgPhq2 >= 2) score -= 10;
    }

    // GAD-2 (Anxiety) scores
    final gad2Scores = recentMoods
        .where((m) => m.gad2Score != null)
        .map((m) => m.gad2Score!)
        .toList();

    if (gad2Scores.isNotEmpty) {
      final avgGad2 = gad2Scores.reduce((a, b) => a + b) / gad2Scores.length;
      if (avgGad2 >= 3) score -= 20;
      else if (avgGad2 >= 2) score -= 10;
    }

    // Check for trigger patterns
    final triggerCount = recentMoods
        .map((m) => m.triggers.length)
        .reduce((a, b) => a + b);
    
    if (triggerCount > 15) score -= 10;
    else if (triggerCount > 10) score -= 5;

    return score.clamp(0, 100);
  }

  // 4. SLEEP SCORE
  static int _calculateSleepScore(List<HealthMetric> metrics) {
    final sleepMetrics = metrics.where((m) => m.type == MetricType.sleep).toList();
    
    if (sleepMetrics.isEmpty) return 50;

    int score = 100;
    final lastSleep = sleepMetrics.first.value as double;

    if (lastSleep < 4 || lastSleep > 11) score -= 30;
    else if (lastSleep < 5 || lastSleep > 10) score -= 20;
    else if (lastSleep < 6 || lastSleep > 9) score -= 10;
    else if (lastSleep < 7 || lastSleep > 8) score -= 5;

    return score.clamp(0, 100);
  }

  // 5. ACTIVITY SCORE
  static int _calculateActivityScore(List<HealthMetric> metrics) {
    final stepMetrics = metrics.where((m) => m.type == MetricType.steps).toList();
    final calorieMetrics = metrics.where((m) => m.type == MetricType.calories).toList();

    if (stepMetrics.isEmpty && calorieMetrics.isEmpty) return 50;

    int score = 100;
    final steps = stepMetrics.isNotEmpty ? stepMetrics.first.value as int : 0;
    final calories = calorieMetrics.isNotEmpty ? calorieMetrics.first.value as int : 0;

    // Steps scoring
    if (steps > 0) {
      if (steps >= 10000) score += 10;
      else if (steps >= 7500) score += 5;
      else if (steps < 3000) score -= 15;
      else if (steps < 5000) score -= 10;
    }

    // Calories scoring (rough estimate)
    if (calories > 0) {
      if (calories >= 500) score += 5;
      else if (calories < 200) score -= 5;
    }

    return score.clamp(0, 100);
  }

  // 6. RECOMMENDATIONS GENERATOR
  static List<String> _generateRecommendations(
    int totalScore,
    Map<HealthCategory, int> categoryScores,
    int physicalScore,
    int mentalScore,
    int sleepScore,
    int activityScore,
  ) {
    final recommendations = <String>[];

    // Overall recommendation
    if (totalScore >= 80) {
      recommendations.add(" Excellent overall health! Keep up your healthy habits.");
    } else if (totalScore >= 65) {
      recommendations.add(" Good health! Small improvements can make a big difference.");
    } else if (totalScore >= 50) {
      recommendations.add(" Moderate health score. Focus on areas that need attention.");
    } else {
      recommendations.add(" Your health score needs attention. Please review the recommendations below.");
    }

    // Category-specific recommendations
    if (physicalScore < 70) {
      recommendations.add(" Monitor your blood pressure, heart rate, and glucose regularly. Consider consulting your doctor.");
    }

    if (mentalScore < 70) {
      recommendations.add(" Practice mindfulness and complete regular mood check-ins. Try our guided exercises.");
    }

    if (sleepScore < 70) {
      recommendations.add(" Aim for 7-8 hours of quality sleep. Maintain a consistent sleep schedule.");
    }

    if (activityScore < 70) {
      recommendations.add(" Aim for 10,000 steps daily. Try to be active for at least 30 minutes each day.");
    }

    // Specific recommendations based on mental health
    if (mentalScore < 50) {
      recommendations.add(" If you're struggling, please reach out to a mental health professional or call 988 for immediate support.");
    }

    // Limit to 5 recommendations
    return recommendations.take(5).toList();
  }

  // 7. TODAY'S FOCUS ENGINE
  static TodayFocus getTodayFocus({
    required List<HealthMetric> metrics,
    List<MoodEntry> moodEntries = const [],
  }) {
    final today = DateTime.now();
    final todaysMetrics = metrics.where((m) => 
      m.timeStamp.year == today.year && 
      m.timeStamp.month == today.month && 
      m.timeStamp.day == today.day
    ).toList();

    final todaysMood = moodEntries.where((m) =>
      m.timestamp.year == today.year &&
      m.timestamp.month == today.month &&
      m.timestamp.day == today.day
    ).toList();

    // Check if mood check-in was done today
    if (todaysMood.isEmpty) {
      return TodayFocus(
        title: "Mood Check-in",
        description: "Take 30 seconds to check in with your mental wellness today.",
        type: FocusType.mental,
        priority: 1,
        time: DateTime.now(),
        actions: const [
          FocusAction(label: "Check-in", action: "mood_checkin", icon: Icons.mood),
        ],
      );
    }

    // Check physical metrics
    if (todaysMetrics.isEmpty) {
      return TodayFocus(
        title: "Daily Check-in",
        description: "You haven't logged any vitals today. Let's start with Blood Pressure.",
        type: FocusType.bloodPressure,
        priority: 2,
        time: DateTime.now(),
        actions: const [
          FocusAction(label: "Log BP", action: "log_bp", icon: Icons.favorite),
        ],
      );
    }

    final loggedTypes = todaysMetrics.map((m) => m.type).toSet();

    if (!loggedTypes.contains(MetricType.bloodPressure)) {
      return TodayFocus(
        title: "Missing Vitals",
        description: "Don't forget to log your Blood Pressure today.",
        type: FocusType.bloodPressure,
        priority: 2,
        time: DateTime.now(),
        actions: const [
          FocusAction(label: "Log BP", action: "log_bp", icon: Icons.favorite),
        ],
      );
    }

    if (!loggedTypes.contains(MetricType.heartRate)) {
      return TodayFocus(
        title: "Heart Rate",
        description: "BP looks good! How is your resting Heart Rate today?",
        type: FocusType.heartRate,
        priority: 2,
        time: DateTime.now(),
        actions: const [
          FocusAction(label: "Log HR", action: "log_hr", icon: Icons.favorite_border),
        ],
      );
    }

    return TodayFocus(
      title: "All Caught Up! 🎉",
      description: "Great job! You've completed your core health tracking for today.",
      type: FocusType.activity,
      priority: 3,
      time: DateTime.now(),
      actions: const [],
    );
  }

  // 8. ABNORMAL ALERT SCANNER
  static List<AbnormalMetrices> scanForAbnormalities(List<HealthMetric> metrics) {
    List<AbnormalMetrices> alerts = [];
    if (metrics.isEmpty) return alerts;

    final recent = metrics.where((m) => 
      m.timeStamp.isAfter(DateTime.now().subtract(const Duration(hours: 48)))
    ).toList();

    for (var metric in recent) {
      if (metric.type == MetricType.bloodPressure) {
        final bp = metric.value as Bloodpressure;
        if (bp.systolic >= 180 || bp.diastolic >= 120) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' CRITICAL: Hypertensive crisis detected (${bp.systolic}/${bp.diastolic}). Seek immediate medical attention!',
            alertSevirity: AlertSevirity.critical,
            category: 'Cardiovascular',
            recommendation: 'Call 911 immediately or go to the nearest emergency room.',
          ));
        } else if (bp.systolic >= 140 || bp.diastolic >= 90) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' High blood pressure detected (${bp.systolic}/${bp.diastolic}).',
            alertSevirity: AlertSevirity.high,
            category: 'Cardiovascular',
            recommendation: 'Contact your healthcare provider and monitor daily.',
          ));
        } else if (bp.systolic >= 130 || bp.diastolic >= 85) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' Elevated blood pressure (${bp.systolic}/${bp.diastolic}).',
            alertSevirity: AlertSevirity.medium,
            category: 'Cardiovascular',
            recommendation: 'Monitor daily and consider lifestyle changes.',
          ));
        }
      } else if (metric.type == MetricType.glucose) {
        final glucose = metric.value as double;
        if (glucose > 240) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' CRITICAL: Very high blood glucose detected ($glucose mg/dL).',
            alertSevirity: AlertSevirity.critical,
            category: 'Metabolic',
            recommendation: 'Check ketones, seek immediate medical attention.',
          ));
        } else if (glucose > 180) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' High blood glucose detected ($glucose mg/dL).',
            alertSevirity: AlertSevirity.high,
            category: 'Metabolic',
            recommendation: 'Check ketones, stay hydrated, and consult your provider.',
          ));
        } else if (glucose < 55) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' CRITICAL: Very low blood glucose detected ($glucose mg/dL).',
            alertSevirity: AlertSevirity.critical,
            category: 'Metabolic',
            recommendation: 'Consume fast-acting carbohydrates immediately. Seek medical help if symptoms persist.',
          ));
        } else if (glucose < 70) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' Low blood glucose detected ($glucose mg/dL).',
            alertSevirity: AlertSevirity.high,
            category: 'Metabolic',
            recommendation: 'Consume fast-acting carbohydrates and retest in 15 minutes.',
          ));
        }
      } else if (metric.type == MetricType.heartRate) {
        final hr = metric.value as int;
        if (hr > 130 || hr < 30) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' CRITICAL: Abnormal heart rate detected ($hr bpm).',
            alertSevirity: AlertSevirity.critical,
            category: 'Cardiovascular',
            recommendation: 'Seek immediate medical attention.',
          ));
        } else if (hr > 110) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' High heart rate detected ($hr bpm).',
            alertSevirity: AlertSevirity.high,
            category: 'Cardiovascular',
            recommendation: 'Rest and monitor. Consult a doctor if persistent.',
          ));
        } else if (hr < 45) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' Low heart rate detected ($hr bpm).',
            alertSevirity: AlertSevirity.high,
            category: 'Cardiovascular',
            recommendation: 'Consult your healthcare provider if you experience symptoms.',
          ));
        }
      } else if (metric.type == MetricType.weight) {
        final weight = metric.value as double;
        if (weight > 180 || weight < 30) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' Extreme weight detected (${weight.toStringAsFixed(1)} kg).',
            alertSevirity: AlertSevirity.high,
            category: 'Metabolic',
            recommendation: 'Consult your healthcare provider for personalized guidance.',
          ));
        }
      } else if (metric.type == MetricType.temperature) {
        final temp = metric.value as double;
        if (temp > 39.5 || temp < 35.0) {
          alerts.add(AbnormalMetrices(
            metric: metric,
            alertmessage: ' Abnormal temperature detected (${temp.toStringAsFixed(1)}°C).',
            alertSevirity: AlertSevirity.high,
            category: 'General',
            recommendation: 'Monitor your symptoms and consult a doctor if concerned.',
          ));
        }
      }
    }
    return alerts;
  }

  // 9. MOOD TREND ANALYSIS
  static Map<String, dynamic> analyzeMoodTrends(List<MoodEntry> moodEntries) {
    if (moodEntries.isEmpty) {
      return {
        'trend': 'stable',
        'average': 0.0,
        'consistency': 0.0,
        'riskLevel': 'low',
        'insights': ['Start tracking your mood to get insights.'],
      };
    }

    final sorted = List<MoodEntry>.from(moodEntries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final ratings = sorted.map((e) => e.moodRating).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    // Determine trend
    String trend = 'stable';
    if (ratings.length >= 3) {
      final firstHalf = ratings.take(ratings.length ~/ 2).toList();
      final secondHalf = ratings.skip(ratings.length ~/ 2).toList();
      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
      
      if (secondAvg > firstAvg + 1.0) trend = 'improving';
      else if (secondAvg < firstAvg - 1.0) trend = 'declining';
    }

    // Risk level
    String riskLevel = 'low';
    final phq2Scores = sorted.where((m) => m.phq2Score != null).map((m) => m.phq2Score!).toList();
    final gad2Scores = sorted.where((m) => m.gad2Score != null).map((m) => m.gad2Score!).toList();
    
    if (phq2Scores.any((s) => s >= 3) || gad2Scores.any((s) => s >= 3)) {
      riskLevel = 'high';
    } else if (phq2Scores.any((s) => s >= 2) || gad2Scores.any((s) => s >= 2)) {
      riskLevel = 'moderate';
    }

    // Insights
    final insights = <String>[];
    if (avg <= 3) {
      insights.add('Your mood has been consistently low. Consider reaching out for support.');
    } else if (avg <= 5) {
      insights.add('Your mood is moderate. Try our guided exercises for mood improvement.');
    } else if (avg >= 8) {
      insights.add('Great! Your mood is consistently high. Keep up your wellness practices.');
    }

    if (trend == 'declining') {
      insights.add('Your mood has been declining. Pay extra attention to self-care.');
    }

    if (riskLevel == 'high') {
      insights.add('High risk indicators detected. Please consider speaking with a professional.');
    }

    // Consistency (lower = more volatile)
    final variance = ratings.map((r) => (r - avg) * (r - avg)).reduce((a, b) => a + b) / ratings.length;
    final consistency = (1 - (math.sqrt(variance) / 4.5)).clamp(0.0, 1.0);

    return {
      'trend': trend,
      'average': avg,
      'consistency': consistency,
      'riskLevel': riskLevel,
      'insights': insights,
    };
  }
}
import 'package:flutter/material.dart';

enum MetricType {
  bloodPressure,
  weight,
  glucose,
  heartRate,
  steps,
  sleep,
  calories,
  hydration,
  oxygenSaturation,
  temperature,
}

enum MetricSource {
  manual,
  weareable,
  imported,
  calculated,
}

enum HealthCategory {
  activity,
  sleep,
  nutrition,
  screening,
  mental,
  cardioVascular,
  metabolic,
}

enum AlertSevirity {
  info,
  low,
  medium,
  high,
  critical,
}

enum WeareableType {
  applehealth,
  googleFit,
  fit,
  samsungHealth,
  aura,
}

extension WeareableTypeExtension on WeareableType {
  String get displayname {
    switch (this) {
      case WeareableType.applehealth:
        return 'Apple Health';
      case WeareableType.googleFit:
        return 'Google Fit';
      case WeareableType.fit:
        return 'Fit Band';
      case WeareableType.samsungHealth:
        return 'Samsung Health';
      case WeareableType.aura:
        return 'Aura Ring';
    }
  }

  IconData get icon {
    switch (this) {
      case WeareableType.applehealth:
        return Icons.apple_rounded;
      case WeareableType.googleFit:
        return Icons.fitness_center_rounded;
      case WeareableType.fit:
        return Icons.watch_rounded;
      case WeareableType.samsungHealth:
        return Icons.smartphone_rounded;
      case WeareableType.aura:
        return Icons.circle_rounded;
    }
  }
}

enum BloodPresureCategory {
  normal,
  elevated,
  hypertensionStage1,
  hypertensionStage2,
  hypertensiveCrisis,
}

extension BloodpressureType on BloodPresureCategory {
  String get displayname {
    switch (this) {
      case BloodPresureCategory.normal:
        return 'Normal';
      case BloodPresureCategory.elevated:
        return 'Elevated';
      case BloodPresureCategory.hypertensionStage1:
        return 'Stage 1 Hypertension';
      case BloodPresureCategory.hypertensionStage2:
        return 'Stage 2 Hypertension';
      case BloodPresureCategory.hypertensiveCrisis:
        return 'Hypertensive Crisis';
    }
  }

  Color get color {
    switch (this) {
      case BloodPresureCategory.normal:
        return Colors.green;
      case BloodPresureCategory.elevated:
        return Colors.yellow;
      case BloodPresureCategory.hypertensionStage1:
        return Colors.orange;
      case BloodPresureCategory.hypertensionStage2:
        return Colors.red;
      case BloodPresureCategory.hypertensiveCrisis:
        return Colors.red.shade900;
    }
  }
}

enum ScoreStatus {
  excellent,
  good,
  fair,
  poor,
  critical,
}

extension ScoreStatusExtension on ScoreStatus {
  String get displayname {
    switch (this) {
      case ScoreStatus.excellent:
        return 'Excellent';
      case ScoreStatus.good:
        return 'Good';
      case ScoreStatus.fair:
        return 'Fair';
      case ScoreStatus.poor:
        return 'Poor';
      case ScoreStatus.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case ScoreStatus.excellent:
        return Colors.green.shade700;
      case ScoreStatus.good:
        return Colors.green.shade400;
      case ScoreStatus.fair:
        return Colors.orange;
      case ScoreStatus.poor:
        return Colors.red.shade400;
      case ScoreStatus.critical:
        return Colors.red.shade900;
    }
  }
}

enum FocusType {
  bloodPressure,
  weight,
  glucose,
  heartRate,
  activity,
  sleep,
  nutrition,
  screening,
  mental,
  emergency,
}

extension FocusTypeExtension on FocusType {
  String get displayname {
    switch (this) {
      case FocusType.bloodPressure:
        return 'Blood Pressure';
      case FocusType.weight:
        return 'Weight Management';
      case FocusType.glucose:
        return 'Blood Glucose';
      case FocusType.heartRate:
        return 'Heart Rate';
      case FocusType.activity:
        return 'Physical Activity';
      case FocusType.sleep:
        return 'Sleep Quality';
      case FocusType.nutrition:
        return 'Nutrition';
      case FocusType.screening:
        return 'Health Screening';
      case FocusType.mental:
        return 'Mental Wellness';
      case FocusType.emergency:
        return 'Emergency Alert';
    }
  }

  IconData get icon {
    switch (this) {
      case FocusType.bloodPressure:
        return Icons.favorite;
      case FocusType.weight:
        return Icons.monitor_weight;
      case FocusType.glucose:
        return Icons.opacity;
      case FocusType.heartRate:
        return Icons.favorite_border;
      case FocusType.activity:
        return Icons.directions_run;
      case FocusType.sleep:
        return Icons.bedtime;
      case FocusType.nutrition:
        return Icons.restaurant;
      case FocusType.screening:
        return Icons.health_and_safety;
      case FocusType.mental:
        return Icons.self_improvement;
      case FocusType.emergency:
        return Icons.warning;
    }
  }
}

enum TrendDepressed {
  sevenDays,
  thirtyDays,
  ninetyDays,
  oneYear,
}

extension TrendDepressedExtension on TrendDepressed {
  int get days {
    switch (this) {
      case TrendDepressed.sevenDays:
        return 7;
      case TrendDepressed.thirtyDays:
        return 30;
      case TrendDepressed.ninetyDays:
        return 90;
      case TrendDepressed.oneYear:
        return 365;
    }
  }

  String get label {
    switch (this) {
      case TrendDepressed.sevenDays:
        return '7 Days';
      case TrendDepressed.thirtyDays:
        return '30 Days';
      case TrendDepressed.ninetyDays:
        return '90 Days';
      case TrendDepressed.oneYear:
        return '1 Year';
    }
  }
}
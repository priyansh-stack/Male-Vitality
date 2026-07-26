import 'package:flutter/material.dart';

enum MetricType{
  bloodPressure,
  weight,
  glucose,
  heartRate,
  steps,
  sleep,
  clories,
  hydration,
  oxygenSaturation,
  temperature,
} 

enum MetricSource{
  manual,
  weareable,
  imported,
  calculated,
}

enum HealthCategory{
  activity,
  sleep,
  nutrition,
  screening,
  mental,
  cardioVacular,
  metabolic,
}

enum AlertSevirity{
  info,
  low,
  medium,
  high,
  critical,
}


enum WeareableType{
  applehealth,
  googleFit,
  fit,
  samsungHealth,
  aura,
}


// extendsion for wearebles
extension WeareableTypeExtension on WeareableType{
  String get displayname {
    switch(this){
      case WeareableType.applehealth:
      return 'AppleHealth';

      case WeareableType.googleFit:
        return 'Google Fit';
      
      case WeareableType.fit:
        return 'Fit Band';

      case WeareableType.samsungHealth:
        return 'Samsung Health ';

      case WeareableType.aura:
        return 'Aura Ring';
    }

  }


  String get Iconname {
    switch(this){
      case WeareableType.applehealth:
      return 'AppleHealth';

      case WeareableType.googleFit:
        return 'Google Fit';
      
      case WeareableType.fit:
        return 'Fit Band';

      case WeareableType.samsungHealth:
        return 'Samsung Health ';

      case WeareableType.aura:
        return 'Aura Ring';
    }

  }

}

enum BloodPresureCategory{
  normal,
  elevated,
  hypertensionStage1,
  hypertensionStage2,
  hypertensiveCrisis,
}

//extension for blood pressure

extension BloodpressureType on BloodPresureCategory{
 String get displayname{
  switch(this){
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

//enums for health score 

  enum ScoreStatus {
    excellent,
    good,
    fair,
    poor,
    critical,
  }

  extension ScoreStatusExtension on ScoreStatus{
    String get displayname{
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

    Color get color{
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
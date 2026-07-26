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

enum TrendPeriod{
  sevenDays,
  thirtyDays,
  ninetyDays,
  oneYear,
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
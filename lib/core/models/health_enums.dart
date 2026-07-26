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

enum MetricScore{
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
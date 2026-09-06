enum SmokingStatus { never, former, occasional, daily }
enum AlcoholConsumption { none, social, moderate, frequent }
enum ExerciseLevel { sedentary, light, moderate, active, intense }
enum SleepQuality { poor, fair, good, excellent }
enum DietType { balanced, vegetarian, vegan, keto, mediterranean, lowCarb, custom }

extension SmokingStatusExt on SmokingStatus {
  String get label {
    switch (this) {
      case SmokingStatus.never: return 'Never Smoked';
      case SmokingStatus.former: return 'Former Smoker';
      case SmokingStatus.occasional: return 'Occasional Smoker';
      case SmokingStatus.daily: return 'Daily Smoker';
    }
  }
}

extension AlcoholConsumptionExt on AlcoholConsumption {
  String get label {
    switch (this) {
      case AlcoholConsumption.none: return 'Non-drinker';
      case AlcoholConsumption.social: return 'Social Drinker';
      case AlcoholConsumption.moderate: return 'Moderate';
      case AlcoholConsumption.frequent: return 'Frequent';
    }
  }
}

extension ExerciseLevelExt on ExerciseLevel {
  String get label {
    switch (this) {
      case ExerciseLevel.sedentary: return 'Sedentary (< 1 day/wk)';
      case ExerciseLevel.light: return 'Light (1-2 days/wk)';
      case ExerciseLevel.moderate: return 'Moderate (3-4 days/wk)';
      case ExerciseLevel.active: return 'Active (5+ days/wk)';
      case ExerciseLevel.intense: return 'Athlete / High Intensity';
    }
  }
}

extension SleepQualityExt on SleepQuality {
  String get label {
    switch (this) {
      case SleepQuality.poor: return 'Poor (< 5 hrs)';
      case SleepQuality.fair: return 'Fair (5-6 hrs)';
      case SleepQuality.good: return 'Good (7-8 hrs)';
      case SleepQuality.excellent: return 'Excellent (8+ hrs)';
    }
  }
}

extension DietTypeExt on DietType {
  String get label {
    switch (this) {
      case DietType.balanced: return 'Balanced Standard';
      case DietType.vegetarian: return 'Vegetarian';
      case DietType.vegan: return 'Vegan';
      case DietType.keto: return 'Keto';
      case DietType.mediterranean: return 'Mediterranean';
      case DietType.lowCarb: return 'Low Carb';
      case DietType.custom: return 'Custom / Other';
    }
  }
}

class LifestyleFactors {
  final SmokingStatus smoking;
  final AlcoholConsumption alcohol;
  final ExerciseLevel exercise;
  final SleepQuality sleep;
  final DietType diet;
  final int stressLevel; // 1-10

  LifestyleFactors({
    this.smoking = SmokingStatus.never,
    this.alcohol = AlcoholConsumption.none,
    this.exercise = ExerciseLevel.moderate,
    this.sleep = SleepQuality.good,
    this.diet = DietType.balanced,
    this.stressLevel = 4,
  });

  bool get isSmoker => smoking == SmokingStatus.daily || smoking == SmokingStatus.occasional;

  Map<String, dynamic> toMap() {
    return {
      'smoking': smoking.name,
      'alcohol': alcohol.name,
      'exercise': exercise.name,
      'sleep': sleep.name,
      'diet': diet.name,
      'stressLevel': stressLevel,
    };
  }

  factory LifestyleFactors.fromMap(Map<String, dynamic> map) {
    return LifestyleFactors(
      smoking: SmokingStatus.values.firstWhere(
        (e) => e.name == map['smoking'],
        orElse: () => SmokingStatus.never,
      ),
      alcohol: AlcoholConsumption.values.firstWhere(
        (e) => e.name == map['alcohol'],
        orElse: () => AlcoholConsumption.none,
      ),
      exercise: ExerciseLevel.values.firstWhere(
        (e) => e.name == map['exercise'],
        orElse: () => ExerciseLevel.moderate,
      ),
      sleep: SleepQuality.values.firstWhere(
        (e) => e.name == map['sleep'],
        orElse: () => SleepQuality.good,
      ),
      diet: DietType.values.firstWhere(
        (e) => e.name == map['diet'],
        orElse: () => DietType.balanced,
      ),
      stressLevel: (map['stressLevel'] as num?)?.toInt() ?? 4,
    );
  }
}

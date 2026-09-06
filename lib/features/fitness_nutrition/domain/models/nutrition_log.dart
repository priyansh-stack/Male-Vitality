import '../../../../core/models/life_stage.dart';

class NutritionDailyTarget {
  final int targetCalories;
  final int targetProteinGrams;
  final int targetCarbsGrams;
  final int targetFatGrams;
  final int targetWaterMl;
  final int targetCalciumMg;
  final int targetZincMg;
  final String clinicalRationale;

  const NutritionDailyTarget({
    required this.targetCalories,
    required this.targetProteinGrams,
    required this.targetCarbsGrams,
    required this.targetFatGrams,
    required this.targetWaterMl,
    required this.targetCalciumMg,
    required this.targetZincMg,
    required this.clinicalRationale,
  });

  static NutritionDailyTarget forLifeStage(LifeStage stage) {
    switch (stage) {
      case LifeStage.teen:
        return const NutritionDailyTarget(
          targetCalories: 2800,
          targetProteinGrams: 140,
          targetCarbsGrams: 350,
          targetFatGrams: 90,
          targetWaterMl: 3000,
          targetCalciumMg: 1300,
          targetZincMg: 11,
          clinicalRationale: 'High-energy growth phase with accelerated protein synthesis and bone lengthening needs.',
        );
      case LifeStage.youngAdult:
        return const NutritionDailyTarget(
          targetCalories: 2600,
          targetProteinGrams: 150,
          targetCarbsGrams: 300,
          targetFatGrams: 80,
          targetWaterMl: 3200,
          targetCalciumMg: 1000,
          targetZincMg: 11,
          clinicalRationale: 'Peak physiological energy demands with focus on athletic recovery and metabolic stamina.',
        );
      case LifeStage.adult:
        return const NutritionDailyTarget(
          targetCalories: 2300,
          targetProteinGrams: 130,
          targetCarbsGrams: 240,
          targetFatGrams: 75,
          targetWaterMl: 2800,
          targetCalciumMg: 1000,
          targetZincMg: 11,
          clinicalRationale: 'Metabolic rate maintenance; zinc supports sperm morphology and healthy testosterone production.',
        );
      case LifeStage.midLife:
        return const NutritionDailyTarget(
          targetCalories: 2100,
          targetProteinGrams: 120,
          targetCarbsGrams: 200,
          targetFatGrams: 70,
          targetWaterMl: 2600,
          targetCalciumMg: 1000,
          targetZincMg: 11,
          clinicalRationale: 'Heart-healthy Mediterranean emphasis; lower glycemic load to counter rising insulin resistance.',
        );
      case LifeStage.olderAdult:
        return const NutritionDailyTarget(
          targetCalories: 1950,
          targetProteinGrams: 115,
          targetCarbsGrams: 190,
          targetFatGrams: 65,
          targetWaterMl: 2400,
          targetCalciumMg: 1200,
          targetZincMg: 11,
          clinicalRationale: 'Sarcopenia prevention via leucine-rich protein, paired with higher calcium to preserve bone mineral density.',
        );
      case LifeStage.senior:
        return const NutritionDailyTarget(
          targetCalories: 1800,
          targetProteinGrams: 110,
          targetCarbsGrams: 180,
          targetFatGrams: 60,
          targetWaterMl: 2200,
          targetCalciumMg: 1200,
          targetZincMg: 11,
          clinicalRationale: 'High-calcium, high-fiber, low-sodium regimen with proactive hydration monitoring against diminished thirst response.',
        );
    }
  }
}

class MealEntry {
  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final DateTime timestamp;

  const MealEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MealEntry.fromMap(Map<String, dynamic> map, String id) {
    return MealEntry(
      id: id,
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
      carbs: map['carbs'] ?? 0,
      fat: map['fat'] ?? 0,
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
    );
  }
}

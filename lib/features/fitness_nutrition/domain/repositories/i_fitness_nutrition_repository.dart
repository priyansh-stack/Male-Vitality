import '../../../../core/models/life_stage.dart';
import '../models/nutrition_log.dart';
import '../models/workout_exercise.dart';

abstract class IFitnessNutritionRepository {
  Future<List<WorkoutRoutine>> getWorkoutRoutinesForStage(LifeStage stage);
  Future<List<WorkoutRoutine>> getUserActiveRoutines(String userId);
  Future<void> addActiveRoutine(String userId, WorkoutRoutine routine);
  Future<void> removeActiveRoutine(String userId, String routineId);
  Future<NutritionDailyTarget?> getNutritionTarget(String userId);
  Future<void> saveNutritionTarget(String userId, NutritionDailyTarget target);
  Future<List<MealEntry>> getTodayMeals(String userId);
  Future<void> logMeal(String userId, MealEntry meal);
  Future<int> getTodayWaterMl(String userId);
  Future<void> addWaterMl(String userId, int amountMl);
  Future<void> resetTodayWater(String userId);
}

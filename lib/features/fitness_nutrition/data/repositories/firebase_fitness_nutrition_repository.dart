import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/life_stage.dart';
import '../../domain/clinical_workout_protocols.dart';
import '../../domain/models/nutrition_log.dart';
import '../../domain/models/workout_exercise.dart';
import '../../domain/repositories/i_fitness_nutrition_repository.dart';

class FirebaseFitnessNutritionRepository implements IFitnessNutritionRepository {
  final FirebaseFirestore _firestore;

  FirebaseFitnessNutritionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<WorkoutRoutine>> getWorkoutRoutinesForStage(LifeStage stage) async {
    // Returns evidence-based routines curated by clinical fitness team
    return ClinicalWorkoutProtocols.routines[stage] ?? [];
  }

  @override
  Future<List<MealEntry>> getTodayMeals(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .get();

      return snapshot.docs.map((doc) => MealEntry.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> logMeal(String userId, MealEntry meal) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(meal.id)
        .set(meal.toMap());
  }

  @override
  Future<int> getTodayWaterMl(String userId) async {
    try {
      final dateKey = DateTime.now().toIso8601String().substring(0, 10);
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('hydration')
          .doc(dateKey)
          .get();
      return (doc.data()?['amountMl'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> addWaterMl(String userId, int amountMl) async {
    final dateKey = DateTime.now().toIso8601String().substring(0, 10);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('hydration')
        .doc(dateKey)
        .set({'amountMl': FieldValue.increment(amountMl)}, SetOptions(merge: true));
  }

  @override
  Future<void> resetTodayWater(String userId) async {
    final dateKey = DateTime.now().toIso8601String().substring(0, 10);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('hydration')
        .doc(dateKey)
        .set({'amountMl': 0});
  }
}

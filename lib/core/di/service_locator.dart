import 'package:flutter/foundation.dart';
import '../../features/fitness_nutrition/data/repositories/firebase_fitness_nutrition_repository.dart';
import '../../features/fitness_nutrition/domain/repositories/i_fitness_nutrition_repository.dart';
import '../../features/medication/data/repositories/firebase_medication_repository.dart';
import '../../features/medication/domain/repositories/i_medication_repository.dart';
import '../../features/preventive_care/data/repositories/firebase_screening_repository.dart';
import '../../features/preventive_care/domain/repositories/i_screening_repository.dart';
import '../../features/senior_care/data/repositories/firebase_senior_care_repository.dart';
import '../../features/senior_care/domain/repositories/i_senior_care_repository.dart';
import '../../features/sexual_health/data/repositories/firebase_sexual_health_repository.dart';
import '../../features/sexual_health/domain/repositories/i_sexual_health_repository.dart';
import '../../features/sexual_health/data/repositories/firebase_fertility_repository.dart';
import '../../features/sexual_health/domain/repositories/i_fertility_repository.dart';
import '../../features/sleep/data/repositories/firebase_sleep_repository.dart';
import '../../features/sleep/domain/repositories/i_sleep_repository.dart';
import '../../features/substance_use/data/repositories/firebase_substance_repository.dart';
import '../../features/substance_use/domain/repositories/i_substance_repository.dart';
import '../../features/telehealth/data/repositories/firebase_telehealth_repository.dart';
import '../../features/telehealth/domain/repositories/i_telehealth_repository.dart';

class ServiceLocator {
  static late IScreeningRepository screeningRepository;
  static late IFitnessNutritionRepository fitnessNutritionRepository;
  static late ISexualHealthRepository sexualHealthRepository;
  static late IMedicationRepository medicationRepository;
  static late ISleepRepository sleepRepository;
  static late ISubstanceRepository substanceRepository;
  static late ITelehealthRepository telehealthRepository;
  static late ISeniorCareRepository seniorCareRepository;
  static late IFertilityRepository fertilityRepository;

  static void initialize() {
    debugPrint('⚡ [ServiceLocator] Initializing real Firebase Cloud Firestore repositories');

    screeningRepository = FirebaseScreeningRepository();
    fitnessNutritionRepository = FirebaseFitnessNutritionRepository();
    sexualHealthRepository = FirebaseSexualHealthRepository();
    medicationRepository = FirebaseMedicationRepository();
    sleepRepository = FirebaseSleepRepository();
    substanceRepository = FirebaseSubstanceRepository();
    telehealthRepository = FirebaseTelehealthRepository();
    seniorCareRepository = FirebaseSeniorCareRepository();
    fertilityRepository = FirebaseFertilityRepository();
  }
}

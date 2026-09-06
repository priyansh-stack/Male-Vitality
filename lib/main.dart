import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_event.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_event.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_bloc/metric_entry_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/bloc/Health_Dashboard/dashboard_bloc.dart';
import 'core/bloc/auth/auth_bloc.dart';
import 'core/bloc/health_sync/health_sync_bloc.dart';
import 'core/bloc/onboarding/onboarding_bloc.dart';
import 'core/services/auth_service.dart';
import 'core/services/database_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/health_sync_service.dart';
import 'core/services/weareable_service.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/usecase/add_health_metric.dart';
import 'router/app_router.dart';
import 'core/di/service_locator.dart';
import 'features/preventive_care/domain/repositories/i_screening_repository.dart';
import 'features/fitness_nutrition/domain/repositories/i_fitness_nutrition_repository.dart';
import 'features/sexual_health/domain/repositories/i_sexual_health_repository.dart';
import 'features/medication/domain/repositories/i_medication_repository.dart';
import 'features/sleep/domain/repositories/i_sleep_repository.dart';
import 'features/substance_use/domain/repositories/i_substance_repository.dart';
import 'features/telehealth/domain/repositories/i_telehealth_repository.dart';
import 'features/senior_care/domain/repositories/i_senior_care_repository.dart';
import 'features/sexual_health/domain/repositories/i_fertility_repository.dart';
import 'core/services/mental_wellness/mental_wellness_repository.dart';
import 'core/services/mental_wellness/mental_wellness_repository_impl.dart';
import 'core/bloc/mental_wellness/mood_bloc/mood_bloc.dart';
import 'core/bloc/mental_wellness/risk_detection_bloc/risk_detection_bloc.dart';
import 'core/bloc/mental_wellness/guided_exercise_bloc/guided_exercise_bloc.dart';
import 'core/bloc/mental_wellness/therapist_finder_bloc/therapist_finder_bloc.dart';
import 'core/bloc/mental_wellness/crisis_resource_bloc/crisis_resource_bloc.dart';
import 'features/mental_wellness/usecases/create_mood_entry_usecase.dart';
import 'features/mental_wellness/usecases/get_mood_history_usecase.dart';
import 'features/mental_wellness/usecases/get_mood_trends_usecase.dart';
import 'features/mental_wellness/usecases/get_mood_heatmap_usecase.dart';
import 'features/mental_wellness/usecases/delete_mood_entry_usecase.dart';
import 'features/mental_wellness/usecases/update_mood_entry_usecase.dart';
import 'features/mental_wellness/usecases/detect_risk_patterns_usecase.dart';
import 'features/mental_wellness/usecases/get_risk_history_usecase.dart';
import 'features/mental_wellness/usecases/generate_risk_alert_usecase.dart';
import 'features/mental_wellness/usecases/check_suicide_risk_usecase.dart';
import 'features/mental_wellness/usecases/check_depression_risk_usecase.dart';
import 'features/mental_wellness/usecases/check_anxiety_risk_usecase.dart';
import 'features/mental_wellness/usecases/get_guided_exercises_usecase.dart';
import 'features/mental_wellness/usecases/get_guided_exercise_by_id_usecase.dart';
import 'features/mental_wellness/usecases/track_exercise_progress_usecase.dart';
import 'features/mental_wellness/usecases/get_exercise_recommendations_usecase.dart';
import 'features/mental_wellness/usecases/filter_exercises_by_age_group_usecase.dart';
import 'features/mental_wellness/usecases/get_exercise_categories_usecase.dart';
import 'features/mental_wellness/usecases/search_therapists_usecase.dart';
import 'features/mental_wellness/usecases/get_teletherapy_providers_usecase.dart';
import 'features/mental_wellness/usecases/filter_therapists_by_insurance_usecase.dart';
import 'features/mental_wellness/usecases/book_therapy_session_usecase.dart';
import 'features/mental_wellness/usecases/get_therapist_availability_usecase.dart';
import 'features/mental_wellness/usecases/get_crisis_resources_usecase.dart';
import 'features/mental_wellness/usecases/get_local_emergency_services_usecase.dart';
import 'features/mental_wellness/usecases/get_national_hotlines_usecase.dart';
import 'features/mental_wellness/usecases/trigger_emergency_protocol_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await FirebaseService.initialize();
    debugPrint('Firebase initialized on ${FirebaseService.platform}');
    
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize Hydrated Storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );

  final firestore = FirebaseFirestore.instance;
  final firestoreService = FirestoreService(firestore: firestore);
  final authService = AuthService();
  final healthSyncService = HealthSyncService(firestoreService);
  final databaseService = DatabaseService(
    firestoreService: firestoreService,
    firestore: firestore,
  );
  final wearableService = WearableService(databaseService);

  // ===== INITIALIZE SERVICE LOCATOR =====
  ServiceLocator.initialize();

  // ===== MENTAL WELLNESS REPOSITORY =====
  final mentalWellnessRepository = MentalWellnessRepositoryImpl(
    firestore: firestore,
    prefs: await SharedPreferences.getInstance(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        ChangeNotifierProvider<HealthSyncService>.value(value: healthSyncService),
        Provider<DatabaseService>.value(value: databaseService),
        Provider<WearableService>.value(value: wearableService),
        Provider<MentalWellnessRepository>.value(value: mentalWellnessRepository),
        
        // Vertical Slice Repositories (Decoupled Interfaces)
        Provider<IScreeningRepository>.value(value: ServiceLocator.screeningRepository),
        Provider<IFitnessNutritionRepository>.value(value: ServiceLocator.fitnessNutritionRepository),
        Provider<ISexualHealthRepository>.value(value: ServiceLocator.sexualHealthRepository),
        Provider<IMedicationRepository>.value(value: ServiceLocator.medicationRepository),
        Provider<ISleepRepository>.value(value: ServiceLocator.sleepRepository),
        Provider<ISubstanceRepository>.value(value: ServiceLocator.substanceRepository),
        Provider<ITelehealthRepository>.value(value: ServiceLocator.telehealthRepository),
        Provider<ISeniorCareRepository>.value(value: ServiceLocator.seniorCareRepository),
        Provider<IFertilityRepository>.value(value: ServiceLocator.fertilityRepository),
        
        // Auth BLoC
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            context.read<AuthService>(),
          )..add(AuthCheckRequested()),
        ),
        
        // Onboarding BLoC
        BlocProvider<OnboardingBloc>(
          create: (context) => OnboardingBloc(
            context.read<FirestoreService>(),
          )..add(OnboardingStarted()),
        ),
        
        // Health Sync BLoC
        BlocProvider<HealthSyncBloc>(
          create: (context) => HealthSyncBloc(
            context.read<HealthSyncService>(),
          ),
        ),
        
        // Dashboard BLoC
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(
            databaseService: context.read<DatabaseService>(),
            wearableService: context.read<WearableService>(),
          ),
        ),
        
        // Metric Entry BLoC
        BlocProvider<MetricEntryBloc>(
          create: (context) => MetricEntryBloc(
            addHealthMetric: AddHealthMetric(
              context.read<DatabaseService>(),
            ),
          ),
        ),

        // ===== MENTAL WELLNESS BLoCs =====
        BlocProvider<MoodBloc>(
          create: (context) => MoodBloc(
            createMoodEntryUseCase: CreateMoodEntryUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getMoodHistoryUseCase: GetMoodHistoryUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getMoodTrendsUseCase: GetMoodTrendsUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getMoodHeatmapUseCase: GetMoodHeatmapUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            deleteMoodEntryUseCase: DeleteMoodEntryUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            updateMoodEntryUseCase: UpdateMoodEntryUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
          ),
        ),

        BlocProvider<RiskDetectionBloc>(
          create: (context) => RiskDetectionBloc(
            detectRiskPatternsUseCase: DetectRiskPatternsUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getRiskHistoryUseCase: GetRiskHistoryUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            generateRiskAlertUseCase: GenerateRiskAlertUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            checkSuicideRiskUseCase: CheckSuicideRiskUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            checkDepressionRiskUseCase: CheckDepressionRiskUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            checkAnxietyRiskUseCase: CheckAnxietyRiskUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
          ),
        ),

        BlocProvider<GuidedExerciseBloc>(
          create: (context) => GuidedExerciseBloc(
            getGuidedExercisesUseCase: GetGuidedExercisesUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getGuidedExerciseByIdUseCase: GetGuidedExerciseByIdUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            trackExerciseProgressUseCase: TrackExerciseProgressUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getExerciseRecommendationsUseCase: GetExerciseRecommendationsUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            filterExercisesByAgeGroupUseCase: FilterExercisesByAgeGroupUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getExerciseCategoriesUseCase: GetExerciseCategoriesUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
          ),
        ),

        BlocProvider<TherapistFinderBloc>(
          create: (context) => TherapistFinderBloc(
            searchTherapistsUseCase: SearchTherapistsUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getTeletherapyProvidersUseCase: GetTeletherapyProvidersUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            filterTherapistsByInsuranceUseCase: FilterTherapistsByInsuranceUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            bookTherapySessionUseCase: BookTherapySessionUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getTherapistAvailabilityUseCase: GetTherapistAvailabilityUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
          ),
        ),

        BlocProvider<CrisisResourceBloc>(
          create: (context) => CrisisResourceBloc(
            getCrisisResourcesUseCase: GetCrisisResourcesUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getLocalEmergencyServicesUseCase: GetLocalEmergencyServicesUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            getNationalHotlinesUseCase: GetNationalHotlinesUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
            triggerEmergencyProtocolUseCase: TriggerEmergencyProtocolUseCase(
              repository: context.read<MentalWellnessRepository>(),
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Male Vitality - Health Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
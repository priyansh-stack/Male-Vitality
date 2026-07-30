import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_event.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_event.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_bloc/metric_entry_bloc.dart';
import 'package:provider/provider.dart';
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

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await FirebaseService.initialize();
    debugPrint('Firebase initialized on ${FirebaseService.platform}');
    
    // OPTIMIZATION 1: Enable Firestore Offline Persistence
    // This forces Firestore to read from the local cache first, saving you thousands of reads.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  //  OPTIMIZATION 2: Initialize Hydrated Storage
  // This allows your BLoCs to save their state to the device.
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        ChangeNotifierProvider<HealthSyncService>.value(value: healthSyncService),
        Provider<DatabaseService>.value(value: databaseService),
        Provider<WearableService>.value(value: wearableService),
        
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            context.read<AuthService>(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<OnboardingBloc>(
          create: (context) => OnboardingBloc(
            context.read<FirestoreService>(),
          )..add(OnboardingStarted()),
        ),
        BlocProvider<HealthSyncBloc>(
          create: (context) => HealthSyncBloc(
            context.read<HealthSyncService>(),
          ),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(
            databaseService: context.read<DatabaseService>(),
            wearableService: context.read<WearableService>(),
          ),
        ),
        BlocProvider<MetricEntryBloc>(
          create: (context) => MetricEntryBloc(
            addHealthMetric: AddHealthMetric(
              context.read<DatabaseService>(),
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
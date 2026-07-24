
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:life_stage_health_app/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/health_sync_service.dart';
import 'core/bloc/auth/auth_bloc.dart';
import 'core/bloc/auth/auth_event.dart';
import 'core/bloc/onboarding/onboarding_bloc.dart';
import 'core/bloc/onboarding/onboarding_event.dart';
import 'core/bloc/health_sync/health_sync_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();

  final firestoreService = FirestoreService();
  final authService = AuthService();
  final healthSyncService = HealthSyncService(firestoreService);

  runApp(
    MultiProvider(
      providers: [
        // AuthService extends ChangeNotifier
        ChangeNotifierProvider<AuthService>.value(value: authService),
        // FirestoreService is a regular service
        Provider<FirestoreService>.value(value: firestoreService),
        // HealthSyncService extends ChangeNotifier
        ChangeNotifierProvider<HealthSyncService>.value(value: healthSyncService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              context.read<AuthService>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => OnboardingBloc(
              context.read<FirestoreService>(),
            )..add(OnboardingStarted()),
          ),
          BlocProvider(
            create: (context) => HealthSyncBloc(
              context.read<HealthSyncService>(),
            ),
          ),
        ],
        child: const LifeStageHealthApp(), // This is now defined below
      ),
    ),
  );
}

// Define the LifeStageHealthApp class
class LifeStageHealthApp extends StatelessWidget {
  const LifeStageHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Male Life-Stage Health Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppRootRouter(),
    );
  }
}
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
  
  try {
    // Initialize Firebase first
    await FirebaseService.initialize();
    debugPrint('App starting on ${FirebaseService.platform}');
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
    
  }

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
        child: const LifeStageHealthApp(),
      ),
    ),
  );
}

class LifeStageHealthApp extends StatelessWidget {
  const LifeStageHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Male Life-Stage Health Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FirebaseService.isInitialized 
          ? const AppRootRouter()
          : const FirebaseErrorScreen(),
    );
  }
}

// Error screen if Firebase fails to initialize
class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Firebase Initialization Failed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                FirebaseService.initializationError ?? 'Unknown error occurred',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                'Please check your configuration and restart the app',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await FirebaseService.initialize();
                    // Rebuild the app
                    runApp(
                      MaterialApp(
                        home: Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    );
                    // Re-run main
                    main();
                  } catch (e) {
                    // Error is already handled
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
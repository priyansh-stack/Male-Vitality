import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_bloc.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_state.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_bloc.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_event.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/services/firebase_service.dart';
import 'package:life_stage_health_app/core/theme/app_theme.dart';
import 'package:life_stage_health_app/features/auth/auth_screen.dart';
import 'package:life_stage_health_app/features/dashboard/main_dashboard.dart';
import 'package:life_stage_health_app/features/dashboard/screens/add_metric_screen.dart';
import 'package:life_stage_health_app/features/dashboard/screens/health_summary_screen.dart';
import 'package:life_stage_health_app/features/dashboard/screens/metric_detail_screen.dart';
import 'package:life_stage_health_app/features/onboarding/life_stage_welcome_screen.dart';
import 'package:life_stage_health_app/features/onboarding/step_emergency_contact.dart';
import 'package:life_stage_health_app/features/onboarding/step_health_profile.dart';
import 'package:life_stage_health_app/features/onboarding/step_permissions.dart';
import 'package:life_stage_health_app/features/onboarding/step_personal_info.dart';
import 'package:life_stage_health_app/features/welcome/welcome_screen.dart';
import 'package:life_stage_health_app/features/mental_wellness/screens/mood_checkin_screen.dart';
import 'package:life_stage_health_app/features/mental_wellness/screens/mood_history_screen.dart';
import 'package:life_stage_health_app/features/mental_wellness/screens/guided_exercise_library_screen.dart';
import 'package:life_stage_health_app/features/mental_wellness/screens/guided_exercise_player_screen.dart';
import 'package:life_stage_health_app/features/mental_wellness/screens/stress_management_screen.dart';
import 'package:life_stage_health_app/features/mental_wellness/screens/crisis_resource_access_screen.dart';
import 'package:life_stage_health_app/features/mental_wellness/screens/therapist_finder_screen.dart';
import 'package:life_stage_health_app/core/models/life_stage.dart';
import 'package:life_stage_health_app/core/di/service_locator.dart';
import 'package:life_stage_health_app/features/health_modules/screens/health_modules_screen.dart';
import 'package:life_stage_health_app/features/learn/screens/learn_screen.dart';
import 'package:life_stage_health_app/features/profile/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_stage_health_app/features/preventive_care/presentation/screens/preventive_care_screen.dart';
import 'package:life_stage_health_app/features/fitness_nutrition/presentation/screens/fitness_nutrition_screen.dart';
import 'package:life_stage_health_app/features/sexual_health/presentation/screens/sexual_health_screen.dart';
import 'package:life_stage_health_app/features/medication/presentation/screens/medication_manager_screen.dart';
import 'package:life_stage_health_app/features/sleep/presentation/screens/sleep_optimizer_screen.dart';
import 'package:life_stage_health_app/features/substance_use/presentation/screens/substance_assessment_screen.dart';
import 'package:life_stage_health_app/features/telehealth/presentation/screens/telehealth_screen.dart';
import 'package:life_stage_health_app/features/senior_care/presentation/screens/senior_care_screen.dart';
import 'package:life_stage_health_app/features/sexual_health/presentation/screens/fertility_tracker_screen.dart';
import 'package:life_stage_health_app/features/mental_wellness/screens/mental_wellness_screen.dart';
import 'package:life_stage_health_app/core/bloc/Health_Dashboard/dashboard_bloc.dart';
import 'package:life_stage_health_app/core/models/health_daily.dart';
import 'package:life_stage_health_app/core/models/health_score.dart';
import 'package:life_stage_health_app/features/ai_assistant/cubit/vitality_copilot_cubit.dart';
import 'package:life_stage_health_app/features/ai_assistant/presentation/screens/vitality_chat_screen.dart';
import 'package:life_stage_health_app/features/ai_assistant/services/vitality_gemini_service.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = 
      GlobalKey<NavigatorState>(debugLabel: 'root');
  
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  // Debouncing variables to prevent infinite redirect loops
  static DateTime? _lastRedirectTime;
  static const Duration _minRedirectInterval = Duration(milliseconds: 500);
  static String? _lastRedirectPath;
  static bool _isRedirecting = false;
  static final Set<String> _profileLoadRequested = <String>{};

  static final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);
  static void refresh() {
    refreshNotifier.value++;
  }

  static GoRouter? _router;
  static GoRouter get router => _router ??= _createRouter('/');

  static void initRouter({String initialLocation = '/'}) {
    _router = _createRouter(initialLocation);
  }

  static GoRouter _createRouter(String initialLocation) => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: true,
    redirect: _redirectLogic,
    routes: [
      // ===== SHELL ROUTE WITH BOTTOM NAV =====
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffoldWithNavBar(
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          // Dashboard Tab
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) {
              String userId = '';
              final queryParams = state.uri.queryParameters;
              if (queryParams.containsKey('userId')) {
                userId = queryParams['userId'] ?? '';
              }
              if (userId.isEmpty && state.extra != null) {
                userId = state.extra as String? ?? '';
              }
              if (userId.isEmpty) {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  userId = authState.user.uid;
                }
              }
              return UnifiedDashboardScreen(userId: userId);
            },
          ),
          // Tab 2: Health Modules (Life-Stage Adaptive)
          GoRoute(
            path: '/health-modules',
            name: 'health-modules',
            builder: (context, state) => const HealthModulesScreen(),
          ),
          // Legacy alias for /track to /health-modules (eliminates duplicate screen)
          GoRoute(
            path: '/track',
            name: 'track',
            builder: (context, state) => const HealthModulesScreen(),
          ),
          // Tab 4: Learn
          GoRoute(
            path: '/learn',
            name: 'learn',
            builder: (context, state) => const LearnScreen(),
          ),
          // Tab 5: Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          // Legacy aliases
          GoRoute(
            path: '/health',
            name: 'health',
            builder: (context, state) => const HealthModulesScreen(),
          ),
          GoRoute(
            path: '/wellness',
            name: 'wellness',
            builder: (context, state) {
              final authState = context.read<AuthBloc>().state;
              final currentUid = authState is Authenticated ? authState.user.uid : (FirebaseAuth.instance.currentUser?.uid ?? '');
              final userId = state.uri.queryParameters['userId'] ?? 
                  (state.extra as String?) ?? currentUid;
              return MentalWellnessScreen(userId: userId);
            },
          ),
        ],
      ),

      // ===== PUBLIC ROUTES =====
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // ===== ONBOARDING ROUTES =====
      GoRoute(
        path: '/onboarding/personal-info',
        name: 'onboarding-personal',
        builder: (context, state) => const Scaffold(
          appBar: OnboardingAppBar(
            title: 'Step 1 of 4: Personal Info',
            progress: 0.25,
          ),
          body: StepPersonalInfo(),
        ),
      ),
      
      GoRoute(
        path: '/onboarding/health-profile',
        name: 'onboarding-health',
        builder: (context, state) => const Scaffold(
          appBar: OnboardingAppBar(
            title: 'Step 2 of 4: Health Profile',
            progress: 0.50,
          ),
          body: StepHealthProfile(),
        ),
      ),
      
      GoRoute(
        path: '/onboarding/emergency-contact',
        name: 'onboarding-emergency',
        builder: (context, state) => const Scaffold(
          appBar: OnboardingAppBar(
            title: 'Step 3 of 4: Emergency Contact',
            progress: 0.75,
          ),
          body: StepEmergencyContact(),
        ),
      ),
      
      GoRoute(
        path: '/onboarding/permissions',
        name: 'onboarding-permissions',
        builder: (context, state) => const Scaffold(
          appBar: OnboardingAppBar(
            title: 'Step 4 of 4: Permissions',
            progress: 1.0,
          ),
          body: StepPermissions(),
        ),
      ),
      
      GoRoute(
        path: '/onboarding/welcome',
        name: 'onboarding-welcome',
        builder: (context, state) => const LifeStageWelcomeScreen(),
      ),

      // ===== DASHBOARD SUB-ROUTES =====
      GoRoute(
        path: '/metric-detail',
        name: 'metric-detail',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return MetricDetailScreen(
            userId: args?['userId'] ?? '',
            metricType: args?['metricType'] ?? MetricType.bloodPressure,
          );
        },
      ),
      
      GoRoute(
        path: '/add-metric',
        name: 'add-metric',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return AddMetricScreen(
            userId: args?['userId'] ?? '',
          );
        },
      ),
      
      GoRoute(
        path: '/health-summary',
        name: 'health-summary',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return HealthSummaryScreen(
            userId: args?['userId'] ?? '',
            startDate: args?['startDate'] ?? DateTime.now().subtract(const Duration(days: 30)),
            endDate: args?['endDate'] ?? DateTime.now(),
          );
        },
      ),

      // ===== MENTAL WELLNESS ROUTES =====
      GoRoute(
        path: '/mood-checkin',
        name: 'mood-checkin',
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? 
              (state.extra as String?) ?? '';
          return MoodCheckinScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/mood-history',
        name: 'mood-history',
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? 
              (state.extra as String?) ?? '';
          return MoodHistoryScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        builder: (context, state) {
          return GuidedExerciseLibraryScreen(
            userLifeStage: LifeStage.adult,
          );
        },
      ),
      GoRoute(
        path: '/exercise-player/:id',
        name: 'exercise-player',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return GuidedExercisePlayerScreen(exerciseId: id);
        },
      ),
      GoRoute(
        path: '/stress-management',
        name: 'stress-management',
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? 
              (state.extra as String?) ?? '';
          return StressManagementScreen(
            userId: userId,
            userLifeStage: LifeStage.adult,
          );
        },
      ),
      GoRoute(
        path: '/crisis-resources',
        name: 'crisis-resources',
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? 
              (state.extra as String?) ?? '';
          return CrisisResourceAccessScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/therapist-finder',
        name: 'therapist-finder',
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? 
              (state.extra as String?) ?? '';
          return TherapistFinderScreen(userId: userId);
        },
      ),

      // ===== PREVENTIVE CARE ROUTE =====
      GoRoute(
        path: '/preventive-care',
        name: 'preventive-care',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          final profile = context.read<OnboardingBloc>().state.completedProfile;
          return PreventiveCareScreen(
            userId: userId,
            repository: ServiceLocator.screeningRepository,
            userAge: profile?.age ?? 35,
            isSmoker: profile?.lifestyleFactors.isSmoker ?? false,
          );
        },
      ),

      // ===== FITNESS & NUTRITION ROUTE =====
      GoRoute(
        path: '/fitness-nutrition',
        name: 'fitness-nutrition',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          final profile = context.read<OnboardingBloc>().state.completedProfile;
          return FitnessNutritionScreen(
            userId: userId,
            lifeStage: profile?.lifeStage ?? LifeStage.adult,
            repository: ServiceLocator.fitnessNutritionRepository,
          );
        },
      ),

      // ===== HORMONE & SEXUAL HEALTH ROUTES =====
      GoRoute(
        path: '/sexual-health',
        name: 'sexual-health',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return SexualHealthScreen(
            userId: userId,
            repository: ServiceLocator.sexualHealthRepository,
          );
        },
      ),
      GoRoute(
        path: '/sexual-health/sti',
        name: 'sexual-health-sti',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return SexualHealthScreen(
            userId: userId,
            repository: ServiceLocator.sexualHealthRepository,
          );
        },
      ),
      GoRoute(
        path: '/sexual-health/fertility',
        name: 'sexual-health-fertility',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return FertilityTrackerScreen(
            userId: userId,
            repository: ServiceLocator.fertilityRepository,
          );
        },
      ),

      // ===== MEDICATION & POLYPHARMACY ROUTES =====
      GoRoute(
        path: '/medications',
        name: 'medications',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return MedicationManagerScreen(
            userId: userId,
            repository: ServiceLocator.medicationRepository,
          );
        },
      ),
      GoRoute(
        path: '/medications/interactions',
        name: 'medications-interactions',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return MedicationManagerScreen(
            userId: userId,
            repository: ServiceLocator.medicationRepository,
          );
        },
      ),

      // ===== SLEEP OPTIMIZER ROUTE =====
      GoRoute(
        path: '/sleep-optimizer',
        name: 'sleep-optimizer',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return SleepOptimizerScreen(
            userId: userId,
            repository: ServiceLocator.sleepRepository,
          );
        },
      ),

      // ===== SUBSTANCE USE ASSESSMENT ROUTE =====
      GoRoute(
        path: '/substance-assessment',
        name: 'substance-assessment',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return SubstanceAssessmentScreen(
            userId: userId,
            repository: ServiceLocator.substanceRepository,
          );
        },
      ),

      // ===== TELEHEALTH ROUTE =====
      GoRoute(
        path: '/telehealth',
        name: 'telehealth',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return TelehealthScreen(
            userId: userId,
            repository: ServiceLocator.telehealthRepository,
          );
        },
      ),

      // ===== SENIOR CARE & FALL DETECTION ROUTES =====
      GoRoute(
        path: '/senior-care/fall-detection',
        name: 'senior-care-fall',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return SeniorCareScreen(
            userId: userId,
            repository: ServiceLocator.seniorCareRepository,
          );
        },
      ),
      GoRoute(
        path: '/senior-care/brain-training',
        name: 'senior-care-brain',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return SeniorCareScreen(
            userId: userId,
            repository: ServiceLocator.seniorCareRepository,
          );
        },
      ),
      GoRoute(
        path: '/senior-care/caregiver',
        name: 'senior-care-caregiver',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : 'guest';
          return SeniorCareScreen(
            userId: userId,
            repository: ServiceLocator.seniorCareRepository,
            initialTabIndex: 2,
          );
        },
      ),

      // ===== VITALITY HEALTH COPILOT (GEMINI AI) ROUTE =====
      GoRoute(
        path: '/ai-assistant',
        name: 'ai-assistant',
        builder: (context, state) {
          final dashboardBloc = context.read<DashboardBloc>();
          final onboardingBloc = context.read<OnboardingBloc>();

          final userProfile = onboardingBloc.state.completedProfile;
          HealthScore? healthScore;
          HealthDaily? todayDaily;
          List<HealthDaily> recentDailies = const [];

          if (dashboardBloc.state is DashboardLoaded) {
            final loaded = dashboardBloc.state as DashboardLoaded;
            healthScore = loaded.healthScore;
            todayDaily = loaded.todayHealthDaily;
            recentDailies = loaded.recentHealthDailies;
          }

          return BlocProvider(
            create: (_) => VitalityCopilotCubit(
              geminiService: VitalityGeminiService(),
              userProfile: userProfile,
              healthScore: healthScore,
              todayHealthDaily: todayDaily,
              recentHealthDailies: recentDailies,
            ),
            child: const VitalityChatScreen(),
          );
        },
      ),

      // ===== ERROR ROUTE =====
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) => const FirebaseErrorScreen(),
      ),
    ],
  );

  //REDIRECT LOGIC - WITH DEBOUNCING
  static Future<String?> _redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    if (_isRedirecting) {
      debugPrint('⏭ Redirect already in progress, skipping');
      return null;
    }

    final now = DateTime.now();
    final currentPath = state.uri.path;
    
    if (_lastRedirectTime != null && 
        now.difference(_lastRedirectTime!) < _minRedirectInterval &&
        _lastRedirectPath == currentPath) {
      debugPrint('⏭ Skipping rapid redirect to: $currentPath');
      return null;
    }

    _isRedirecting = true;
    _lastRedirectTime = now;
    _lastRedirectPath = currentPath;

    try {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      final onboardingBloc = context.read<OnboardingBloc>();
      final onboardingState = onboardingBloc.state;

      if (authState is AuthLoading || authState is AuthInitial) {
        debugPrint(' Auth loading or initial...');
        return null;
      }

      debugPrint(' Redirect: path=$currentPath, auth=${authState.runtimeType}');

      if (authState is Unauthenticated) {
        _profileLoadRequested.clear();
        final publicPaths = ['/', '/auth', '/welcome'];
        if (publicPaths.contains(currentPath)) {
          return null;
        }
        debugPrint(' Unauthenticated, redirecting to /');
        UnifiedDashboardScreen.resetState();
        return '/';
      }

      if (authState is Authenticated) {
        final userId = authState.user.uid;
        debugPrint(' User authenticated: $userId');
        
        final prefs = await SharedPreferences.getInstance();
        final isLocallyComplete = prefs.getBool('onboarding_completed_$userId') ?? 
            prefs.getBool('onboarding_completed_global') ?? 
            false;

        if (onboardingState.completedProfile == null && !_profileLoadRequested.contains(userId)) {
          _profileLoadRequested.add(userId);
          debugPrint(' Loading profile once for userId: $userId...');
          onboardingBloc.add(LoadSavedProfile(userId));
        }
        
        final isOnboardingComplete = isLocallyComplete || (onboardingState.completedProfile != null);
        debugPrint(' Onboarding complete: $isOnboardingComplete (cached: $isLocallyComplete)');

        if (!isOnboardingComplete) {
          final onboardingPaths = [
            '/onboarding/personal-info',
            '/onboarding/health-profile',
            '/onboarding/emergency-contact',
            '/onboarding/permissions',
            '/onboarding/welcome',
          ];
          
          if (onboardingPaths.contains(currentPath)) {
            return null;
          }
          debugPrint(' Not onboarded, redirecting to onboarding');
          return '/onboarding/personal-info';
        }

        final onboardingPaths = [
          '/onboarding/personal-info',
          '/onboarding/health-profile',
          '/onboarding/emergency-contact',
          '/onboarding/permissions',
          '/onboarding/welcome',
        ];
        
        if (onboardingPaths.contains(currentPath)) {
          debugPrint(' Already onboarded, redirecting to dashboard');
          return '/dashboard?userId=$userId';
        }

        if (currentPath == '/' || currentPath == '/auth' || currentPath == '/welcome') {
          debugPrint(' Redirecting from public path to dashboard');
          return '/dashboard?userId=$userId';
        }

        if (currentPath == '/dashboard') {
          final queryParams = state.uri.queryParameters;
          if (!queryParams.containsKey('userId') || queryParams['userId']?.isEmpty == true) {
            debugPrint(' Adding userId to dashboard URL');
            return '/dashboard?userId=$userId';
          }
        }

        return null;
      }

      return '/';
    } catch (e) {
      debugPrint(' Redirect error: $e');
      return '/';
    } finally {
      _isRedirecting = false;
    }
  }
}

// ONBOARDING APP BAR - FUTURISTIC HUD
class OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double progress;

  const OnboardingAppBar({
    super.key,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final stepPercentage = (progress * 100).toInt();
    return AppBar(
      backgroundColor: AppTheme.darkCanvas,
      elevation: 0,
      title: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppTheme.cyberCyan,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cyberCyan,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'PROTOCOL CALIBRATION // $stepPercentage% COMPLETE',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.cyberCyan,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Container(
          height: 4,
          color: const Color(0xFF1E2D4A),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * progress.clamp(0.0, 1.0),
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.cyberCyan],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cyberCyan,
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

// MAIN SCAFFOLD WITH FLOATING FROSTED GLASS CYBER DOCK
class MainScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const MainScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.currentPath,
  });

  int get _currentIndex {
    if (currentPath.contains('/health-modules') || currentPath.contains('/health') || currentPath.contains('/track')) {
      return 1;
    }
    if (currentPath.contains('/learn')) {
      return 2;
    }
    if (currentPath.contains('/profile')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.uid : '';

    return Scaffold(
      backgroundColor: AppTheme.darkCanvas,
      body: child,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'app_scaffold_crisis_fab',
        backgroundColor: AppTheme.neonRed,
        elevation: 6,
        icon: const Icon(Icons.emergency_rounded, color: Colors.white, size: 18),
        label: const Text(
          '988 CRISIS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 0.8,
          ),
        ),
        onPressed: () {
          context.push('/crisis-resources?userId=$userId');
        },
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppTheme.cyberCyan.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppTheme.cyberCyan.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.speed_rounded, 'HUD', '/dashboard?userId=$userId'),
            _buildNavItem(context, 1, Icons.grid_view_rounded, 'Modules', '/health-modules'),
            _buildNavItem(context, 2, Icons.menu_book_rounded, 'Learn', '/learn'),
            _buildNavItem(context, 3, Icons.person_rounded, 'Profile', '/profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, String route) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.go(route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.cyberCyan.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.cyberCyan.withValues(alpha: 0.45)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.cyberCyan : const Color(0xFF64748B),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppTheme.cyberCyan : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FIREBASE ERROR SCREEN
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Firebase Connection Error',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                FirebaseService.initializationError ?? 'Unknown error occurred',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseService.initialize();
                      context.go('/');
                    } catch (e) {
                      // Error handled
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Retry Connection',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_bloc.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_event.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_state.dart';
import 'package:life_stage_health_app/core/bloc/mental_wellness/mood_bloc/mood_bloc.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_bloc.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_event.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/mood_entry.dart';
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

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: _redirectLogic,
    routes: [
      // ===== SHELL ROUTE WITH BOTTOM NAV =====
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffoldWithNavBar(child: child);
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
          // Health Tab
          GoRoute(
            path: '/health',
            name: 'health',
            builder: (context, state) {
              return const HealthTabScreen();
            },
          ),
          // Mental Wellness Tab
          GoRoute(
            path: '/wellness',
            name: 'wellness',
            builder: (context, state) {
              final userId = state.uri.queryParameters['userId'] ?? 
                  (state.extra as String?) ?? '';
              return MentalWellnessTabScreen(userId: userId);
            },
          ),
          // Profile Tab
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) {
              return const ProfileTabScreen();
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
        
        if (onboardingState.completedProfile == null) {
          debugPrint(' Loading profile from Firestore...');
          onboardingBloc.add(LoadSavedProfile(userId));
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        final isOnboardingComplete = onboardingState.completedProfile != null;
        debugPrint(' Onboarding complete: $isOnboardingComplete');

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

// ONBOARDING APP BAR
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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(6),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFFE2E8F0),
          color: const Color(0xFF4F46E5),
          minHeight: 4,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 6);
}

// MAIN SCAFFOLD WITH BOTTOM NAVIGATION
class MainScaffoldWithNavBar extends StatefulWidget {
  final Widget child;

  const MainScaffoldWithNavBar({super.key, required this.child});

  @override
  State<MainScaffoldWithNavBar> createState() => _MainScaffoldWithNavBarState();
}

class _MainScaffoldWithNavBarState extends State<MainScaffoldWithNavBar> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndexFromRoute();
    });
  }

  void _updateIndexFromRoute() {
    final route = ModalRoute.of(context);
    if (route != null) {
      final path = route.settings.name ?? '';
      if (path.contains('/dashboard')) {
        _currentIndex = 0;
      } else if (path.contains('/health')) {
        _currentIndex = 1;
      } else if (path.contains('/wellness')) {
        _currentIndex = 2;
      } else if (path.contains('/profile')) {
        _currentIndex = 3;
      }
    }
  }

  @override
  void didUpdateWidget(covariant MainScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIndexFromRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.uid : '';

          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              context.go('/dashboard?userId=$userId');
              break;
            case 1:
              context.go('/health');
              break;
            case 2:
              context.go('/wellness?userId=$userId');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_rounded),
            label: 'Wellness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// TAB SCREENS
class HealthTabScreen extends StatelessWidget {
  const HealthTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Health Tab - Coming Soon'),
      ),
    );
  }
}

class AnalyticsTabScreen extends StatelessWidget {
  const AnalyticsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Analytics Tab - Coming Soon'),
      ),
    );
  }
}

  // ===== MENTAL WELLNESS TAB SCREEN =====
  class MentalWellnessTabScreen extends StatefulWidget {
    final String userId;

    const MentalWellnessTabScreen({super.key, this.userId = ''});

    @override
    State<MentalWellnessTabScreen> createState() => _MentalWellnessTabScreenState();
  }

  class _MentalWellnessTabScreenState extends State<MentalWellnessTabScreen> {
    @override
    void initState() {
      super.initState();
      if (widget.userId.isNotEmpty) {
        _loadRecentMood();
      }
    }

    void _loadRecentMood() {
      context.read<MoodBloc>().add(
        LoadMoodHistoryEvent(
          userId: widget.userId,
          days: 7,
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mental Wellness'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.mood),
              onPressed: () {
                if (widget.userId.isNotEmpty) {
                  context.go('/mood-checkin?userId=${widget.userId}');
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                if (widget.userId.isNotEmpty) {
                  context.go('/mood-history?userId=${widget.userId}');
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<MoodBloc, MoodState>(
          listener: (context, state) {
            if (state is MoodErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // Get the latest entries
            List<MoodEntry> recentEntries = [];
            if (state is MoodHistoryLoadedState) {
              recentEntries = state.entries.take(5).toList();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuickActionCard(
                        context,
                        title: 'Mood Check-in',
                        icon: Icons.mood,
                        color: const Color(0xFF6366F1),
                        onTap: () {
                          if (widget.userId.isNotEmpty) {
                            context.go('/mood-checkin?userId=${widget.userId}');
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildQuickActionCard(
                        context,
                        title: 'Mood History',
                        icon: Icons.calendar_today,
                        color: const Color(0xFF06B6D4),
                        onTap: () {
                          if (widget.userId.isNotEmpty) {
                            context.go('/mood-history?userId=${widget.userId}');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuickActionCard(
                        context,
                        title: 'Exercises',
                        icon: Icons.self_improvement,
                        color: const Color(0xFF10B981),
                        onTap: () => context.go('/exercises'),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickActionCard(
                        context,
                        title: 'Stress Tools',
                        icon: Icons.spa,
                        color: const Color(0xFFF59E0B),
                        onTap: () {
                          if (widget.userId.isNotEmpty) {
                            context.go('/stress-management?userId=${widget.userId}');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuickActionCard(
                        context,
                        title: 'Crisis Support',
                        icon: Icons.warning_amber,
                        color: const Color(0xFFDC2626),
                        onTap: () {
                          if (widget.userId.isNotEmpty) {
                            context.go('/crisis-resources?userId=${widget.userId}');
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildQuickActionCard(
                        context,
                        title: 'Find Therapist',
                        icon: Icons.people,
                        color: const Color(0xFF8B5CF6),
                        onTap: () {
                          if (widget.userId.isNotEmpty) {
                            context.go('/therapist-finder?userId=${widget.userId}');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Daily Tip
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ' Daily Wellness Tip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Take 5 minutes today to practice deep breathing. It can help reduce stress and improve focus.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Mood Section - NOW DYNAMIC
                  _buildRecentMoodSection(recentEntries, state),
                ],
              ),
            );
          },
        ),
      );
    }

    Widget _buildRecentMoodSection(List<MoodEntry> entries, MoodState state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Mood',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (entries.isNotEmpty)
                TextButton(
                  onPressed: () {
                    if (widget.userId.isNotEmpty) {
                      context.go('/mood-history?userId=${widget.userId}');
                    }
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Show loading state
          if (state is MoodLoadingState)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),

          // Show entries if available
          if (entries.isNotEmpty)
            ...entries.map((entry) => _buildMoodEntryCard(entry)),

          // Show empty state if no entries
          if (entries.isEmpty && state is! MoodLoadingState)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mood_bad,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No mood entries yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Start your first check-in!',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (widget.userId.isNotEmpty) {
                        context.go('/mood-checkin?userId=${widget.userId}');
                      }
                    },
                    icon: const Icon(Icons.mood),
                    label: const Text('Check-in Now'),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    Widget _buildMoodEntryCard(MoodEntry entry) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Mood circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getMoodColor(entry.moodRating),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  entry.moodRating.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(entry.timestamp),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (entry.triggers.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: entry.triggers.take(3).map((trigger) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trigger,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        );
                      }).toList(),
                    ),
                  if (entry.notes != null)
                    Text(
                      entry.notes!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // PHQ-2 / GAD-2 indicators
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (entry.phq2Score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: entry.phq2Score! >= 3 ? Colors.red.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'PHQ-2: ${entry.phq2Score}',
                      style: TextStyle(
                        fontSize: 10,
                        color: entry.phq2Score! >= 3 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (entry.gad2Score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: entry.gad2Score! >= 3 ? Colors.orange.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'GAD-2: ${entry.gad2Score}',
                      style: TextStyle(
                        fontSize: 10,
                        color: entry.gad2Score! >= 3 ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    Color _getMoodColor(int rating) {
      if (rating >= 8) return AppTheme.healthyGreen;
      if (rating >= 6) return AppTheme.primaryTeal;
      if (rating >= 4) return AppTheme.warningOrange;
      return AppTheme.dangerRed;
    }

    String _formatDate(DateTime date) {
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        if (diff.inHours < 1) {
          if (diff.inMinutes < 1) return 'Just now';
          return '${diff.inMinutes}m ago';
        }
        return '${diff.inHours}h ago';
      }
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    }

    Widget _buildQuickActionCard(
      BuildContext context, {
      required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              context.go('/');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Profile Tab - Coming Soon'),
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
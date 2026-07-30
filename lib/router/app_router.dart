import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_bloc.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_event.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_state.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_bloc.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_event.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/services/firebase_service.dart';
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

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = 
      GlobalKey<NavigatorState>(debugLabel: 'root');
  
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  //  Debouncing variables to prevent infinite redirect loops
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
              // Try to get userId from query parameters first
              final queryParams = state.uri.queryParameters;
              if (queryParams.containsKey('userId')) {
                userId = queryParams['userId'] ?? '';
              }
              // If not in query params, try extra
              if (userId.isEmpty && state.extra != null) {
                userId = state.extra as String? ?? '';
              }
              // If still empty, try auth state
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
          // Analytics Tab
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) {
              return const AnalyticsTabScreen();
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

      // ===== ERROR ROUTE =====
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) => const FirebaseErrorScreen(),
      ),
    ],
  );

  // ============================================
  // REDIRECT LOGIC - WITH DEBOUNCING
  // ============================================
  static Future<String?> _redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    //  Prevent concurrent redirects
    if (_isRedirecting) {
      debugPrint('⏭ Redirect already in progress, skipping');
      return null;
    }

    //  Prevent rapid redirect loops
    final now = DateTime.now();
    final currentPath = state.uri.path;
    
    if (_lastRedirectTime != null && 
        now.difference(_lastRedirectTime!) < _minRedirectInterval &&
        _lastRedirectPath == currentPath) {
      debugPrint('⏭️ Skipping rapid redirect to: $currentPath');
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

      // Wait for auth to initialize
      if (authState is AuthLoading || authState is AuthInitial) {
        debugPrint('⏳ Auth loading or initial...');
        return null;
      }

      debugPrint(' Redirect: path=$currentPath, auth=${authState.runtimeType}');

      //  UNAUTHENTICATED
      if (authState is Unauthenticated) {
        final publicPaths = ['/', '/auth', '/welcome'];
        if (publicPaths.contains(currentPath)) {
          return null;
        }
        debugPrint(' Unauthenticated, redirecting to /');
        
        //  Reset dashboard state on logout
        UnifiedDashboardScreen.resetState();
        
        return '/';
      }

      // AUTHENTICATED
      if (authState is Authenticated) {
        final userId = authState.user.uid;
        
        debugPrint(' User authenticated: $userId');
        
        //  Check if onboarding is complete
        if (onboardingState.completedProfile == null) {
          debugPrint(' Loading profile from Firestore...');
          onboardingBloc.add(LoadSavedProfile(userId));
          
          // Wait for profile to load
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        // Re-check after potential load
        final isOnboardingComplete = onboardingState.completedProfile != null;
        debugPrint(' Onboarding complete: $isOnboardingComplete');

        // NOT ONBOARDED
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

        // ONBOARDED - Redirect properly
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

        // If on dashboard without userId, add it
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
      //  Always reset the redirect flag
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
      } else if (path.contains('/analytics')) {
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
              if (userId.isNotEmpty) {
                context.go('/dashboard?userId=$userId');
              } else {
                context.go('/dashboard');
              }
              break;
            case 1:
              context.go('/health');
              break;
            case 2:
              context.go('/analytics');
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
            icon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_event.dart';
import 'package:life_stage_health_app/core/models/health_score.dart';
import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_widgets/abnormal_alerts.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_widgets/health_score_card.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_widgets/metric_chart.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_widgets/metrics_grid.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_widgets/quick_metric_entry.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_widgets/today_focus_card.dart';
import 'package:life_stage_health_app/features/dashboard/screens/add_metric_screen.dart';
import '../../../core/bloc/Health_Dashboard/dashboard_bloc.dart';
import '../../../core/bloc/Health_Dashboard/support_states.dart';
import '../../../core/bloc/auth/auth_bloc.dart';
import '../../../core/bloc/auth/auth_state.dart';
import '../../../core/bloc/health_sync/health_sync_bloc.dart';
import '../../../core/bloc/health_sync/health_sync_event.dart';
import '../../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../../core/models/health_enums.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';

class UnifiedDashboardScreen extends StatefulWidget {
  final String userId;

  const UnifiedDashboardScreen({super.key, required this.userId});

  static void resetState() {
    _UnifiedDashboardScreenState.resetState();
  }

  @override
  State<UnifiedDashboardScreen> createState() => _UnifiedDashboardScreenState();
}

class _UnifiedDashboardScreenState extends State<UnifiedDashboardScreen>
    with AutomaticKeepAliveClientMixin<UnifiedDashboardScreen> {
  static bool _isLoadingData = false;
  static String? _lastLoadedUserId;
  static DateTime? _lastLoadTime;

  static const Duration _minLoadInterval = Duration(seconds: 15);

  @override
  bool get wantKeepAlive => true;

  static void resetState() {
    _isLoadingData = false;
    _lastLoadedUserId = null;
    _lastLoadTime = null;
    debugPrint('🔄 Dashboard state reset');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void didUpdateWidget(UnifiedDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId && widget.userId.isNotEmpty) {
      _lastLoadedUserId = null;
      _loadDashboardData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadDashboardData() {
    if (_isLoadingData) {
      debugPrint('⏭️ Load already in progress, skipping');
      return;
    }

    String userId = widget.userId;

    if (userId.isEmpty) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        userId = authState.user.uid;
      }
    }

    if (userId.isEmpty) {
      debugPrint('❌ No userId available, skipping load');
      return;
    }

    // If dashboard is already loaded with valid data for this user, do not trigger a full reload spinner
    final dashboardBloc = context.read<DashboardBloc>();
    if (dashboardBloc.state is DashboardLoaded) {
      final currentData = dashboardBloc.state as DashboardLoaded;
      if (currentData.healthScore.userId == userId) {
        debugPrint('✅ Dashboard data already active for user: $userId (skipping reload)');
        return;
      }
    }

    final now = DateTime.now();
    if (_lastLoadedUserId == userId &&
        _lastLoadTime != null &&
        now.difference(_lastLoadTime!) < _minLoadInterval) {
      debugPrint(
        '⏭️ Skipping duplicate load for user: $userId (cooldown active)',
      );
      return;
    }

    _isLoadingData = true;
    _lastLoadedUserId = userId;
    _lastLoadTime = now;

    debugPrint('🔄 Loading dashboard for userId: $userId');

    context.read<DashboardBloc>().add(LoadDashboardData(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authState = context.watch<AuthBloc>().state;
    final onboardingState = context.watch<OnboardingBloc>().state;

    String userId = '';
    String userName = 'User';
    String userEmail = '';

    if (authState is Authenticated) {
      userId = authState.user.uid;
      userName = authState.user.displayName;
      userEmail = authState.user.email;
    }

    final profile = onboardingState.completedProfile;
    if (profile != null) {
      userName = profile.displayName;
      userEmail = profile.email;
    }

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    if (authState is! Authenticated) {
      _isLoadingData = false;

      return Scaffold(
        backgroundColor: AppTheme.obsidianBase,
        appBar: _buildAppBar(context, userName, userEmail, userId),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: AppTheme.cyberCardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.neonCyan.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: AppTheme.neonCyan,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'BIOMETRIC AUTHENTICATION REQUIRED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please authorize credentials to initialize Vitality Command HUD',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonCyan,
                    foregroundColor: AppTheme.obsidianBase,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'AUTHENTICATE ACCESS',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.obsidianBase,
      appBar: _buildAppBar(context, userName, userEmail, userId),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded || state is DashboardError) {
            _isLoadingData = false;
          }

          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.neonCrimson,
              ),
            );
          }
          if (state is SyncComplete) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.neonEmerald,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.neonCyan,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'SYNCHRONIZING TELEMETRY STREAM...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.neonCyan,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cyberCardDecoration(
                    borderColor: AppTheme.neonCrimson.withOpacity(0.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 52,
                        color: AppTheme.neonCrimson,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'TELEMETRY LINK INTERRUPTED',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _isLoadingData = false;
                          _loadDashboardData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonCyan,
                          foregroundColor: AppTheme.obsidianBase,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'RECONNECT TELEMETRY',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              color: AppTheme.cyberCyan,
              backgroundColor: AppTheme.darkCard,
              onRefresh: () async {
                _isLoadingData = false;
                _loadDashboardData();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 90.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Warm Greeting & Health Status
                    _buildGreetingHeader(context, greeting, userName),
                    const SizedBox(height: 18),

                    // 2. Hero Daily Vitality Score Card
                    HealthScoreCard(
                      healthScore: state.healthScore,
                      onTap: () {
                        _showScoreDetails(context, state.healthScore);
                      },
                    ),
                    const SizedBox(height: 18),

                    // 3. Today's Essential Male Biomarkers (HR, Steps, Sleep, Vascular)
                    _buildCoreBiomarkersCard(context, state, userId),
                    const SizedBox(height: 18),

                    // 4. Today's Health Directive
                    TodayFocusCard(
                      focus: state.todayFocus,
                      onActionTap: (action) {
                        _handleFocusAction(context, action, userId);
                      },
                    ),
                    const SizedBox(height: 18),

                    // 5. Abnormal Health Alerts (if any)
                    if (state.abnormalMetrics.isNotEmpty) ...[
                      AbnormalAlerts(
                        alerts: state.abnormalMetrics,
                        onAlertTap: (alert) {
                          _showAlertDetails(context, alert, userId);
                        },
                      ),
                      const SizedBox(height: 18),
                    ],

                    // 6. Quick Health Log Hub
                    QuickMetricEntry(
                      userId: userId,
                      onMetricAdded: () {
                        _loadDashboardData();
                      },
                    ),
                    const SizedBox(height: 18),

                    // 7. Weekly Vitals Progression
                    MetricChart(
                      metrics: state.allMetrics,
                      selectedPeriod: state.trendDepressed,
                      onPeriodChanged: (period) {
                        context.read<DashboardBloc>().add(
                          SelectTimeRange(trendDepressed: period),
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // 8. Recent Health Biomarkers (if any)
                    if (state.recentMetrics.isNotEmpty) ...[
                      MetricsGrid(
                        metrics: state.recentMetrics,
                        onMetricTap: (type) {
                          context.push(
                            '/metric-detail',
                            extra: {'userId': userId, 'metricType': type},
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                    ],
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: AppTheme.cyberCyan),
          );
        },
      ),
    );
  }

  // ============= App Bar =============
  AppBar _buildAppBar(
    BuildContext context,
    String userName,
    String userEmail,
    String userId,
  ) {
    return AppBar(
      backgroundColor: AppTheme.darkCanvas,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.cyberCyan.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cyberCyan.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: AppTheme.darkCard,
              radius: 20,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppTheme.cyberCyan,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userEmail.isNotEmpty
                      ? userEmail
                      : 'CLINICAL VITALITY ACTIVE',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.add_chart_rounded,
            color: AppTheme.cyberCyan,
            size: 22,
          ),
          tooltip: 'Log Telemetry',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMetricScreen(userId: userId),
              ),
            ).then((result) {
              if (result == true) {
                _isLoadingData = false;
                _lastLoadedUserId = null;
                _loadDashboardData();
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppTheme.cyberCyan,
            size: 22,
          ),
          tooltip: 'Clinical Alerts',
          onPressed: () => _showNotificationsSheet(context, userId),
        ),
        PopupMenuButton<String>(
          color: AppTheme.darkCard,
          icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted),
          onSelected: (value) {
            if (value == 'profile' || value == 'settings') {
              context.push('/profile');
            } else if (value == 'logout') {
              context.read<DashboardBloc>().add(const ClearDashboardData());
              context.read<FirestoreService>().clearUserCache(userId);
              UnifiedDashboardScreen.resetState();
              context.read<AuthBloc>().add(AuthSignOutRequested());
              context.go('/');
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 18,
                    color: AppTheme.cyberCyan,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Clinical Profile',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 18, color: AppTheme.cyberCyan),
                  SizedBox(width: 12),
                  Text(
                    'Vitality Settings',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(color: AppTheme.darkBorder),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    Icons.power_settings_new_rounded,
                    color: AppTheme.neonRed,
                    size: 18,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Sign Out',
                    style: TextStyle(color: AppTheme.neonRed, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============= Helper Widgets =============

  Widget _buildGreetingHeader(
    BuildContext context,
    String greeting,
    String userName,
  ) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.bioEmerald,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.bioEmerald.withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'HEALTH STATUS // OPTIMAL',
                  style: TextStyle(
                    color: AppTheme.bioEmerald.withOpacity(0.95),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            Text(
              dateStr,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${greeting.toUpperCase()},',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.cyberCyan,
            letterSpacing: 1.1,
          ),
        ),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCoreBiomarkersCard(
    BuildContext context,
    DashboardLoaded dashboardState,
    String userId,
  ) {
    final daily = dashboardState.todayHealthDaily;
    final hasDailyData = daily != null;

    final stepsStr = daily?.steps != null
        ? NumberFormat.decimalPattern().format(daily!.steps)
        : '--';

    // RHR: If today's RHR has not yet finalized (e.g. intraday before nocturnal sleep computation),
    // fallback to the most recent recorded resting HR from recentHealthDailies.
    int? effectiveRhr = daily?.restingHeartRate;
    if (effectiveRhr == null || effectiveRhr <= 0) {
      for (final d in dashboardState.recentHealthDailies) {
        if (d.restingHeartRate != null && d.restingHeartRate! > 0) {
          effectiveRhr = d.restingHeartRate;
          break;
        }
      }
    }
    final hrStr = effectiveRhr != null ? '$effectiveRhr' : '--';

    // Sleep: If today's sleep has not yet finalized, fallback to most recent recorded sleep
    int? effectiveSleepMinutes = (daily?.sleepMinutes != null && daily!.sleepMinutes! > 0)
        ? daily.sleepMinutes
        : null;
    if (effectiveSleepMinutes == null) {
      for (final d in dashboardState.recentHealthDailies) {
        if (d.sleepMinutes != null && d.sleepMinutes! > 0) {
          effectiveSleepMinutes = d.sleepMinutes;
          break;
        }
      }
    }
    final sleepStr = effectiveSleepMinutes != null
        ? '${(effectiveSleepMinutes / 60).toStringAsFixed(1)}h'
        : '--';

    // Fourth metric: Calories (primary if > 0) or SpO2
    final cal = daily?.calories;
    final hasCalories = cal != null && cal > 0;
    int? effectiveCalories = hasCalories ? cal : null;
    if (effectiveCalories == null) {
      for (final d in dashboardState.recentHealthDailies) {
        if (d.calories != null && d.calories! > 0) {
          effectiveCalories = d.calories;
          break;
        }
      }
    }

    double? effectiveSpo2 = daily?.avgSpo2;
    if (effectiveSpo2 == null) {
      for (final d in dashboardState.recentHealthDailies) {
        if (d.avgSpo2 != null && d.avgSpo2! > 0) {
          effectiveSpo2 = d.avgSpo2;
          break;
        }
      }
    }

    final isCalories = effectiveCalories != null && effectiveCalories > 0;
    final fourthStr = isCalories
        ? NumberFormat.decimalPattern().format(effectiveCalories)
        : (effectiveSpo2 != null ? '${effectiveSpo2.toStringAsFixed(0)}%' : '--');
    final fourthLabel = isCalories ? 'CALORIES' : 'SPO2';
    final fourthUnit = isCalories ? 'kcal' : '';
    final fourthIcon = isCalories ? Icons.local_fire_department_rounded : Icons.air_rounded;
    final fourthColor = isCalories ? AppTheme.neonAmber : AppTheme.bioEmerald;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cyberCardDecoration(
        borderColor: AppTheme.darkBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.monitor_heart_outlined,
                    color: AppTheme.cyberCyan,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'CORE MALE VITALITY METRICS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.cyberCyan,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  context.read<HealthSyncBloc>().add(
                    RequestGoogleFitEvent(userId),
                  );
                  _loadDashboardData();
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sync_rounded,
                        size: 13,
                        color: hasDailyData ? AppTheme.bioEmerald : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasDailyData ? 'SYNCED' : 'SYNC',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: hasDailyData ? AppTheme.bioEmerald : AppTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildVitalPill(
                value: hrStr,
                unit: 'bpm',
                label: 'RESTING HR',
                icon: Icons.favorite_rounded,
                color: AppTheme.neonRed,
                onTap: () {
                  context.push(
                    '/metric-detail',
                    extra: {'userId': userId, 'metricType': MetricType.heartRate},
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildVitalPill(
                value: stepsStr,
                unit: 'steps',
                label: 'MOVEMENT',
                icon: Icons.directions_walk_rounded,
                color: AppTheme.cyberCyan,
                onTap: () {
                  context.push(
                    '/metric-detail',
                    extra: {'userId': userId, 'metricType': MetricType.steps},
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildVitalPill(
                value: sleepStr,
                unit: '',
                label: 'SLEEP',
                icon: Icons.nightlight_round,
                color: AppTheme.neonPurple,
                onTap: () {
                  context.push(
                    '/metric-detail',
                    extra: {'userId': userId, 'metricType': MetricType.sleep},
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildVitalPill(
                value: fourthStr,
                unit: fourthUnit,
                label: fourthLabel,
                icon: fourthIcon,
                color: fourthColor,
                onTap: () {
                  final metricType = hasDailyData ? MetricType.calories : MetricType.bloodPressure;
                  context.push(
                    '/metric-detail',
                    extra: {'userId': userId, 'metricType': metricType},
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalPill({
    required String value,
    required String unit,
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (unit.isNotEmpty) ...[
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============= Helper Methods =============

  void _showScoreDetails(BuildContext context, HealthScore score) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.obsidianCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: AppTheme.neonCyan,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'CLINICAL TELEMETRY BREAKDOWN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.neonCyan,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...score.categoryScores.entries.map((entry) {
                return ListTile(
                  title: Text(
                    _getCategoryLabel(entry.key),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    '${entry.value} / 100',
                    style: const TextStyle(
                      color: AppTheme.neonCyan,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  leading: _getScoreIndicator(entry.value),
                );
              }),
              const Divider(color: AppTheme.obsidianBorder),
              ListTile(
                title: const Text(
                  'COMPOSITE VITALITY INDEX',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                trailing: Text(
                  '${score.score} / 100',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.neonEmerald,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAlertDetails(
    BuildContext context,
    AbnormalMetrices alert,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final sevColor = _getSeverityColor(alert.alertSevirity);
        return AlertDialog(
          backgroundColor: AppTheme.obsidianCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: sevColor.withOpacity(0.5)),
          ),
          title: Text(
            '${_getMetricLabel(alert.metric.type).toUpperCase()} ALERT',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.alertmessage,
                style: TextStyle(
                  color: sevColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Telemetry: ${alert.metric.displayValue} ${alert.metric.unit}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Recorded: ${_formatDate(alert.metric.timeStamp)}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              if (alert.recommendation != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Clinical Protocol: ${alert.recommendation}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'DISMISS',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(
                  '/metric-detail',
                  extra: {'userId': userId, 'metricType': alert.metric.type},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonCyan,
                foregroundColor: AppTheme.obsidianBase,
              ),
              child: const Text(
                'INVESTIGATE',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleFocusAction(BuildContext context, FocusAction action, String userId) {
    if (action.action == 'mood_checkin') {
      context.push('/mood-checkin', extra: userId);
      return;
    }
    if (action.action == 'log_bp') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMetricScreen(
            userId: userId,
            initialMetricType: MetricType.bloodPressure,
          ),
        ),
      ).then((result) {
        if (result == true) {
          _isLoadingData = false;
          _lastLoadedUserId = null;
          _loadDashboardData();
        }
      });
      return;
    }
    if (action.action == 'log_hr') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMetricScreen(
            userId: userId,
            initialMetricType: MetricType.heartRate,
          ),
        ),
      ).then((result) {
        if (result == true) {
          _isLoadingData = false;
          _lastLoadedUserId = null;
          _loadDashboardData();
        }
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMetricScreen(userId: userId),
      ),
    ).then((result) {
      if (result == true) {
        _isLoadingData = false;
        _lastLoadedUserId = null;
        _loadDashboardData();
      }
    });
  }

  void _showNotificationsSheet(BuildContext context, String userId) {
    final state = context.read<DashboardBloc>().state;
    final List<AbnormalMetrices> alerts =
        state is DashboardLoaded ? state.abnormalMetrics : [];
    final bool hasDaily =
        state is DashboardLoaded && state.todayHealthDaily != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.obsidianCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.obsidianBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.notifications_active_rounded,
                            color: AppTheme.cyberCyan,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'CLINICAL ALERTS & NOTIFICATIONS',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.cyberCyan,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      if (alerts.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.neonRed.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.neonRed.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            '${alerts.length} ALERTS',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.neonRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (alerts.isNotEmpty) ...[
                    const Text(
                      'BIOMETRIC FLAGS REQUIRING ATTENTION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...alerts.map((alert) {
                      final sevColor = _getSeverityColor(alert.alertSevirity);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: sevColor.withOpacity(0.5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: sevColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert.alertmessage,
                                    style: TextStyle(
                                      color: sevColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_getMetricLabel(alert.metric.type)}: ${alert.metric.displayValue} ${alert.metric.unit}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (alert.recommendation != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      alert.recommendation!,
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                context.push(
                                  '/metric-detail',
                                  extra: {
                                    'userId': userId,
                                    'metricType': alert.metric.type,
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.cyberCyan,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text(
                                'INVESTIGATE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.bioEmerald.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppTheme.bioEmerald,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ALL BIOMARKERS NOMINAL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'No abnormal clinical flags or biomarker alerts detected in active telemetry.',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'INTEGRATION & SCREENING SCHEDULE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          color: hasDaily
                              ? AppTheme.bioEmerald
                              : AppTheme.cyberCyan,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasDaily
                                    ? 'WEARABLE TELEMETRY SYNCED'
                                    : 'WEARABLE SYNC PENDING',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasDaily
                                    ? 'Daily step, heart rate, and sleep biometrics active'
                                    : 'Connect Google Fit or Fitbit to enable automatic biomarker streaming',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.health_and_safety_rounded,
                          color: AppTheme.cyberCyan,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PREVENTIVE CARE PROTOCOLS ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'USPSTF cardiovascular risk screening & testosterone screening protocols up to date.',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyberCyan,
                      foregroundColor: AppTheme.obsidianBase,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'DISMISS',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getCategoryLabel(HealthCategory category) {
    switch (category) {
      case HealthCategory.activity:
        return 'Activity';
      case HealthCategory.sleep:
        return 'Sleep';
      case HealthCategory.nutrition:
        return 'Nutrition';
      case HealthCategory.screening:
        return 'Screening';
      case HealthCategory.mental:
        return 'Mental Wellness';
      case HealthCategory.cardioVascular:
        return 'Cardiovascular';
      case HealthCategory.metabolic:
        return 'Metabolic';
    }
  }

  String _getMetricLabel(MetricType type) {
    switch (type) {
      case MetricType.bloodPressure:
        return 'Blood Pressure';
      case MetricType.weight:
        return 'Weight';
      case MetricType.glucose:
        return 'Glucose';
      case MetricType.heartRate:
        return 'Heart Rate';
      case MetricType.steps:
        return 'Steps';
      case MetricType.sleep:
        return 'Sleep';
      case MetricType.calories:
        return 'Calories';
      case MetricType.hydration:
        return 'Hydration';
      case MetricType.oxygenSaturation:
        return 'Oxygen Saturation';
      case MetricType.temperature:
        return 'Temperature';
    }
  }

  Color _getSeverityColor(AlertSevirity severity) {
    switch (severity) {
      case AlertSevirity.info:
        return Colors.blue;
      case AlertSevirity.low:
        return Colors.green;
      case AlertSevirity.medium:
        return Colors.orange;
      case AlertSevirity.high:
        return Colors.red.shade400;
      case AlertSevirity.critical:
        return Colors.red.shade900;
    }
  }

  Widget _getScoreIndicator(int score) {
    Color color;
    if (score >= 80) {
      color = Colors.green;
    } else if (score >= 70) {
      color = Colors.green.shade300;
    } else if (score >= 50) {
      color = Colors.orange;
    } else if (score >= 30) {
      color = Colors.red.shade400;
    } else {
      color = Colors.red.shade900;
    }

    return CircleAvatar(
      radius: 12,
      backgroundColor: color,
      child: Text(
        score >= 70 ? '✓' : '!',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

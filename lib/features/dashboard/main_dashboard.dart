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
import '../../../core/bloc/health_sync/health_sync_state.dart';
import '../../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../../core/bloc/onboarding/onboarding_state.dart';
import '../../../core/models/health_enums.dart';
import '../../../core/theme/app_theme.dart';

class UnifiedDashboardScreen extends StatefulWidget {
  final String userId;

  const UnifiedDashboardScreen({
    super.key,
    required this.userId,
  });

  static void resetState() {
    _UnifiedDashboardScreenState.resetState();
  }

  @override
  State<UnifiedDashboardScreen> createState() => _UnifiedDashboardScreenState();
}

class _UnifiedDashboardScreenState extends State<UnifiedDashboardScreen> {
  static bool _isLoading = true;
  static bool _isInitialLoad = true;
  static bool _isLoadingData = false;
  static String? _lastLoadedUserId;
  static DateTime? _lastLoadTime;
  
  static const Duration _minLoadInterval = Duration(milliseconds: 500);

  static void resetState() {
    _isLoading = true;
    _isInitialLoad = true;
    _isLoadingData = false;
    _lastLoadedUserId = null;
    _lastLoadTime = null;
    debugPrint('🔄 Dashboard state reset');
  }

  @override
  void initState() {
    super.initState();
    _isInitialLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void didUpdateWidget(UnifiedDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId && widget.userId.isNotEmpty) {
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
      debugPrint(' No userId available, skipping load');
      if (_isInitialLoad) {
        setState(() {
          _isLoading = false;
          _isInitialLoad = false;
        });
      }
      return;
    }

    final now = DateTime.now();
    if (_lastLoadedUserId == userId && 
        _lastLoadTime != null && 
        now.difference(_lastLoadTime!) < _minLoadInterval) {
      debugPrint('⏭️ Skipping duplicate load for user: $userId (too soon)');
      return;
    }

    _isLoadingData = true;
    _lastLoadedUserId = userId;
    _lastLoadTime = now;
    
    if (_isInitialLoad) {
      setState(() {
        _isLoading = true;
      });
    }

    debugPrint(' Loading dashboard for userId: $userId');
    
    context.read<DashboardBloc>().add(
      LoadDashboardData(userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final onboardingState = context.watch<OnboardingBloc>().state;
    final healthSyncState = context.watch<HealthSyncBloc>().state;
    final dashboardState = context.watch<DashboardBloc>().state;

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
    final greeting = hour < 12 ? 'Good Morning' :
        hour < 17 ? 'Good Afternoon' :
        'Good Evening';

    if (authState is! Authenticated) {
      if (_isLoading || _isLoadingData) {
        _isLoading = false;
        _isLoadingData = false;
      }
      
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: _buildAppBar(context, userName, userEmail),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Please log in to view your dashboard',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(context, userName, userEmail),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded || state is DashboardError) {
            _isLoadingData = false;
            if (_isInitialLoad) {
              setState(() {
                _isLoading = false;
                _isInitialLoad = false;
              });
            }
          }
          
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is SyncComplete) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.healthyGreen,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_isLoading || state is DashboardLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading your health dashboard...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.dangerRed,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error Loading Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _isLoading = true;
                        _isInitialLoad = true;
                        _isLoadingData = false;
                        _loadDashboardData();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DashboardLoaded) {
            if (_isInitialLoad) {
              _isInitialLoad = false;
              _isLoading = false;
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                _isLoadingData = false;
                _loadDashboardData();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section
                    Text(
                      '$greeting,',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Health Score Card
                    HealthScoreCard(
                      healthScore: state.healthScore,
                      onTap: () {
                        _showScoreDetails(context, state.healthScore);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Today's Focus Card
                    TodayFocusCard(
                      focus: state.todayFocus,
                      onActionTap: (action) {
                        _handleFocusAction(context, action);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quick Stats Row
                    _buildQuickStatsRow(context, onboardingState),
                    const SizedBox(height: 20),

                    // Abnormal Alerts
                    if (state.abnormalMetrics.isNotEmpty)
                      AbnormalAlerts(
                        alerts: state.abnormalMetrics,
                        onAlertTap: (alert) {
                          _showAlertDetails(context, alert, userId);
                        },
                      ),
                    const SizedBox(height: 16),

                    // ✅ FIXED: Mood Insights Card with null safety
                    _buildMoodInsightsCard(context, state.moodTrends),
                    const SizedBox(height: 16),

                    // Health Integrations
                    _buildHealthIntegrations(context, healthSyncState),
                    const SizedBox(height: 24),

                    // Quick Metric Entry
                    QuickMetricEntry(
                      userId: userId,
                      onMetricAdded: () {
                        _loadDashboardData();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Metrics Grid
                    MetricsGrid(
                      metrics: state.recentMetrics,
                      onMetricTap: (type) {
                        context.go(
                          '/metric-detail',
                          extra: {
                            'userId': userId,
                            'metricType': type,
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Metric Chart
                    MetricChart(
                      metrics: state.allMetrics,
                      selectedPeriod: state.trendDepressed,
                      onPeriodChanged: (period) {
                        context.read<DashboardBloc>().add(
                          SelectTimeRange(trendDepressed: period)
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Lifestyle & Stress Card
                    _buildLifestyleCard(context, onboardingState),
                    const SizedBox(height: 12),

                    // Medications Card
                    _buildMedicationsCard(context, onboardingState),
                    const SizedBox(height: 12),

                    // Emergency Contact Card
                    if (onboardingState.emergencyContact != null)
                      _buildEmergencyContactCard(context, onboardingState),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMetricScreen(userId: userId),
            ),
          ).then((result) {
            if (result == true) {
              debugPrint('🔄 Metric added, refreshing dashboard...');
              _isLoadingData = false;
              _lastLoadedUserId = null;
              _loadDashboardData();
            }
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Health Metric',
      ),
    );
  }

  // ============= App Bar =============
  AppBar _buildAppBar(BuildContext context, String userName, String userEmail) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4F46E5).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF4F46E5),
              radius: 22,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
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
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
          onSelected: (value) {
            if (value == 'logout') {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              context.go('/');
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============= Helper Widgets =============

  // ✅ FIXED: Mood Insights Card with null safety
  Widget _buildMoodInsightsCard(BuildContext context, Map<String, dynamic>? moodTrends) {
    // Handle null or empty case
    if (moodTrends == null || moodTrends.isEmpty) {
      return const SizedBox.shrink();
    }

    // Safely extract values with defaults
    final trend = moodTrends['trend'] as String? ?? 'stable';
    final average = moodTrends['average'] as double? ?? 0.0;
    final riskLevel = moodTrends['riskLevel'] as String? ?? 'low';
    final insights = moodTrends['insights'] as List<String>? ?? [];

    Color trendColor;
    String trendIcon;
    if (trend == 'improving') {
      trendColor = AppTheme.healthyGreen;
      trendIcon = '📈';
    } else if (trend == 'declining') {
      trendColor = AppTheme.dangerRed;
      trendIcon = '📉';
    } else {
      trendColor = AppTheme.warningOrange;
      trendIcon = '➡️';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Color(0xFF7C3AED),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mood Insights',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Average: ${average.toStringAsFixed(1)}/10',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMedium,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: riskLevel == 'high' 
                                  ? Colors.red.shade100 
                                  : riskLevel == 'moderate'
                                      ? Colors.orange.shade100
                                      : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              riskLevel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: riskLevel == 'high'
                                    ? Colors.red
                                    : riskLevel == 'moderate'
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '$trendIcon Trend: ${trend.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: trendColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (insights.isNotEmpty)
              ...insights.map((insight) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          insight,
                          style: TextStyle(
                            fontSize: 13,
                            color: insight.contains('⚠️') 
                                ? Colors.red 
                                : AppTheme.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  context.go('/mood-history?userId=${widget.userId}');
                },
                icon: const Icon(Icons.mood, size: 16),
                label: const Text('View Mood History'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow(BuildContext context, OnboardingState state) {
    final lifeStage = state.detectedLifeStage;
    
    return Row(
      children: [
        _buildQuickStat(
          context,
          icon: Icons.calendar_today_rounded,
          value: lifeStage.name,
          label: 'Life Stage',
          color: lifeStage.badgeColor,
        ),
        const SizedBox(width: 12),
        _buildQuickStat(
          context,
          icon: Icons.fitness_center_rounded,
          value: state.lifestyle.exercise.name,
          label: 'Exercise',
          color: const Color(0xFF0D9488),
        ),
        const SizedBox(width: 12),
        _buildQuickStat(
          context,
          icon: Icons.medication_rounded,
          value: state.medications.length.toString(),
          label: 'Medications',
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIntegrations(BuildContext context, HealthSyncState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Health Integrations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                _loadDashboardData();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4F46E5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHealthSourceCard(
                title: 'Apple Health',
                icon: Icons.apple_rounded,
                isConnected: state.isAppleHealthAuthorized,
                lastSync: state.appleHealthLastSync,
                isLoading: state.isLoading,
                onConnect: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthSourceCard(
                title: 'Google Fit',
                icon: Icons.fitness_center_rounded,
                isConnected: state.isGoogleFitAuthorized,
                lastSync: state.googleFitLastSync,
                isLoading: state.isLoading,
                onConnect: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthSourceCard({
    required String title,
    required IconData icon,
    required bool isConnected,
    required DateTime? lastSync,
    required bool isLoading,
    required VoidCallback onConnect,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
          width: isConnected ? 2 : 1,
        ),
        boxShadow: [
          if (isConnected)
            BoxShadow(
              color: const Color(0xFF0D9488).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isConnected 
                      ? const Color(0xFF0D9488).withOpacity(0.1) 
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon, 
                  color: isConnected ? const Color(0xFF0D9488) : const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4F46E5),
                  ),
                )
              else
                Icon(
                  isConnected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isConnected ? const Color(0xFF0D9488) : const Color(0xFF94A3B8),
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isConnected && lastSync != null
                ? 'Last sync: ${DateFormat('MMM d, hh:mm a').format(lastSync)}'
                : 'Not Connected',
            style: TextStyle(
              fontSize: 11,
              color: isConnected ? const Color(0xFF0D9488) : const Color(0xFF64748B),
              fontWeight: isConnected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isConnected ? null : onConnect,
              style: TextButton.styleFrom(
                backgroundColor: isConnected 
                    ? const Color(0xFF0D9488).withOpacity(0.05) 
                    : const Color(0xFF4F46E5).withOpacity(0.1),
                foregroundColor: isConnected ? const Color(0xFF0D9488) : const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isConnected ? 'Connected' : 'Connect',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleCard(BuildContext context, OnboardingState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded, 
                    color: Color(0xFF4F46E5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lifestyle & Stress',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Stress Level: ${state.lifestyle.stressLevel}/10',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStressIndicator(state.lifestyle.stressLevel),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getExerciseIcon(state.lifestyle.exercise.name),
                    size: 16,
                    color: const Color(0xFF475569),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Exercise: ${state.lifestyle.exercise.name}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsCard(BuildContext context, OnboardingState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE6FFFA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.medication_rounded, 
            color: Color(0xFF0D9488),
          ),
        ),
        title: const Text(
          'Tracked Medications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          state.medications.isEmpty
              ? 'No active medications registered'
              : '${state.medications.length} medications tracked',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        trailing: state.medications.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${state.medications.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              )
            : null,
        onTap: () {},
      ),
    );
  }

  Widget _buildEmergencyContactCard(BuildContext context, OnboardingState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.contact_phone_rounded, 
            color: Colors.redAccent,
          ),
        ),
        title: Text(
          'Emergency Contact: ${state.emergencyContact?.name ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${state.emergencyContact?.relationship ?? ''} • ${state.emergencyContact?.phoneNumber ?? ''}',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone_forwarded_rounded, color: Colors.redAccent),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildStressIndicator(int stressLevel) {
    Color color;
    if (stressLevel <= 3) {
      color = const Color(0xFF0D9488);
    } else if (stressLevel <= 6) {
      color = const Color(0xFFFF9800);
    } else {
      color = const Color(0xFFF44336);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$stressLevel/10',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ============= Helper Methods =============

  void _showScoreDetails(BuildContext context, HealthScore score) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Health Score Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...score.categoryScores.entries.map((entry) {
                return ListTile(
                  title: Text(_getCategoryLabel(entry.key)),
                  trailing: Text('${entry.value}/100'),
                  leading: _getScoreIndicator(entry.value),
                );
              }).toList(),
              const Divider(),
              ListTile(
                title: const Text(
                  'Total Score',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '${score.score}/100',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Recommendations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...score.recommendations.map((rec) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.sailing, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(rec)),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAlertDetails(BuildContext context, AbnormalMetrices alert, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${_getMetricLabel(alert.metric.type)} Alert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.alertmessage,
                style: TextStyle(
                  color: _getSeverityColor(alert.alertSevirity),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Value: ${alert.metric.displayValue} ${alert.metric.unit}'),
              const SizedBox(height: 8),
              Text('Time: ${_formatDate(alert.metric.timeStamp)}'),
              if (alert.recommendation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Recommendation: ${alert.recommendation}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(
                  '/metric-detail',
                  extra: {
                    'userId': userId,
                    'metricType': alert.metric.type,
                  },
                );
              },
              child: const Text('View Details'),
            ),
          ],
        );
      },
    );
  }

  void _handleFocusAction(BuildContext context, FocusAction action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action: ${action.label}'),
        duration: const Duration(seconds: 2),
      ),
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
    if (score >= 80) color = Colors.green;
    else if (score >= 70) color = Colors.green.shade300;
    else if (score >= 50) color = Colors.orange;
    else if (score >= 30) color = Colors.red.shade400;
    else color = Colors.red.shade900;

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

  IconData _getExerciseIcon(String exercise) {
    switch (exercise.toLowerCase()) {
      case 'running':
        return Icons.directions_run_rounded;
      case 'cycling':
        return Icons.directions_bike_rounded;
      case 'swimming':
        return Icons.pool_rounded;
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'yoga':
        return Icons.self_improvement_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }
}
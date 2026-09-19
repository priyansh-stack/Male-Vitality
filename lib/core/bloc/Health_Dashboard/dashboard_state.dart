part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

enum HealthDailyLoadStatus {
  initial,
  loading,
  loaded,
  noData,
  unauthenticated,
  error,
}

class DashboardLoaded extends DashboardState {
  final HealthScore healthScore;
  final List<HealthMetric> recentMetrics;
  final Map<MetricType, List<HealthMetric>> metricsTrend;
  final TodayFocus todayFocus;
  final List<AbnormalMetrices> abnormalMetrics;
  final List<HealthMetric> allMetrics;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final Set<MetricType> visibleMetrics;
  final TrendDepressed trendDepressed;
  final Map<String, dynamic> moodTrends;
  final HealthDaily? todayHealthDaily;
  final List<HealthDaily> recentHealthDailies;
  final HealthDailyLoadStatus healthDailyStatus;
  final String? healthDailyErrorMessage;

  const DashboardLoaded({
    required this.healthScore,
    required this.recentMetrics,
    required this.metricsTrend,
    required this.todayFocus,
    required this.abnormalMetrics,
    required this.allMetrics,
    this.isSyncing = false,
    this.lastSyncTime,
    this.visibleMetrics = const {},
    this.trendDepressed = TrendDepressed.thirtyDays,
    this.moodTrends = const {},
    this.todayHealthDaily,
    this.recentHealthDailies = const [],
    this.healthDailyStatus = HealthDailyLoadStatus.initial,
    this.healthDailyErrorMessage,
  });

  DashboardLoaded copyWith({
    HealthScore? healthScore,
    List<HealthMetric>? recentMetrics,
    Map<MetricType, List<HealthMetric>>? metricsTrend,
    TodayFocus? todayFocus,
    List<AbnormalMetrices>? abnormalMetrics,
    List<HealthMetric>? allMetrics,
    bool? isSyncing,
    DateTime? lastSyncTime,
    Set<MetricType>? visibleMetrics,
    TrendDepressed? trendDepressed,
    Map<String, dynamic>? moodTrends,
    HealthDaily? todayHealthDaily,
    bool clearTodayDaily = false,
    List<HealthDaily>? recentHealthDailies,
    HealthDailyLoadStatus? healthDailyStatus,
    String? healthDailyErrorMessage,
  }) {
    return DashboardLoaded(
      healthScore: healthScore ?? this.healthScore,
      recentMetrics: recentMetrics ?? this.recentMetrics,
      metricsTrend: metricsTrend ?? this.metricsTrend,
      todayFocus: todayFocus ?? this.todayFocus,
      abnormalMetrics: abnormalMetrics ?? this.abnormalMetrics,
      allMetrics: allMetrics ?? this.allMetrics,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      visibleMetrics: visibleMetrics ?? this.visibleMetrics,
      trendDepressed: trendDepressed ?? this.trendDepressed,
      moodTrends: moodTrends ?? this.moodTrends,
      todayHealthDaily: clearTodayDaily
          ? null
          : (todayHealthDaily ?? this.todayHealthDaily),
      recentHealthDailies: recentHealthDailies ?? this.recentHealthDailies,
      healthDailyStatus: healthDailyStatus ?? this.healthDailyStatus,
      healthDailyErrorMessage:
          healthDailyErrorMessage ?? this.healthDailyErrorMessage,
    );
  }

  @override
  List<Object> get props => [
    healthScore,
    recentMetrics,
    metricsTrend,
    todayFocus,
    abnormalMetrics,
    allMetrics,
    isSyncing,
    lastSyncTime ?? DateTime(0),
    visibleMetrics,
    trendDepressed,
    moodTrends,
    todayHealthDaily ?? '',
    recentHealthDailies,
    healthDailyStatus,
    healthDailyErrorMessage ?? '',
  ];
}

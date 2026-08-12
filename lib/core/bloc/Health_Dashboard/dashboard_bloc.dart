import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:life_stage_health_app/core/bloc/Health_Dashboard/support_states.dart';
import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';
import 'package:life_stage_health_app/core/services/weareable_service.dart';
import '../../models/health_metric.dart';
import '../../models/health_score.dart';
import '../../models/health_enums.dart';
import '../../services/database_service.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DatabaseService databaseService;
  final WearableService wearableService;

  DashboardBloc({
    required this.databaseService,
    required this.wearableService,
  }) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<LoadMetricTrend>(_onLoadMetricTrend);
    on<AddHealthMetricEvent>(_onAddHealthMetric);
    on<SyncWearableDataEvent>(_onSyncWearableData);
    on<UpdateTodayFocus>(_onUpdateTodayFocus);
    on<GenerateHealthSummary>(_onGenerateHealthSummary);
    on<ToggleMetricVisibility>(_onToggleMetricVisibility);
    on<SelectTimeRange>(_onSelectTimeRange);
  }

  Future<void> _onLoadDashboardData(
  LoadDashboardData event,
  Emitter<DashboardState> emit,
) async {
  if (event.userId.isEmpty) {
    emit(const DashboardError(
      message: 'User ID cannot be empty. Please log in again.',
    ));
    return;
  }

  try {
    emit(const DashboardLoading(message: 'Loading your health data...'));

    final results = await Future.wait([
      databaseService.calculateHealthScore(event.userId),
      databaseService.getRecentMetrics(event.userId, days: 7),
      _loadAllMetricsTrend(event.userId),
      databaseService.getTodayFocus(event.userId),
      databaseService.getAbnormalMetrics(event.userId),
      databaseService.getAllMetrics(event.userId),
      databaseService.getUserVisibleMetrics(event.userId),
      databaseService.analyzeMoodTrends(event.userId), 
    ]);

    final healthScore = results[0] as HealthScore;
    final recentMetrics = results[1] as List<HealthMetric>;
    final metricsTrend = results[2] as Map<MetricType, List<HealthMetric>>;
    final todayFocus = results[3] as TodayFocus;
    final abnormalMetrics = results[4] as List<AbnormalMetrices>;
    final allMetrics = results[5] as List<HealthMetric>;
    final visibleMetrics = results[6] as Set<MetricType>;
    final moodTrends = results[7] as Map<String, dynamic>;

    emit(DashboardLoaded(
      healthScore: healthScore,
      recentMetrics: recentMetrics,
      metricsTrend: metricsTrend,
      todayFocus: todayFocus,
      abnormalMetrics: abnormalMetrics,
      allMetrics: allMetrics,
      isSyncing: false,
      lastSyncTime: DateTime.now(),
      visibleMetrics: visibleMetrics.isEmpty
          ? MetricType.values.toSet()
          : visibleMetrics,
      trendDepressed: TrendDepressed.thirtyDays,
      moodTrends: moodTrends,
    ));
  } catch (e) {
    emit(DashboardError(
      message: 'Failed to load dashboard: $e',
      exception: e is Exception ? e : null,
    ));
  }
}
  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(const DashboardError(
        message: 'User ID cannot be empty. Please log in again.',
      ));
      return;
    }
    add(LoadDashboardData(userId: event.userId));
  }

  Future<void> _onLoadMetricTrend(
    LoadMetricTrend event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(const DashboardError(
        message: 'User ID cannot be empty. Please log in again.',
      ));
      return;
    }
    
    try {
      final metrics = await databaseService.getMetricTrend(
        userId: event.userId,
        metricType: event.metricType,
        depressed: event.trendDepressed,
      );

      emit(MetricTrendLoaded(
        metrics: metrics,
        metricType: event.metricType,
        trendDepressed: event.trendDepressed,
      ));
    } catch (e) {
      emit(DashboardError(
        message: 'Failed to load metric trend: $e',
        exception: e is Exception ? e : null,
      ));
    }
  }

  Future<void> _onAddHealthMetric(
    AddHealthMetricEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.metric.userId.isEmpty) {
      emit(const DashboardError(
        message: 'User ID cannot be empty. Please log in again.',
      ));
      return;
    }
    
    try {
      await databaseService.saveHealthMetric(event.metric);

      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        add(LoadDashboardData(userId: event.metric.userId));
      }

      emit(MetricAdded(event.metric));
    } catch (e) {
      emit(DashboardError(
        message: 'Failed to add metric: $e',
        exception: e is Exception ? e : null,
      ));
    }
  }

  Future<void> _onSyncWearableData(
    SyncWearableDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(const DashboardError(
        message: 'User ID cannot be empty. Please log in again.',
      ));
      return;
    }
    
    try {
      emit(SyncInProgress(
        wearableType: event.wearableType,
        progress: 0.0,
        status: 'Initializing sync...',
      ));

      await for (final progress in wearableService.syncData(
        event.userId,
        event.wearableType,
      )) {
        emit(SyncInProgress(
          wearableType: event.wearableType,
          progress: progress.progress,
          status: progress.status,
        ));
      }

      final result = await wearableService.getSyncResult(
        event.userId,
        event.wearableType,
      );

      emit(SyncComplete(
        syncedCount: result.count,
        message: 'Successfully synced ${result.count} metrics from ${event.wearableType.displayname}',
      ));

      add(LoadDashboardData(userId: event.userId));
    } catch (e) {
      emit(DashboardError(
        message: 'Failed to sync wearable data: $e',
        exception: e is Exception ? e : null,
      ));
    }
  }

  Future<void> _onUpdateTodayFocus(
    UpdateTodayFocus event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(const DashboardError(
        message: 'User ID cannot be empty. Please log in again.',
      ));
      return;
    }
    
    try {
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        final newFocus = await databaseService.getTodayFocus(event.userId);
        emit(currentState.copyWith(todayFocus: newFocus));
      }
    } catch (e) {
      emit(DashboardError(
        message: 'Failed to update focus: $e',
        exception: e is Exception ? e : null,
      ));
    }
  }

  Future<void> _onGenerateHealthSummary(
    GenerateHealthSummary event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(const DashboardError(
        message: 'User ID cannot be empty. Please log in again.',
      ));
      return;
    }
    
    try {
      emit(const DashboardLoading(message: 'Generating health summary...'));

      final result = await databaseService.generateHealthSummary(
        userId: event.userId,
        startDate: event.startTime,
        endDate: event.endDate,
      );

      emit(SummaryGenerated(
        pdfPath: result.pdfPath,
        summary: result.summary,
      ));
    } catch (e) {
      emit(DashboardError(
        message: 'Failed to generate summary: $e',
        exception: e is Exception ? e : null,
      ));
    }
  }

  Future<void> _onToggleMetricVisibility(
    ToggleMetricVisibility event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      final updatedVisible = Set<MetricType>.from(currentState.visibleMetrics);

      if (updatedVisible.contains(event.metricType)) {
        updatedVisible.remove(event.metricType);
      } else {
        updatedVisible.add(event.metricType);
      }

      await databaseService.saveUserVisibleMetrics(
        currentState.healthScore.userId!,
        updatedVisible,
      );

      emit(currentState.copyWith(visibleMetrics: updatedVisible));
    }
  }

  Future<void> _onSelectTimeRange(
    SelectTimeRange event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(trendDepressed: event.trendDepressed));

      if (currentState.healthScore.userId != null) {
        for (final metricType in currentState.visibleMetrics) {
          add(LoadMetricTrend(
            userId: currentState.healthScore.userId!,
            metricType: metricType,
            trendDepressed: event.trendDepressed,
          ));
        }
      }
    }
  }

  Future<Map<MetricType, List<HealthMetric>>> _loadAllMetricsTrend(String userId) async {
    final result = <MetricType, List<HealthMetric>>{};
    
    for (final type in MetricType.values) {
      result[type] = [];
    }
    
    try {
      final recentMetrics = await databaseService.getRecentMetrics(userId, days: 30);
      
      for (final metric in recentMetrics) {
        result[metric.type]?.add(metric);
      }
    } catch (e) {
      debugPrint('Failed to load metric trends: $e');
    }
    
    return result;
  }
}
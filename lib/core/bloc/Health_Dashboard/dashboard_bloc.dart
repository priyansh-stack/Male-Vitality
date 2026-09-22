import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'support_states.dart';
import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';
import 'package:life_stage_health_app/core/services/weareable_service.dart';
import '../../models/health_metric.dart';
import '../../models/health_score.dart';
import '../../models/health_enums.dart';
import '../../models/health_daily.dart';
import '../../models/mental_wellness/mood_entry.dart';
import '../../services/database_service.dart';
import '../../services/clinical_engine.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DatabaseService databaseService;
  final WearableService wearableService;
  StreamSubscription<HealthDaily?>? _todayDailySubscription;

  DashboardBloc({required this.databaseService, required this.wearableService})
    : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<LoadMetricTrend>(_onLoadMetricTrend);
    on<AddHealthMetricEvent>(_onAddHealthMetric);
    on<SyncWearableDataEvent>(_onSyncWearableData);
    on<UpdateTodayFocus>(_onUpdateTodayFocus);
    on<GenerateHealthSummary>(_onGenerateHealthSummary);
    on<ToggleMetricVisibility>(_onToggleMetricVisibility);
    on<SelectTimeRange>(_onSelectTimeRange);
    on<ClearDashboardData>(_onClearDashboardData);
    on<HealthDailyUpdated>(_onHealthDailyUpdated);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(
        const DashboardError(
          message: 'User ID cannot be empty. Please log in again.',
        ),
      );
      return;
    }

    try {
      emit(const DashboardLoading(message: 'Loading your health data...'));

      // CONSOLIDATED QUERY STRATEGY:
      // Only 3 primary queries instead of 8 parallel overlapping queries:
      // 1. 30-day health metrics
      // 2. 14-day mood entries
      // 3. User visible metrics
      final results = await Future.wait([
        databaseService.getRecentMetrics(event.userId, days: 30),
        databaseService.firestoreService.getMoodEntries(event.userId, days: 14),
        databaseService.getUserVisibleMetrics(event.userId),
        databaseService.getTodayHealthDaily(event.userId),
        databaseService.getRecentHealthDailies(event.userId, limit: 7),
      ]);

      final all30dMetrics = results[0] as List<HealthMetric>;
      final mood14dEntries = results[1] as List<MoodEntry>;
      final visibleMetrics = results[2] as Set<MetricType>;
      final todayHealthDaily = results[3] as HealthDaily?;
      final recentHealthDailies = results[4] as List<HealthDaily>;

      final healthDailyStatus = todayHealthDaily != null
          ? HealthDailyLoadStatus.loaded
          : HealthDailyLoadStatus.noData;

      // Setup real-time listener for today's healthDaily document
      _todayDailySubscription?.cancel();
      _todayDailySubscription = databaseService
          .watchTodayHealthDaily(event.userId)
          .listen(
            (daily) {
              add(HealthDailyUpdated(todayDaily: daily));
            },
            onError: (e) {
              debugPrint('Error listening to todayHealthDaily: $e');
            },
          );

      // In-memory time filters (0 additional Firestore reads)
      final now = DateTime.now();
      final oneDayAgo = now.subtract(const Duration(days: 1));
      final twoDaysAgo = now.subtract(const Duration(days: 2));
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final todayMetrics = all30dMetrics
          .where((m) => m.timeStamp.isAfter(oneDayAgo))
          .toList();
      final recent2dMetrics = all30dMetrics
          .where((m) => m.timeStamp.isAfter(twoDaysAgo))
          .toList();
      final recent7dMetrics = all30dMetrics
          .where((m) => m.timeStamp.isAfter(sevenDaysAgo))
          .toList();

      final todayMood = mood14dEntries
          .where((m) => m.timestamp.isAfter(oneDayAgo))
          .toList();
      final mood7d = mood14dEntries
          .where((m) => m.timestamp.isAfter(sevenDaysAgo))
          .toList();

      // In-memory ClinicalEngine calculations (0 additional Firestore reads)
      final healthScore = ClinicalEngine.calculateHealthScore(
        metrics: all30dMetrics,
        moodEntries: mood7d,
      );

      final todayFocus = ClinicalEngine.getTodayFocus(
        metrics: todayMetrics,
        moodEntries: todayMood,
      );

      final abnormalMetrics = ClinicalEngine.scanForAbnormalities(
        recent2dMetrics,
      );
      final moodTrends = ClinicalEngine.analyzeMoodTrends(mood14dEntries);

      final metricsTrend = <MetricType, List<HealthMetric>>{};
      for (final type in MetricType.values) {
        metricsTrend[type] = [];
      }
      for (final m in all30dMetrics) {
        metricsTrend[m.type]?.add(m);
      }

      emit(
        DashboardLoaded(
          healthScore: healthScore,
          recentMetrics: recent7dMetrics,
          metricsTrend: metricsTrend,
          todayFocus: todayFocus,
          abnormalMetrics: abnormalMetrics,
          allMetrics: all30dMetrics,
          isSyncing: false,
          lastSyncTime: DateTime.now(),
          visibleMetrics: visibleMetrics.isEmpty
              ? MetricType.values.toSet()
              : visibleMetrics,
          trendDepressed: TrendDepressed.thirtyDays,
          moodTrends: moodTrends,
          todayHealthDaily: todayHealthDaily,
          recentHealthDailies: recentHealthDailies,
          healthDailyStatus: healthDailyStatus,
        ),
      );
    } catch (e) {
      emit(
        DashboardError(
          message: 'Failed to load dashboard: $e',
          exception: e is Exception ? e : null,
        ),
      );
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(
        const DashboardError(
          message: 'User ID cannot be empty. Please log in again.',
        ),
      );
      return;
    }
    add(LoadDashboardData(userId: event.userId));
  }

  Future<void> _onLoadMetricTrend(
    LoadMetricTrend event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(
        const DashboardError(
          message: 'User ID cannot be empty. Please log in again.',
        ),
      );
      return;
    }

    try {
      final metrics = await databaseService.getMetricTrend(
        userId: event.userId,
        metricType: event.metricType,
        depressed: event.trendDepressed,
      );

      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        final updatedTrends = Map<MetricType, List<HealthMetric>>.from(currentState.metricsTrend);
        updatedTrends[event.metricType] = metrics;
        emit(currentState.copyWith(metricsTrend: updatedTrends));
      } else {
        emit(
          MetricTrendLoaded(
            metrics: metrics,
            metricType: event.metricType,
            trendDepressed: event.trendDepressed,
          ),
        );
      }
    } catch (e) {
      emit(
        DashboardError(
          message: 'Failed to load metric trend: $e',
          exception: e is Exception ? e : null,
        ),
      );
    }
  }

  Future<void> _onAddHealthMetric(
    AddHealthMetricEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.metric.userId.isEmpty) {
      emit(
        const DashboardError(
          message: 'User ID cannot be empty. Please log in again.',
        ),
      );
      return;
    }

    try {
      await databaseService.saveHealthMetric(event.metric);

      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        final updatedAll = List<HealthMetric>.from(currentState.allMetrics)..insert(0, event.metric);
        final updatedRecent = List<HealthMetric>.from(currentState.recentMetrics)..insert(0, event.metric);
        emit(currentState.copyWith(allMetrics: updatedAll, recentMetrics: updatedRecent));
      } else {
        emit(MetricAdded(event.metric));
      }
    } catch (e) {
      emit(
        DashboardError(
          message: 'Failed to add metric: $e',
          exception: e is Exception ? e : null,
        ),
      );
    }
  }

  Future<void> _onSyncWearableData(
    SyncWearableDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(
        const DashboardError(
          message: 'User ID cannot be empty. Please log in again.',
        ),
      );
      return;
    }

    try {
      emit(
        SyncInProgress(
          wearableType: event.wearableType,
          progress: 0.0,
          status: 'Initializing sync...',
        ),
      );

      await for (final progress in wearableService.syncData(
        event.userId,
        event.wearableType,
      )) {
        emit(
          SyncInProgress(
            wearableType: event.wearableType,
            progress: progress.progress,
            status: progress.status,
          ),
        );
      }

      final result = await wearableService.getSyncResult(
        event.userId,
        event.wearableType,
      );

      emit(
        SyncComplete(
          syncedCount: result.count,
          message:
              'Successfully synced ${result.count} metrics from ${event.wearableType.displayname}',
        ),
      );

      add(LoadDashboardData(userId: event.userId));
    } catch (e) {
      emit(
        DashboardError(
          message: 'Failed to sync wearable data: $e',
          exception: e is Exception ? e : null,
        ),
      );
    }
  }

  Future<void> _onUpdateTodayFocus(
    UpdateTodayFocus event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(
        const DashboardError(
          message: 'User ID cannot be empty. Please log in again.',
        ),
      );
      return;
    }

    try {
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        final newFocus = await databaseService.getTodayFocus(event.userId);
        emit(currentState.copyWith(todayFocus: newFocus));
      }
    } catch (e) {
      emit(
        DashboardError(
          message: 'Failed to update focus: $e',
          exception: e is Exception ? e : null,
        ),
      );
    }
  }

  Future<void> _onGenerateHealthSummary(
    GenerateHealthSummary event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(
        const DashboardError(
          message: 'User ID cannot be empty. Please log in again.',
        ),
      );
      return;
    }

    try {
      emit(const DashboardLoading(message: 'Generating health summary...'));

      final result = await databaseService.generateHealthSummary(
        userId: event.userId,
        startDate: event.startTime,
        endDate: event.endDate,
      );

      emit(SummaryGenerated(pdfPath: result.pdfPath, summary: result.summary));
    } catch (e) {
      emit(
        DashboardError(
          message: 'Failed to generate summary: $e',
          exception: e is Exception ? e : null,
        ),
      );
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
    }
  }

  void _onHealthDailyUpdated(
    HealthDailyUpdated event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      // Guard against redundant emissions when daily data is unchanged
      if (currentState.todayHealthDaily == event.todayDaily &&
          (event.recentDailies == null ||
              currentState.recentHealthDailies == event.recentDailies)) {
        return;
      }
      emit(
        currentState.copyWith(
          todayHealthDaily: event.todayDaily,
          clearTodayDaily: event.todayDaily == null,
          recentHealthDailies:
              event.recentDailies ?? currentState.recentHealthDailies,
          healthDailyStatus: event.todayDaily != null
              ? HealthDailyLoadStatus.loaded
              : HealthDailyLoadStatus.noData,
        ),
      );
    }
  }

  void _onClearDashboardData(
    ClearDashboardData event,
    Emitter<DashboardState> emit,
  ) {
    _todayDailySubscription?.cancel();
    _todayDailySubscription = null;
    emit(DashboardInitial());
  }

  @override
  Future<void> close() {
    _todayDailySubscription?.cancel();
    return super.close();
  }
}

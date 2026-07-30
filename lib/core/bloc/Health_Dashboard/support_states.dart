import 'package:life_stage_health_app/core/bloc/Health_Dashboard/dashboard_bloc.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_metric.dart';

// For metric Trends classes
class MetricTrendLoaded extends DashboardState {
  final List<HealthMetric> metrics;
  final MetricType metricType;
  final TrendDepressed trendDepressed;

  const MetricTrendLoaded({
    required this.metrics,
    required this.metricType,
    required this.trendDepressed,
  });

  @override
  List<Object> get props => [metrics, metricType,trendDepressed,];
}

class MetricAdded extends DashboardState {
  final HealthMetric metric;

  const MetricAdded(this.metric);

  @override
  List<Object> get props => [metric];
}


// For Syncing Data Classes
class SyncInProgress extends DashboardState {
  final WeareableType wearableType;
  final double progress;
  final String status;

  const SyncInProgress({
    required this.wearableType,
    required this.progress,
    this.status = 'Syncing...',
  });

  // @override
  List<Object> get props => [wearableType, progress, status];
}

class SyncComplete extends DashboardState {
  final int syncedCount;
  final String message;

  const SyncComplete({
    required this.syncedCount,
    required this.message,
  });

  @override
  List<Object> get props => [syncedCount, message];
}

// For Summary Generation
class SummaryGenerated extends DashboardState {
  final String pdfPath;
  final String summary;

  const SummaryGenerated({
    required this.pdfPath,
    required this.summary,
  });

  @override
  List<Object> get props => [pdfPath, summary];
}

// Dashboard error states

class DashboardError extends DashboardState {
  final String message;
  final Exception? exception;

  const DashboardError({
    required this.message,
    this.exception,
  });

  @override
  List<Object> get props => [message, exception ?? ''];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {
  final String? message;

  const DashboardLoading({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

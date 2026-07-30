import 'package:life_stage_health_app/core/models/health_metric.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_bloc/metric_entry_bloc.dart';

class MetricEntrySubmitting extends MetricEntryState {}

class MetricEntrySuccess extends MetricEntryState {
  final HealthMetric metric;

  const MetricEntrySuccess(this.metric);

  @override
  List<Object> get props => [metric];
}

class MetricEntryError extends MetricEntryState {
  final String message;
  final Exception? exception;

  const MetricEntryError({
    required this.message,
    this.exception,
  });

  @override
  List<Object> get props => [message, exception ?? ''];
}
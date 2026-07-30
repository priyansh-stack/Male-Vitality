part of 'metric_entry_bloc.dart';


abstract class MetricEntryEvent extends Equatable {
  const MetricEntryEvent();

  @override
  List<Object> get props => [];
}

class MetricTypeSelected extends MetricEntryEvent {
  final MetricType metricType;

  const MetricTypeSelected(this.metricType);

  @override
  List<Object> get props => [metricType];
}

class MetricValueChanged extends MetricEntryEvent {
  final String value;

  const MetricValueChanged(this.value);

  @override
  List<Object> get props => [value];
}

class MetricUnitChanged extends MetricEntryEvent {
  final String unit;

  const MetricUnitChanged(this.unit);

  @override
  List<Object> get props => [unit];
}

class MetricTimestampChanged extends MetricEntryEvent {
  final DateTime timestamp;

  const MetricTimestampChanged(this.timestamp);

  @override
  List<Object> get props => [timestamp];
}

class MetricNoteChanged extends MetricEntryEvent {
  final String note;

  const MetricNoteChanged(this.note);

  @override
  List<Object> get props => [note];
}

class SubmitMetric extends MetricEntryEvent {
  final String userId;

  const SubmitMetric(this.userId);

  @override
  List<Object> get props => [userId];
}

class ResetMetricForm extends MetricEntryEvent {}
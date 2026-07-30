part of 'metric_entry_bloc.dart';

abstract class MetricEntryState extends Equatable {
  const MetricEntryState();

  @override
  List<Object> get props => [];
}

class MetricEntryInitial extends MetricEntryState {}

class MetricEntryForm extends MetricEntryState {
  final MetricType metricType;
  final String value;
  final String unit;
  final DateTime timestamp;
  final String note;
  final bool isValid;
  final Map<String, String> validationErrors;

  const MetricEntryForm({
    required this.metricType,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.note,
    required this.isValid,
    required this.validationErrors,
  });

  MetricEntryForm copyWith({
    MetricType? metricType,
    String? value,
    String? unit,
    DateTime? timestamp,
    String? note,
    bool? isValid,
    Map<String, String>? validationErrors,
  }) {
    return MetricEntryForm(
      metricType: metricType ?? this.metricType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      isValid: isValid ?? this.isValid,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  List<Object> get props => [
    metricType,
    value,
    unit,
    timestamp,
    note,
    isValid,
    validationErrors,
  ];
}


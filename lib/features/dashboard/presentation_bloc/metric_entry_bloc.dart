import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:life_stage_health_app/core/models/bloodpressure.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_bloc/support_classes.dart';
import 'package:life_stage_health_app/features/dashboard/usecase/add_health_metric.dart';
import '../../../core/models/health_metric.dart';
import '../../../core/models/health_enums.dart';
part 'metric_entry_state.dart';
part 'metric_event_entry.dart';

class MetricEntryBloc extends Bloc<MetricEntryEvent, MetricEntryState> {
  final AddHealthMetric addHealthMetric;

  MetricEntryBloc({required this.addHealthMetric}) : super(MetricEntryInitial()) {
    on<MetricTypeSelected>(_onMetricTypeSelected);
    on<MetricValueChanged>(_onMetricValueChanged);
    on<MetricUnitChanged>(_onMetricUnitChanged);
    on<MetricTimestampChanged>(_onMetricTimestampChanged);
    on<MetricNoteChanged>(_onMetricNoteChanged);
    on<SubmitMetric>(_onSubmitMetric);
    on<ResetMetricForm>(_onResetMetricForm);
  }

  void _onMetricTypeSelected(
    MetricTypeSelected event,
    Emitter<MetricEntryState> emit,
  ) {
    emit(MetricEntryForm(
      metricType: event.metricType,
      value: '',
      unit: _getDefaultUnit(event.metricType),
      timestamp: DateTime.now(),
      note: '',
      isValid: false,
      validationErrors: {},
    ));
  }

  void _onMetricValueChanged(
    MetricValueChanged event,
    Emitter<MetricEntryState> emit,
  ) {
    if (state is MetricEntryForm) {
      final currentState = state as MetricEntryForm;
      final validationResult = _validateValue(
        currentState.metricType,
        event.value,
      );

      emit(currentState.copyWith(
        value: event.value,
        isValid: validationResult.isValid,
        validationErrors: validationResult.errors,
      ));
    }
  }

  void _onMetricUnitChanged(
    MetricUnitChanged event,
    Emitter<MetricEntryState> emit,
  ) {
    if (state is MetricEntryForm) {
      final currentState = state as MetricEntryForm;
      emit(currentState.copyWith(unit: event.unit));
    }
  }

  void _onMetricTimestampChanged(
    MetricTimestampChanged event,
    Emitter<MetricEntryState> emit,
  ) {
    if (state is MetricEntryForm) {
      final currentState = state as MetricEntryForm;
      emit(currentState.copyWith(timestamp: event.timestamp));
    }
  }

  void _onMetricNoteChanged(
    MetricNoteChanged event,
    Emitter<MetricEntryState> emit,
  ) {
    if (state is MetricEntryForm) {
      final currentState = state as MetricEntryForm;
      emit(currentState.copyWith(note: event.note));
    }
  }

  Future<void> _onSubmitMetric(
    SubmitMetric event,
    Emitter<MetricEntryState> emit,
  ) async {
    if (state is! MetricEntryForm) return;

    final currentState = state as MetricEntryForm;
    if (!currentState.isValid) {
      emit(currentState);
      return;
    }

    emit(MetricEntrySubmitting());

    try {
      final metric = _buildMetric(currentState, event.userId);
      await addHealthMetric.execute(metric);
      emit(MetricEntrySuccess(metric));
    } catch (e) {
      emit(MetricEntryError(
        message: 'Failed to save metric: $e',
        exception: e is Exception ? e : null,
      ));
    }
  }

  void _onResetMetricForm(
    ResetMetricForm event,
    Emitter<MetricEntryState> emit,
  ) {
    emit(MetricEntryInitial());
  }

  String _getDefaultUnit(MetricType type) {
    switch (type) {
      case MetricType.bloodPressure:
        return 'mmHg';
      case MetricType.weight:
        return 'kg';
      case MetricType.glucose:
        return 'mg/dL';
      case MetricType.heartRate:
        return 'bpm';
      case MetricType.steps:
        return 'steps';
      case MetricType.sleep:
        return 'hours';
      case MetricType.calories:
        return 'kcal';
      case MetricType.hydration:
        return 'ml';
      case MetricType.oxygenSaturation:
        return '%';
      case MetricType.temperature:
        return '°C';
    }
  }

  ValidationResult _validateValue(MetricType type, String value) {
    if (value.isEmpty) {
      return ValidationResult(
        isValid: false,
        errors: {'value': 'Please enter a value'},
      );
    }

    if (type == MetricType.bloodPressure) {
      final parts = value.split('/');
      if (parts.length != 2) {
        return ValidationResult(
          isValid: false,
          errors: {'value': 'Enter as systolic/diastolic (e.g., 120/80)'},
        );
      }
      try {
        int.parse(parts[0].trim());
        int.parse(parts[1].trim());
      } catch (_) {
        return ValidationResult(
          isValid: false,
          errors: {'value': 'Invalid numbers entered'},
        );
      }
    } else {
      try {
        double.parse(value);
      } catch (_) {
        return ValidationResult(
          isValid: false,
          errors: {'value': 'Please enter a valid number'},
        );
      }
    }

    return ValidationResult(isValid: true, errors: {});
  }

  HealthMetric _buildMetric(MetricEntryForm form, String userId) {
    dynamic value;
    if (form.metricType == MetricType.bloodPressure) {
      final parts = form.value.split('/');
      value = Bloodpressure(
        systolic: int.parse(parts[0].trim()),
        diastolic: int.parse(parts[1].trim()),
      );
    } else {
      value = double.parse(form.value);
    }

    return HealthMetric(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: form.metricType,
      value: value,
      unit: form.unit,
      timeStamp: form.timestamp,
      source: MetricSource.manual,
      note: form.note,
      metaData: {},
    );
  }
}

class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  ValidationResult({required this.isValid, this.errors = const {}});
}
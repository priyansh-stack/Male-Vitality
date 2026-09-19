import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_bloc/metric_entry_bloc.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_bloc/support_classes.dart';
import '../../../core/theme/app_theme.dart';

class QuickMetricEntry extends StatelessWidget {
  final String userId;
  final VoidCallback? onMetricAdded;

  const QuickMetricEntry({
    super.key,
    required this.userId,
    this.onMetricAdded,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MetricEntryBloc, MetricEntryState>(
      listener: (context, state) {
        if (state is MetricEntrySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Health metric logged successfully!'),
              backgroundColor: AppTheme.bioEmerald,
            ),
          );
          onMetricAdded?.call();
          context.read<MetricEntryBloc>().add(ResetMetricForm());
        }
        if (state is MetricEntryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.neonRed,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MetricEntryInitial) {
          return _buildMetricSelector(context);
        }
        if (state is MetricEntryForm) {
          return _buildMetricForm(context, state);
        }
        if (state is MetricEntrySubmitting) {
          return _buildLoadingState();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMetricSelector(BuildContext context) {
    return Container(
      decoration: AppTheme.cyberCardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.add_chart_rounded, color: AppTheme.cyberCyan, size: 18),
              SizedBox(width: 8),
              Text(
                'QUICK HEALTH LOG',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.cyberCyan,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricChip(context, MetricType.bloodPressure, Icons.favorite, 'BP'),
              _buildMetricChip(context, MetricType.weight, Icons.monitor_weight, 'Weight'),
              _buildMetricChip(context, MetricType.glucose, Icons.opacity, 'Glucose'),
              _buildMetricChip(context, MetricType.heartRate, Icons.favorite_border, 'HR'),
              _buildMetricChip(context, MetricType.hydration, Icons.water_drop, 'Water'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(BuildContext context, MetricType type, IconData icon, String label) {
    return InkWell(
      onTap: () {
        context.read<MetricEntryBloc>().add(MetricTypeSelected(type));
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.cyberCyan),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricForm(BuildContext context, MetricEntryForm state) {
    return Container(
      decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.cyberCyan.withOpacity(0.4)),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOG ${_getMetricLabel(state.metricType).toUpperCase()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.cyberCyan,
                  letterSpacing: 1.0,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 20),
                onPressed: () {
                  context.read<MetricEntryBloc>().add(ResetMetricForm());
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Value (${state.unit})',
              labelStyle: const TextStyle(color: AppTheme.textMuted),
              suffixText: state.unit,
              suffixStyle: const TextStyle(color: AppTheme.cyberCyan),
              errorText: state.validationErrors['value'],
              filled: true,
              fillColor: AppTheme.darkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.darkBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.darkBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.cyberCyan, width: 1.5),
              ),
            ),
            keyboardType: state.metricType == MetricType.bloodPressure
                ? TextInputType.text
                : TextInputType.number,
            onChanged: (value) {
              context.read<MetricEntryBloc>().add(MetricValueChanged(value));
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Annotation / Clinical Note',
                    labelStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.darkSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.darkBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.darkBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.cyberCyan, width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<MetricEntryBloc>().add(MetricNoteChanged(value));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded, color: AppTheme.cyberCyan, size: 20),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: state.timestamp,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      context.read<MetricEntryBloc>().add(
                        MetricTimestampChanged(date),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: state.isValid
                  ? () {
                      context.read<MetricEntryBloc>().add(
                        SubmitMetric(userId),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyberCyan,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'SAVE HEALTH LOG',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: AppTheme.cyberCardDecoration(),
      padding: const EdgeInsets.all(28),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.cyberCyan,
            ),
            SizedBox(height: 16),
            Text(
              'Saving health log...',
              style: TextStyle(
                color: AppTheme.cyberCyan,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMetricLabel(MetricType type) {
    switch (type) {
      case MetricType.bloodPressure:
        return 'Blood Pressure';
      case MetricType.weight:
        return 'Weight';
      case MetricType.glucose:
        return 'Blood Glucose';
      case MetricType.heartRate:
        return 'Heart Rate';
      case MetricType.hydration:
        return 'Water Intake';
      default:
        return type.toString();
    }
  }
}
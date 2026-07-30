import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_bloc/metric_entry_bloc.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_bloc/support_classes.dart';

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
              content: Text('Metric added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          onMetricAdded?.call();
          context.read<MetricEntryBloc>().add(ResetMetricForm());
        }
        if (state is MetricEntryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
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
            const Text(
              'Quick Add Metric',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildMetricChip(BuildContext context, MetricType type, IconData icon, String label) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () {
        context.read<MetricEntryBloc>().add(MetricTypeSelected(type));
      },
      backgroundColor: Colors.grey.shade100,
    );
  }

  Widget _buildMetricForm(BuildContext context, MetricEntryForm state) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enter ${_getMetricLabel(state.metricType)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context.read<MetricEntryBloc>().add(ResetMetricForm());
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Value',
                suffixText: state.unit,
                errorText: state.validationErrors['value'],
                border: const OutlineInputBorder(),
              ),
              keyboardType: state.metricType == MetricType.bloodPressure
                  ? TextInputType.text
                  : TextInputType.number,
              onChanged: (value) {
                context.read<MetricEntryBloc>().add(MetricValueChanged(value));
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      context.read<MetricEntryBloc>().add(MetricNoteChanged(value));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
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
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isValid
                    ? () {
                        context.read<MetricEntryBloc>().add(
                          SubmitMetric(userId),
                        );
                      }
                    : null,
                child: const Text('Save Metric'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Saving metric...'),
            ],
          ),
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
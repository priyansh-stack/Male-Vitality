
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_bloc/metric_entry_bloc.dart';
import 'package:life_stage_health_app/features/dashboard/presentation_bloc/support_classes.dart';
import '../../../core/theme/app_theme.dart';

class AddMetricScreen extends StatefulWidget {
  final String userId;

  const AddMetricScreen({super.key, required this.userId});

  @override
  State<AddMetricScreen> createState() => _AddMetricScreenState();
}

class _AddMetricScreenState extends State<AddMetricScreen> {
  // Logic remains identical
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Log Metric', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          BlocBuilder<MetricEntryBloc, MetricEntryState>(
            builder: (context, state) {
              if (state is MetricEntryForm && state.isValid) {
                return TextButton(
                  onPressed: () => context.read<MetricEntryBloc>().add(SubmitMetric(widget.userId)),
                  child: const Text('Save', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 16)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<MetricEntryBloc, MetricEntryState>(
        listener: (context, state) {
          if (state is MetricEntrySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged successfully!'), backgroundColor: AppTheme.healthyGreen));
            Navigator.pop(context, true);
          }
          if (state is MetricEntryError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppTheme.dangerRed));
          }
        },
        builder: (context, state) {
          if (state is MetricEntryInitial) return _buildMetricTypeSelector(context);
          if (state is MetricEntryForm) return _buildMetricForm(context, state);
          if (state is MetricEntrySubmitting) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMetricTypeSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What would you like to log?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          const Text('Select a vital sign or activity metric below.', style: TextStyle(color: AppTheme.textMedium, fontSize: 15)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: MetricType.values.length,
              itemBuilder: (context, index) {
                final type = MetricType.values[index];
                return InkWell(
                  onTap: () => context.read<MetricEntryBloc>().add(MetricTypeSelected(type)),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.surfaceSubtle, shape: BoxShape.circle),
                          child: Icon(_getMetricIcon(type), size: 28, color: AppTheme.primarySlate),
                        ),
                        const SizedBox(height: 12),
                        Text(_getMetricLabel(type), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textDark)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricForm(BuildContext context, MetricEntryForm state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(_getMetricIcon(state.metricType), color: AppTheme.primaryTeal),
              ),
              const SizedBox(width: 16),
              Text('Log ${_getMetricLabel(state.metricType)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: AppTheme.textMuted), onPressed: () => context.read<MetricEntryBloc>().add(ResetMetricForm())),
            ],
          ),
          const SizedBox(height: 32),
          
          TextFormField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Measurement Value',
              suffixText: state.unit,
              errorText: state.validationErrors['value'],
            ),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            keyboardType: state.metricType == MetricType.bloodPressure ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => context.read<MetricEntryBloc>().add(MetricValueChanged(value)),
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            decoration: const InputDecoration(labelText: 'Notes / Context (optional)'),
            onChanged: (value) => context.read<MetricEntryBloc>().add(MetricNoteChanged(value)),
          ),
          const SizedBox(height: 20),
          
          InkWell(
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: state.timestamp, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now());
              if (date != null) context.read<MetricEntryBloc>().add(MetricTimestampChanged(date));
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.surfaceWhite, border: Border.all(color: AppTheme.borderLight), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: AppTheme.textMedium),
                  const SizedBox(width: 16),
                  Text('Date: ${_formatDate(state.timestamp)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textDark)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: state.isValid ? () => context.read<MetricEntryBloc>().add(SubmitMetric(widget.userId)) : null,
              child: const Text('Save to Dashboard', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // (Keep identical icon, label, and format methods from previous implementation)
  IconData _getMetricIcon(MetricType type) {
    switch (type) {
      case MetricType.bloodPressure: return Icons.favorite;
      case MetricType.weight: return Icons.monitor_weight;
      case MetricType.glucose: return Icons.opacity;
      case MetricType.heartRate: return Icons.favorite_border;
      case MetricType.steps: return Icons.directions_run;
      case MetricType.sleep: return Icons.bedtime;
      case MetricType.calories: return Icons.local_fire_department;
      case MetricType.hydration: return Icons.water_drop;
      case MetricType.oxygenSaturation: return Icons.air;
      case MetricType.temperature: return Icons.thermostat;
    }
  }

  String _getMetricLabel(MetricType type) {
    switch (type) {
      case MetricType.bloodPressure: return 'Blood Pressure';
      case MetricType.weight: return 'Weight';
      case MetricType.glucose: return 'Glucose';
      case MetricType.heartRate: return 'Heart Rate';
      case MetricType.steps: return 'Steps';
      case MetricType.sleep: return 'Sleep';
      case MetricType.calories: return 'Calories';
      case MetricType.hydration: return 'Hydration';
      case MetricType.oxygenSaturation: return 'Oxygen';
      case MetricType.temperature: return 'Temperature';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
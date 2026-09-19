
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkCanvas,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface.withValues(alpha: 0.8),
        elevation: 0,
        title: const Text(
          'LOG TELEMETRY',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.2,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          BlocBuilder<MetricEntryBloc, MetricEntryState>(
            builder: (context, state) {
              if (state is MetricEntryForm && state.isValid) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.cyberCyan.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppTheme.cyberCyan),
                      ),
                    ),
                    onPressed: () => context.read<MetricEntryBloc>().add(SubmitMetric(widget.userId)),
                    child: const Text(
                      'COMMIT',
                      style: TextStyle(color: AppTheme.cyberCyan, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.8),
                    ),
                  ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric telemetry synchronized with Firestore!'),
                backgroundColor: AppTheme.bioEmerald,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is MetricEntryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.neonRed),
            );
          }
        },
        builder: (context, state) {
          if (state is MetricEntryInitial) return _buildMetricTypeSelector(context);
          if (state is MetricEntryForm) return _buildMetricForm(context, state);
          if (state is MetricEntrySubmitting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.cyberCyan),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  bool _isFitbitMetric(MetricType type) {
    return type == MetricType.steps ||
        type == MetricType.heartRate ||
        type == MetricType.sleep ||
        type == MetricType.calories;
  }

  Widget _buildMetricTypeSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECT TELEMETRY VECTOR',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.cyberCyan,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select a vital sign, biomarker, or physical activity channel to ingest.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cyberCyan.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.sync_alt, color: AppTheme.cyberCyan, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Wearable metrics (Steps, HR, Sleep, Calories) sync automatically via the Fitbit connector. You can also record manual clinical benchmarks below.',
                    style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.05,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: MetricType.values.length,
              itemBuilder: (context, index) {
                final type = MetricType.values[index];
                final isFitbit = _isFitbitMetric(type);
                return InkWell(
                  onTap: () => context.read<MetricEntryBloc>().add(MetricTypeSelected(type)),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: AppTheme.cyberCardDecoration(
                      borderColor: isFitbit
                          ? AppTheme.cyberCyan.withValues(alpha: 0.4)
                          : AppTheme.bioEmerald.withValues(alpha: 0.3),
                      backgroundColor: AppTheme.darkCard,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isFitbit
                                ? AppTheme.cyberCyan.withValues(alpha: 0.12)
                                : AppTheme.bioEmerald.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFitbit
                                  ? AppTheme.cyberCyan.withValues(alpha: 0.3)
                                  : AppTheme.bioEmerald.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            _getMetricIcon(type),
                            size: 24,
                            color: isFitbit ? AppTheme.cyberCyan : AppTheme.bioEmerald,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getMetricLabel(type),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isFitbit
                                ? AppTheme.cyberCyan.withValues(alpha: 0.15)
                                : AppTheme.bioEmerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isFitbit ? 'SYNCED VIA FITBIT' : 'CLINICAL / MANUAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isFitbit ? AppTheme.cyberCyan : AppTheme.bioEmerald,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.cyberCyan),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cyberCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getMetricIcon(state.metricType), color: AppTheme.cyberCyan, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INGEST ${_getMetricLabel(state.metricType).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Expected Unit: ${state.unit}',
                        style: const TextStyle(color: AppTheme.cyberCyan, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => context.read<MetricEntryBloc>().add(ResetMetricForm()),
                ),
              ],
            ),
          ),
          if (_isFitbitMetric(state.metricType)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.cyberCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.cyberCyan.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.cyberCyan, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This telemetry stream is continuously synchronized via the Fitbit connector. Manual submissions create an immediate verified record.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          TextFormField(
            autofocus: true,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.cyberCyan),
            decoration: InputDecoration(
              labelText: 'TELEMETRY VALUE',
              labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, letterSpacing: 1),
              suffixText: state.unit,
              suffixStyle: const TextStyle(color: AppTheme.cyberCyan, fontWeight: FontWeight.bold),
              errorText: state.validationErrors['value'],
              filled: true,
              fillColor: AppTheme.darkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.darkBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.darkBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.cyberCyan, width: 1.5),
              ),
            ),
            keyboardType: state.metricType == MetricType.bloodPressure
                ? TextInputType.text
                : const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => context.read<MetricEntryBloc>().add(MetricValueChanged(value)),
          ),
          const SizedBox(height: 20),

          TextFormField(
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'CLINICAL NOTES / CONTEXT (OPTIONAL)',
              labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 0.8),
              filled: true,
              fillColor: AppTheme.darkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.darkBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.darkBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.cyberCyan, width: 1.5),
              ),
            ),
            onChanged: (value) => context.read<MetricEntryBloc>().add(MetricNoteChanged(value)),
          ),
          const SizedBox(height: 20),

          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.timestamp,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (date != null) context.read<MetricEntryBloc>().add(MetricTimestampChanged(date));
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.darkBorder),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppTheme.cyberCyan),
                  const SizedBox(width: 14),
                  Text(
                    'Timestamp: ${_formatDate(state.timestamp)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_calendar_rounded, size: 16, color: AppTheme.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isValid ? AppTheme.cyberCyan : AppTheme.darkCard,
                foregroundColor: state.isValid ? const Color(0xFF080C14) : AppTheme.textMuted,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: state.isValid ? 6 : 0,
              ),
              onPressed: state.isValid ? () => context.read<MetricEntryBloc>().add(SubmitMetric(widget.userId)) : null,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_rounded),
                  SizedBox(width: 10),
                  Text(
                    'SAVE TELEMETRY TO HUD',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMetricIcon(MetricType type) {
    switch (type) {
      case MetricType.bloodPressure: return Icons.favorite_rounded;
      case MetricType.weight: return Icons.monitor_weight_rounded;
      case MetricType.glucose: return Icons.opacity_rounded;
      case MetricType.heartRate: return Icons.monitor_heart_rounded;
      case MetricType.steps: return Icons.directions_run_rounded;
      case MetricType.sleep: return Icons.bedtime_rounded;
      case MetricType.calories: return Icons.local_fire_department_rounded;
      case MetricType.hydration: return Icons.water_drop_rounded;
      case MetricType.oxygenSaturation: return Icons.air_rounded;
      case MetricType.temperature: return Icons.thermostat_rounded;
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
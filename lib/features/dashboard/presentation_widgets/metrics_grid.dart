import 'package:flutter/material.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_metric.dart';
import '../../../core/theme/app_theme.dart';

class MetricsGrid extends StatelessWidget {
  final List<HealthMetric> metrics;
  final Function(MetricType) onMetricTap;

  const MetricsGrid({
    super.key,
    required this.metrics,
    required this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <MetricType, List<HealthMetric>>{};
    for (final metric in metrics) {
      grouped.putIfAbsent(metric.type, () => []).add(metric);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latest Vitals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            final type = grouped.keys.elementAt(index);
            final latest = grouped[type]!.first;
            
            return _buildMetricCard(
              context,
              type: type,
              value: latest.displayValue,
              unit: latest.unit,
              timestamp: latest.timeStamp,
              isAbnormal: latest.isAbnormal,
              onTap: () => onMetricTap(type),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required MetricType type,
    required String value,
    required String unit,
    required DateTime timestamp,
    required bool isAbnormal,
    required VoidCallback onTap,
  }) {
    final themeColor = isAbnormal ? AppTheme.dangerRed : AppTheme.primaryTeal;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAbnormal ? AppTheme.dangerRed.withOpacity(0.5) : AppTheme.borderLight,
          width: isAbnormal ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_getMetricIcon(type), size: 18, color: themeColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMetricLabel(type),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMedium,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isAbnormal ? AppTheme.dangerRed : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Keep existing _getMetricIcon, _getMetricLabel, _formatTime methods identical)
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
      case MetricType.hydration: return 'Water';
      case MetricType.oxygenSaturation: return 'Oxygen';
      case MetricType.temperature: return 'Temp';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
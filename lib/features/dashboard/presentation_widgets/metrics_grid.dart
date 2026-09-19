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
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.cyberCyan,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cyberCyan.withOpacity(0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'RECENT HEALTH BIOMARKERS',
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
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
    final themeColor = isAbnormal ? AppTheme.neonCrimson : AppTheme.neonCyan;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.obsidianCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAbnormal ? AppTheme.neonCrimson.withOpacity(0.7) : AppTheme.obsidianBorder,
          width: isAbnormal ? 1.5 : 1,
        ),
        boxShadow: [
          if (isAbnormal)
            BoxShadow(
              color: AppTheme.neonCrimson.withOpacity(0.2),
              blurRadius: 12,
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getMetricIcon(type), size: 16, color: themeColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMetricLabel(type).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isAbnormal)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.neonCrimson,
                        shape: BoxShape.circle,
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
                          fontWeight: FontWeight.w900,
                          color: isAbnormal ? AppTheme.neonCrimson : Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isAbnormal ? AppTheme.neonCrimson.withOpacity(0.8) : AppTheme.neonCyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
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
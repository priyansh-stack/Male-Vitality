import 'package:flutter/material.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_metric.dart';
import '../../../core/theme/app_theme.dart';

class MetricChart extends StatelessWidget {
  final List<HealthMetric> metrics;
  final TrendDepressed selectedPeriod;
  final Function(TrendDepressed) onPeriodChanged;

  const MetricChart({
    super.key,
    required this.metrics,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cyberCardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.auto_graph_rounded, color: AppTheme.cyberCyan, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'VITALS TELEMETRY PROGRESSION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.cyberCyan,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: metrics.isEmpty
                ? _buildEmptyState()
                : _buildProgressionChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: DropdownButton<TrendDepressed>(
        value: selectedPeriod,
        underline: const SizedBox(),
        dropdownColor: AppTheme.darkCard,
        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.cyberCyan, size: 18),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        items: TrendDepressed.values.map((period) {
          return DropdownMenuItem(
            value: period,
            child: Text(_getPeriodLabel(period)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onPeriodChanged(value);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cyberCyan.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppTheme.cyberCyan,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'NO BIOMETRIC SAMPLES RECORDED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Log vitals or sync your wearable to generate progression data',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionChart() {
    // Show up to the 7 most recent unique chronological metrics
    final displayMetrics = metrics.take(7).toList().reversed.toList();
    
    // Find dynamic min and max numerical values for bar height scaling
    double maxVal = 100.0;
    double minVal = 0.0;
    final numValues = displayMetrics.map((m) {
      if (m.value is num) return (m.value as num).toDouble();
      if (m.value is Map && m.value['systolic'] != null) {
        return (m.value['systolic'] as num).toDouble();
      }
      return 50.0;
    }).toList();

    if (numValues.isNotEmpty) {
      maxVal = numValues.reduce((a, b) => a > b ? a : b);
      minVal = numValues.reduce((a, b) => a < b ? a : b);
      if (maxVal == minVal) maxVal += 20;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${metrics.length} SAMPLES TELEMETRY STREAM',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.cyberCyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Optimal',
                    style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.neonRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Alert',
                    style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(displayMetrics.length, (index) {
                final metric = displayMetrics[index];
                final val = numValues[index];
                final ratio = ((val - minVal) / (maxVal - minVal)).clamp(0.2, 1.0);
                final isAbnormal = metric.isAbnormal;
                final barColor = isAbnormal ? AppTheme.neonRed : AppTheme.cyberCyan;
                final gradientTop = isAbnormal ? AppTheme.neonRed : AppTheme.neonPurple;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          metric.displayValue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: barColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: ratio,
                            child: Container(
                              width: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    gradientTop,
                                    barColor.withOpacity(0.4),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: barColor.withOpacity(0.35),
                                    blurRadius: 6,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDay(metric.timeStamp),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(date.weekday - 1) % 7];
  }

  String _getPeriodLabel(TrendDepressed period) {
    switch (period) {
      case TrendDepressed.sevenDays:
        return '7 Days';
      case TrendDepressed.thirtyDays:
        return '30 Days';
      case TrendDepressed.ninetyDays:
        return '90 Days';
      case TrendDepressed.oneYear:
        return '1 Year';
    }
  }
}
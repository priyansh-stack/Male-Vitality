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
              const Row(
                children: [
                  Icon(Icons.auto_graph_rounded, color: AppTheme.cyberCyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'WEEKLY VITALS PROGRESSION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.cyberCyan,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: metrics.isEmpty
                ? const Center(
                    child: Text(
                      'No vitals history recorded yet for this period',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  )
                : _buildChartContent(),
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

  Widget _buildChartContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cyberCyan.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.ssid_chart_rounded,
                size: 30,
                color: AppTheme.cyberCyan,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${metrics.length} CLINICAL LOGS MONITORED',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Vitality baseline and clinical progression active',
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
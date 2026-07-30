import 'package:flutter/material.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_metric.dart';

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
                const Text(
                  'Health Trends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildPeriodSelector(),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: metrics.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _buildChartContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return DropdownButton<TrendDepressed>(
      value: selectedPeriod,
      underline: const SizedBox(),
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
    );
  }

  Widget _buildChartContent() {
    // Placeholder chart - you can use fl_chart or syncfusion here
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Chart will display ${metrics.length} data points',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
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
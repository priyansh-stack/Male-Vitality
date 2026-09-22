import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_metric.dart';
import 'package:life_stage_health_app/core/services/database_service.dart';
import 'package:life_stage_health_app/core/theme/app_theme.dart';

class MetricDetailScreen extends StatefulWidget {
  final String userId;
  final MetricType metricType;

  const MetricDetailScreen({
    super.key,
    required this.userId,
    required this.metricType,
  });

  @override
  State<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen> {
  TrendDepressed _selectedPeriod = TrendDepressed.thirtyDays;
  List<HealthMetric>? _metrics;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dbService = context.read<DatabaseService>();
      final metrics = await dbService.getMetricTrend(
        userId: widget.userId,
        metricType: widget.metricType,
        depressed: _selectedPeriod,
      );
      if (mounted) {
        setState(() {
          _metrics = metrics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load metric trend: $e'),
            backgroundColor: AppTheme.neonRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkCanvas,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        title: Text(
          _getMetricLabel(widget.metricType).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: AppTheme.cyberCyan),
            onPressed: _showPeriodPicker,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.cyberCyan),
            )
          : _buildTrendContent(_metrics ?? []),
    );
  }

  Widget _buildTrendContent(List<HealthMetric> metrics) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPeriodChips(),
          const SizedBox(height: 16),
          Expanded(
            flex: 2,
            child: metrics.isEmpty
                ? const Center(
                    child: Text(
                      'No telemetry logged for this period',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  )
                : _buildChart(metrics),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 3,
            child: _buildMetricsList(metrics),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChips() {
    return Wrap(
      spacing: 8,
      children: TrendDepressed.values.map((period) {
        final isSelected = period == _selectedPeriod;
        return FilterChip(
          label: Text(
            _getPeriodLabel(period),
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          selected: isSelected,
          selectedColor: AppTheme.cyberCyan,
          backgroundColor: AppTheme.darkSurface,
          checkmarkColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? AppTheme.cyberCyan : AppTheme.darkBorder,
            ),
          ),
          onSelected: (_) {
            setState(() {
              _selectedPeriod = period;
              _loadData();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildChart(List<HealthMetric> metrics) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cyberCyan.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.ssid_chart_rounded,
              size: 40,
              color: AppTheme.cyberCyan,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${metrics.length} TELEMETRY RECORDS',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_getMetricLabel(widget.metricType)} Trend (${_getPeriodLabel(_selectedPeriod)})',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsList(List<HealthMetric> metrics) {
    return ListView.builder(
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        final alertColor = metric.isAbnormal ? AppTheme.neonRed : AppTheme.bioEmerald;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: metric.isAbnormal ? AppTheme.neonRed.withOpacity(0.4) : AppTheme.darkBorder,
            ),
          ),
          child: ListTile(
            leading: Icon(
              metric.isAbnormal ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: alertColor,
              size: 22,
            ),
            title: Text(
              '${metric.displayValue} ${metric.unit}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              _formatDate(metric.timeStamp),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                metric.source.toString().split('.').last.toUpperCase(),
                style: const TextStyle(fontSize: 9, color: AppTheme.cyberCyan, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Wrap(
            children: TrendDepressed.values.map((period) {
              return ListTile(
                title: Text(
                  _getPeriodLabel(period),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                trailing: period == _selectedPeriod
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.cyberCyan)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPeriod = period;
                    _loadData();
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getMetricLabel(MetricType type) {
    switch (type) {
      case MetricType.bloodPressure:
        return 'Blood Pressure';
      case MetricType.weight:
        return 'Weight';
      case MetricType.glucose:
        return 'Glucose';
      case MetricType.heartRate:
        return 'Heart Rate';
      case MetricType.steps:
        return 'Steps';
      case MetricType.sleep:
        return 'Sleep';
      case MetricType.calories:
        return 'Calories';
      case MetricType.hydration:
        return 'Hydration';
      case MetricType.oxygenSaturation:
        return 'Oxygen Saturation';
      case MetricType.temperature:
        return 'Temperature';
    }
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_stage_health_app/core/bloc/Health_Dashboard/dashboard_bloc.dart';
import 'package:life_stage_health_app/core/bloc/Health_Dashboard/support_states.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_metric.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<DashboardBloc>().add(
      LoadMetricTrend(
        userId: widget.userId,
        metricType: widget.metricType,
        trendDepressed: _selectedPeriod,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getMetricLabel(widget.metricType)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showPeriodPicker,
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MetricTrendLoaded) {
            return _buildTrendContent(state);
          }
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('Select a time period to view trends'));
        },
      ),
    );
  }

  Widget _buildTrendContent(MetricTrendLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPeriodChips(),
          const SizedBox(height: 16),
          Expanded(
            flex: 2,
            child: state.metrics.isEmpty
                ? const Center(child: Text('No data for this period'))
                : _buildChart(state.metrics),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 1,
            child: _buildMetricsList(state.metrics),
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
          label: Text(_getPeriodLabel(period)),
          selected: isSelected,
          selectedColor: Colors.blue.shade100,
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
    // Placeholder - implement with fl_chart or syncfusion
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            '${metrics.length} data points',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            '${_getMetricLabel(widget.metricType)} Trend',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
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
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(
              metric.isAbnormal ? Icons.warning : Icons.check_circle,
              color: metric.isAbnormal ? Colors.red : Colors.green,
            ),
            title: Text(
              '${metric.displayValue} ${metric.unit}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_formatDate(metric.timeStamp)),
            trailing: Text(
              metric.source.toString().split('.').last,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: TrendDepressed.values.map((period) {
            return ListTile(
              title: Text(_getPeriodLabel(period)),
              trailing: period == _selectedPeriod
                  ? const Icon(Icons.check, color: Colors.blue)
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
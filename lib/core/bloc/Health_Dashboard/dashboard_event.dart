part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {  
  final String userId;
  
  const LoadDashboardData({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class RefreshDashboard extends DashboardEvent {  
  final String userId;

  const RefreshDashboard({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class LoadMetricTrend extends DashboardEvent {  
  final String userId;
  final MetricType metricType;
  final TrendDepressed trendDepressed;

  const LoadMetricTrend({
    required this.userId,
    required this.metricType,
    required this.trendDepressed,
  });
  
  @override
  List<Object> get props => [userId, metricType, trendDepressed];
}

class AddHealthMetricEvent extends DashboardEvent {
  final HealthMetric metric;
  
  const AddHealthMetricEvent({required this.metric});

  @override
  List<Object> get props => [metric];
}

class SyncWearableDataEvent extends DashboardEvent {  
  final String userId;
  final WeareableType wearableType;  

  const SyncWearableDataEvent({
    required this.userId,
    required this.wearableType,
  });

  @override
  List<Object> get props => [userId, wearableType];
}

class UpdateTodayFocus extends DashboardEvent {
  final String userId;

  const UpdateTodayFocus({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GenerateHealthSummary extends DashboardEvent {
  final String userId;
  final DateTime startTime;
  final DateTime endDate;

  const GenerateHealthSummary({
    required this.userId,
    required this.startTime,
    required this.endDate,
  });

  @override
  List<Object> get props => [userId, startTime, endDate];
}

class ToggleMetricVisibility extends DashboardEvent {
  final MetricType metricType;

  const ToggleMetricVisibility(this.metricType);

  @override
  List<Object> get props => [metricType];
}

class SelectTimeRange extends DashboardEvent {
  final TrendDepressed trendDepressed;  

  const SelectTimeRange({required this.trendDepressed});

  @override
  List<Object> get props => [trendDepressed];
}
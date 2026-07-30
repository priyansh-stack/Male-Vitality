import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_metric.dart';
import 'package:life_stage_health_app/core/services/database_service.dart';

class GetMetricTrend {
  final DatabaseService databaseService;

  GetMetricTrend({required this.databaseService});

  Future<List<HealthMetric>> execute ({
    required String userId,
    required MetricType type,
    required TrendDepressed depressed,
  }) async {
    return await databaseService.getMetricTrend(userId: userId, metricType: type, depressed: depressed);
  }
}


import 'package:life_stage_health_app/core/models/health_metric.dart';
import 'package:life_stage_health_app/core/services/database_service.dart';

class AddHealthMetric {
  final DatabaseService databaseService;

  AddHealthMetric(this.databaseService);

  Future<void> execute(HealthMetric metric) async{
    return await databaseService.saveHealthMetric(metric);
  }
}
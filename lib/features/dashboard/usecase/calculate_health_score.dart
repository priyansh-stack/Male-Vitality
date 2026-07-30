import 'package:life_stage_health_app/core/models/health_score.dart';
import 'package:life_stage_health_app/core/services/database_service.dart';

class CalculateHealthScore {
  final DatabaseService databaseService;

  CalculateHealthScore({required this.databaseService});

  Future<HealthScore> execute(String userId) async {
    return await databaseService.calculateHealthScore(userId);
  }

  
}
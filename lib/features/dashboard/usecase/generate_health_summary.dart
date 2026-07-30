import 'package:life_stage_health_app/core/services/database_service.dart';

class GenerateHealthSummary {
  final DatabaseService databaseService;

  GenerateHealthSummary({required this.databaseService});

  Future<SummaryResult> execute({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await databaseService.generateHealthSummary(userId: userId, startDate: startDate, endDate: endDate);
  }

}
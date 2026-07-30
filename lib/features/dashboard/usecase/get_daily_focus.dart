import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';
import 'package:life_stage_health_app/core/services/database_service.dart';

class GetDailyFocus {
  final DatabaseService databaseService;

  GetDailyFocus({required this.databaseService});

  Future<TodayFocus> execute(String userId) async{
    return await databaseService.getTodayFocus(userId);
  }
}
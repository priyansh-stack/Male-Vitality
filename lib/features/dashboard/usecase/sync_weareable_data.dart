import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/services/weareable_service.dart';

class SyncWeareableData {
  final WearableService wearableService;

  SyncWeareableData({required this.wearableService});

  Stream<SyncProgress> execute(String userId, WeareableType type){
    return wearableService.syncData(userId, type);
  }
}
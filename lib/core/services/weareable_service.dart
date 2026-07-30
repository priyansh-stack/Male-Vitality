import 'dart:async';
import 'package:health/health.dart';

import '../models/health_metric.dart';
import '../models/health_enums.dart';
import 'database_service.dart';

class WearableService {
  final DatabaseService databaseService;
  final Health _health = Health();

  WearableService(this.databaseService);

  Stream<SyncProgress> syncData(String userId, WeareableType type) async* {
    yield SyncProgress(progress: 0.0, status: 'Requesting permissions...');

    try {
      // Request permissions based on platform
      final permissions = _getPermissions();
      final granted = await _health.requestAuthorization(permissions.cast<HealthDataType>());

      if (!granted) {
        yield SyncProgress(
          progress: 0.0,
          status: 'Permission denied. Please enable in settings.',
        );
        return;
      }

      yield SyncProgress(progress: 0.2, status: 'Fetching health data...');

      // Get data based on type
      final metrics = await _fetchHealthData(type);

      yield SyncProgress(progress: 0.6, status: 'Saving ${metrics.length} metrics...');

      // Save each metric
      for (var i = 0; i < metrics.length; i++) {
        await databaseService.saveHealthMetric(metrics[i]);
        final progress = 0.6 + (i / metrics.length) * 0.4;
        yield SyncProgress(
          progress: progress,
          status: 'Saving metric ${i + 1}/${metrics.length}...',
        );
      }

      yield SyncProgress(progress: 1.0, status: 'Sync complete!');
    } catch (e) {
      yield SyncProgress(
        progress: 0.0,
        status: 'Error: $e',
      );
    }
  }

  Future<List<HealthMetric>> _fetchHealthData(WeareableType type) async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    final healthData = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: now,
      types: _getHealthDataTypes(type),
      
    );

    return _convertToHealthMetrics(healthData);
  }

  List<HealthDataType> _getHealthDataTypes(WeareableType type) {
    // Return appropriate data types based on platform
    return [
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.SLEEP_IN_BED,
    ];
  }

  List<HealthDataAccess> _getPermissions() {
    return [
      HealthDataAccess.READ_WRITE,
    ];
  }

  List<HealthMetric> _convertToHealthMetrics(List<HealthDataPoint> data) {
    final metrics = <HealthMetric>[];
    // Convert platform-specific data to HealthMetric objects
    // Implementation depends on the health package
    return metrics;
  }

  Future<SyncResult> getSyncResult(String userId, WeareableType type) async {
    // Get sync history from database
    return SyncResult(count: 0, lastSync: DateTime.now(), status: 'success');
  }
}

class SyncProgress {
  final double progress;
  final String status;

  SyncProgress({required this.progress, required this.status});
}

class SyncResult {
  final int count;
  final DateTime? lastSync;
  final String status;

  SyncResult({required this.count, this.lastSync, required this.status});
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';
import '../models/health_metric.dart';
import '../models/health_score.dart';
import '../models/health_enums.dart';
import '../models/user_profile.dart';
import 'firestore_service.dart';

class DatabaseService {
  final FirestoreService firestoreService;
  final FirebaseFirestore firestore;

  DatabaseService({
    required this.firestoreService,
    required this.firestore,
  });

  // Health Metrics
  Future<void> saveHealthMetric(HealthMetric metric) async {
    await firestoreService.saveHealthMetric(metric);
  }

  Future<List<HealthMetric>> getRecentMetrics(String userId, {int days = 7}) async {
    return await firestoreService.getRecentMetrics(userId, days: days);
  }

  Future<List<HealthMetric>> getAllMetrics(String userId) async {
    return await firestoreService.getAllMetrics(userId);
  }

  Future<List<HealthMetric>> getMetricTrend({
    required String userId,
    required MetricType metricType,
    required TrendDepressed depressed,
  }) async {
    return await firestoreService.getMetricTrend(
      userId: userId,
      metricType: metricType,
      trendDepressed: depressed,
    );
  }

  Future<List<HealthMetric>> getMetricsInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await firestoreService.getMetricsInRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Health Score
  Future<HealthScore> calculateHealthScore(String userId) async {
    return await firestoreService.calculateHealthScore(userId);
  }

  // Today's Focus
  Future<TodayFocus> getTodayFocus(String userId) async {
    return await firestoreService.getTodayFocus(userId);
  }

  // Abnormal Metrics
  Future<List<AbnormalMetrices>> getAbnormalMetrics(String userId) async {
    return await firestoreService.getAbnormalMetrics(userId);
  }

  // User Preferences
  Future<void> saveUserVisibleMetrics(String userId, Set<MetricType> metrics) async {
    await firestoreService.saveUserVisibleMetrics(userId, metrics);
  }

  Future<Set<MetricType>> getUserVisibleMetrics(String userId) async {
    return await firestoreService.getUserVisibleMetrics(userId);
  }

  // Health Summary
  Future<SummaryResult> generateHealthSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await firestoreService.generateHealthSummary(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // User Profile
  Future<UserProfile?> getUserProfile(String userId) async {
    return await firestoreService.getUserProfile(userId);
  }
}

class SummaryResult {
  final String pdfPath;
  final String summary;

  SummaryResult({required this.pdfPath, required this.summary});
}

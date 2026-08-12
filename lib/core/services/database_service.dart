import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';
import '../models/health_metric.dart';
import '../models/health_score.dart';
import '../models/health_enums.dart';
import '../models/user_profile.dart';
import 'firestore_service.dart';
import 'clinical_engine.dart';

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

  // ============================================================
  //  UPDATED: HEALTH SCORE WITH MENTAL WELLNESS
  // ============================================================
  Future<HealthScore> calculateHealthScore(String userId) async {
    try {
      // Fetch physical metrics (30 days)
      final metrics = await firestoreService.getRecentMetrics(userId, days: 30);
    
      //  Fetch mood entries for mental score (7 days)
      final moodEntries = await firestoreService.getMoodEntries(userId, days: 7);
      
      // Calculate combined health score
      final healthScore = ClinicalEngine.calculateHealthScore(
        metrics: metrics,
        moodEntries: moodEntries,
      );
      
      return healthScore;
    } catch (e) {
      return HealthScore(
        score: 50,
        calculatedAt: DateTime.now(),
        categoryScores: const {},
        recommendations: const ["Error calculating score. Please try again."],
        userId: userId,
      );
    }
  }

  //  UPDATED: TODAY'S FOCUS WITH MENTAL WELLNESS
  Future<TodayFocus> getTodayFocus(String userId) async {
    try {
      final metrics = await firestoreService.getRecentMetrics(userId, days: 1);
      final moodEntries = await firestoreService.getMoodEntries(userId, days: 1);
      
      return ClinicalEngine.getTodayFocus(
        metrics: metrics,
        moodEntries: moodEntries,
      );
    } catch (e) {
      return TodayFocus(
        title: "Daily Check-in",
        description: "Stay healthy today! Let's log some vitals.",
        type: FocusType.bloodPressure,
        priority: 1,
        time: DateTime.now(),
        actions: const [],
      );
    }
  }

  // UPDATED: ABNORMAL METRICS WITH MORE CHECKS
  Future<List<AbnormalMetrices>> getAbnormalMetrics(String userId) async {
    try {
      final metrics = await firestoreService.getRecentMetrics(userId, days: 2);
      return ClinicalEngine.scanForAbnormalities(metrics);
    } catch (e) {
      return [];
    }
  }

  //  NEW: MOOD TREND ANALYSIS
  Future<Map<String, dynamic>> analyzeMoodTrends(String userId) async {
    try {
      final moodEntries = await firestoreService.getMoodEntries(userId, days: 14);
      return ClinicalEngine.analyzeMoodTrends(moodEntries);
    } catch (e) {
      return {
        'trend': 'stable',
        'average': 0.0,
        'consistency': 0.0,
        'riskLevel': 'low',
        'insights': ['Unable to analyze mood trends at this time.'],
      };
    }
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
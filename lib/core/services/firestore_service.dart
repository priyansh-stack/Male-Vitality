import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:life_stage_health_app/core/models/bloodpressure.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_metric.dart';
import 'package:life_stage_health_app/core/models/health_score.dart';
import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';
import 'package:life_stage_health_app/core/services/database_service.dart';
import 'package:life_stage_health_app/core/services/pdf_generate.dart';
import '../models/user_profile.dart';
import '../models/health_import.dart';
import 'firebase_service.dart';

class FirestoreService {
  final FirebaseFirestore firestore;

  const FirestoreService({required this.firestore});

  static final Map<String, UserProfile> _profileStore = {};
  static final Map<String, Map<String, HealthImportSource>> _healthImportStore = {};

  Future<void> saveUserProfile(UserProfile profile) async {
    _profileStore[profile.uid] = profile;

    if (FirebaseService.isInitialized) {
      try {
        final userRef = firestore.collection('users').doc(profile.uid);
        
        await userRef.set({
          'onboarding_completed': profile.onboardingCompleted,
          'last_active': FieldValue.serverTimestamp(),
          'email': profile.email,
          'displayName': profile.displayName,
        }, SetOptions(merge: true));

        await userRef.collection('profile').doc('main').set(profile.toMap());
        await userRef.collection('lifestyle').doc('factors').set(profile.lifestyle.toMap());

        if (profile.emergencyContact != null) {
          await userRef.collection('emergency').doc('contact').set(profile.emergencyContact!.toMap());
        }

        debugPrint('UserProfile synced to Firestore [users/${profile.uid}]');
      } catch (e) {
        debugPrint('Firestore write error (using local store): $e');
      }
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    if (FirebaseService.isInitialized) {
      try {
        final doc = await firestore
            .collection('users')
            .doc(uid)
            .collection('profile')
            .doc('main')
            .get();
        if (doc.exists && doc.data() != null) {
          return UserProfile.fromMap(doc.data()!);
        }
      } catch (e) {
        debugPrint('Firestore read error: $e');
      }
    }
    return _profileStore[uid];
  }

  Future<void> saveHealthImport({
    required String uid,
    required String provider,
    required HealthImportSource importSource,
  }) async {
    _healthImportStore.putIfAbsent(uid, () => {});
    _healthImportStore[uid]![provider] = importSource;

    if (FirebaseService.isInitialized) {
      try {
        await firestore
            .collection('health_imports')
            .doc(uid)
            .set({
          provider: importSource.toMap(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('Health import saved to Firestore [health_imports/$uid/$provider]');
      } catch (e) {
        debugPrint('Firestore health import error: $e');
      }
    }
  }

  Map<String, HealthImportSource>? getHealthImports(String uid) {
    return _healthImportStore[uid];
  }

  Future<void> saveHealthMetric(HealthMetric metric) async {
    try {
      await firestore
          .collection('users')
          .doc(metric.userId)
          .collection('health_metrics')
          .doc(metric.id)
          .set(metric.toMap());
      debugPrint('Health metric saved: ${metric.id} for user ${metric.userId}');
    } catch (e) {
      throw Exception('Failed to save health metric: $e');
    }
  }

  Future<List<HealthMetric>> getRecentMetrics(String userId, {int days = 7}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('health_metrics')
          .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      final metrics = snapshot.docs
          .map((doc) => HealthMetric.fromMap(doc.data()))
          .toList();
      
      debugPrint('Found ${metrics.length} recent metrics for user $userId');
      return metrics;
    } catch (e) {
      debugPrint('Failed to get recent metrics: $e');
      return [];
    }
  }

  Future<List<HealthMetric>> getAllMetrics(String userId) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('health_metrics')
          .orderBy('timestamp', descending: true)
          .get();

      final metrics = snapshot.docs
          .map((doc) => HealthMetric.fromMap(doc.data()))
          .toList();
      
      debugPrint('Found ${metrics.length} total metrics for user $userId');
      return metrics;
    } catch (e) {
      debugPrint('Failed to get all metrics: $e');
      return [];
    }
  }

  Future<List<HealthMetric>> getMetricTrend({
    required String userId,
    required MetricType metricType,
    required TrendDepressed trendDepressed,
  }) async {
    try {
      final days = _getDaysofDepressed(trendDepressed);
      final startDate = DateTime.now().subtract(Duration(days: days));

      try {
        final snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('health_metrics')
            .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
            .orderBy('timestamp', descending: false)
            .limit(100)
            .get();

        final allMetrics = snapshot.docs
            .map((doc) => HealthMetric.fromMap(doc.data()))
            .toList();

        final filteredMetrics = allMetrics
            .where((metric) => metric.type == metricType)
            .toList();

        debugPrint('Found ${filteredMetrics.length} metrics for type $metricType');
        return filteredMetrics;
      } catch (e) {
        debugPrint('Falling back to in-memory filtering: $e');
        // ✅ FIX: Fetch only recent metrics to avoid full DB download
        final recentMetrics = await getRecentMetrics(userId, days: days);
        return recentMetrics
            .where((metric) => 
                metric.type == metricType && 
                metric.timeStamp.isAfter(startDate))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to get metric trend: $e');
      return [];
    }
  }

  int _getDaysofDepressed(TrendDepressed trend) {
    switch (trend) {
      case TrendDepressed.sevenDays:
        return 7;
      case TrendDepressed.thirtyDays:
        return 30;
      case TrendDepressed.ninetyDays:
        return 90;
      case TrendDepressed.oneYear:
        return 365;
    }
  }

  Future<List<HealthMetric>> getMetricsInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('health_metrics')
          .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HealthMetric.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get metrics in range: $e');
    }
  }

  Future<HealthScore> calculateHealthScore(String userId) async {
    try {
      final metrics = await getRecentMetrics(userId, days: 30);
      
      final categoryScores = <HealthCategory, int>{};
      
      for (final category in HealthCategory.values) {
        int score = 50; 
        categoryScores[category] = score;
      }

      int totalScore = 0;
      for (final score in categoryScores.values) {
        totalScore += score;
      }
      final overallScore = categoryScores.isNotEmpty 
          ? (totalScore / categoryScores.length).round() 
          : 50;

      return HealthScore(
        score: overallScore,
        calculatedAt: DateTime.now(),
        categoryScores: categoryScores,
        recommendations: [
          'Continue monitoring your health metrics regularly',
          'Maintain a balanced lifestyle',
        ],
        userId: userId,
      );
    } catch (e) {
      debugPrint('Failed to calculate health score: $e');
      return HealthScore(
        score: 50,
        calculatedAt: DateTime.now(),
        categoryScores: {},
        recommendations: ['Start tracking your health metrics'],
        userId: userId,
      );
    }
  }

  Future<TodayFocus> getTodayFocus(String userId) async {
    try {
      final metrics = await getRecentMetrics(userId, days: 7);
      
      return TodayFocus(
        title: 'Check Your Health Metrics',
        description: 'Log your daily health metrics to track your progress.',
        type: FocusType.activity,
        priority: 2,
        actions: [
          FocusAction(
            label: 'Log Metrics',
            action: 'log_metrics',
            icon: Icons.add,
          ),
          FocusAction(
            label: 'View Trends',
            action: 'view_trends',
            icon: Icons.trending_up,
          ),
        ],
        time: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Failed to get today focus: $e');
      return TodayFocus(
        title: 'Welcome to Your Dashboard',
        description: 'Start tracking your health metrics today.',
        type: FocusType.activity,
        priority: 1,
        actions: [],
        time: DateTime.now(),
      );
    }
  }

  Future<List<AbnormalMetrices>> getAbnormalMetrics(String userId) async {
    // ✅ FIX: Only check the last 7 days instead of the whole database history
    final metrics = await getRecentMetrics(userId, days: 7);
    final abnormal = <AbnormalMetrices>[];

    for (final metric in metrics) {
      if (metric.isAbnormal) {
        abnormal.add(
          AbnormalMetrices(
            metric: metric,
            alertmessage: _generateAlertMessage(metric),
            alertSevirity: _determineSeverity(metric),
            recommendation: _getRecommendation(metric),
            category: _getCategoryFromMetric(metric),
          ),
        );
      }
    }

    return abnormal;
  }

  Future<void> saveUserVisibleMetrics(String userId, Set<MetricType> metrics) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .set({
        'visibleMetrics': metrics.map((e) => e.toString()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user visible metrics: $e');
    }
  }

  Future<Set<MetricType>> getUserVisibleMetrics(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data()!.containsKey('visibleMetrics')) {
        final list = List<String>.from(doc.data()!['visibleMetrics']);
        return list
            .map((e) => MetricType.values.firstWhere((type) => type.toString() == e))
            .toSet();
      }
      return MetricType.values.toSet();
    } catch (e) {
      return MetricType.values.toSet();
    }
  }

  Future<SummaryResult> generateHealthSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final metrics = await getMetricsInRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    final summary = StringBuffer();
    summary.writeln('Health Summary Report');
    summary.writeln('Period: ${startDate.toLocal()} - ${endDate.toLocal()}');
    summary.writeln('Total Metrics: ${metrics.length}');
    summary.writeln('');

    final grouped = <MetricType, List<HealthMetric>>{};
    for (final metric in metrics) {
      grouped.putIfAbsent(metric.type, () => []).add(metric);
    }

    for (final entry in grouped.entries) {
      summary.writeln('${_getMetricLabel(entry.key)}:');
      summary.writeln('  Count: ${entry.value.length}');
      if (entry.value.isNotEmpty) {
        summary.writeln('  Latest: ${entry.value.first.displayValue} ${entry.value.first.unit}');
      }
      summary.writeln('');
    }

    final pdfGenerator = PDFGenerator();
    final pdfBytes = await pdfGenerator.generateHealthSummary(
      title: 'Health Summary',
      content: summary.toString(),
      metrices: {},
    );

    final path = await _savePDF(pdfBytes);

    return SummaryResult(
      pdfPath: path,
      summary: summary.toString(),
    );
  }

  String _generateAlertMessage(HealthMetric metric) {
    switch (metric.type) {
      case MetricType.bloodPressure:
        final bp = metric.value as Bloodpressure;
        return 'Blood pressure is ${bp.Category.displayname.toLowerCase()}: ${bp.formatted}';
      case MetricType.weight:
        return 'Weight is outside healthy range: ${metric.displayValue} ${metric.unit}';
      case MetricType.glucose:
        return 'Blood glucose is abnormal: ${metric.displayValue} ${metric.unit}';
      case MetricType.heartRate:
        final hr = metric.value as int;
        return 'Heart rate is ${hr > 100 ? 'elevated' : 'low'}: $hr bpm';
      default:
        return 'Abnormal ${_getMetricLabel(metric.type)} detected: ${metric.displayValue} ${metric.unit}';
    }
  }

  AlertSevirity _determineSeverity(HealthMetric metric) {
    switch (metric.type) {
      case MetricType.bloodPressure:
        final bp = metric.value as Bloodpressure;
        if (bp.Category == BloodPresureCategory.hypertensiveCrisis) {
          return AlertSevirity.critical;
        }
        if (bp.Category == BloodPresureCategory.hypertensionStage2) {
          return AlertSevirity.high;
        }
        return AlertSevirity.medium;
      case MetricType.glucose:
        final glucose = metric.value as double;
        if (glucose < 70 || glucose > 200) return AlertSevirity.high;
        return AlertSevirity.medium;
      case MetricType.heartRate:
        final hr = metric.value as int;
        if (hr < 50 || hr > 110) return AlertSevirity.high;
        return AlertSevirity.medium;
      default:
        return AlertSevirity.medium;
    }
  }

  String _getRecommendation(HealthMetric metric) {
    switch (metric.type) {
      case MetricType.bloodPressure:
        final bp = metric.value as Bloodpressure;
        if (bp.Category == BloodPresureCategory.hypertensionStage2) {
          return 'Contact your healthcare provider. Monitor daily and reduce sodium intake.';
        }
        if (bp.Category == BloodPresureCategory.elevated) {
          return 'Increase exercise, reduce stress, and monitor regularly.';
        }
        return 'Continue monitoring and maintain healthy lifestyle.';
      case MetricType.glucose:
        final glucose = metric.value as double;
        if (glucose < 70) {
          return 'Consume fast-acting carbohydrates and retest in 15 minutes.';
        }
        if (glucose > 200) {
          return 'Check ketones, stay hydrated, and consult your healthcare provider.';
        }
        return 'Monitor glucose levels and follow your diabetes management plan.';
      default:
        return 'Monitor this metric regularly and consult your healthcare provider if concerned.';
    }
  }

  String _getCategoryFromMetric(HealthMetric metric) {
    switch (metric.type) {
      case MetricType.bloodPressure:
      case MetricType.heartRate:
        return 'Cardiovascular';
      case MetricType.weight:
      case MetricType.glucose:
        return 'Metabolic';
      case MetricType.steps:
      case MetricType.calories:
        return 'Activity';
      case MetricType.sleep:
        return 'Sleep';
      case MetricType.hydration:
        return 'Nutrition';
      default:
        return 'General';
    }
  }

  String _getMetricLabel(MetricType type) {
    switch (type) {
      case MetricType.bloodPressure:
        return 'Blood Pressure';
      case MetricType.weight:
        return 'Weight';
      case MetricType.glucose:
        return 'Glucose';
      case MetricType.heartRate:
        return 'Heart Rate';
      case MetricType.steps:
        return 'Steps';
      case MetricType.sleep:
        return 'Sleep';
      case MetricType.calories:
        return 'Calories';
      case MetricType.hydration:
        return 'Hydration';
      case MetricType.oxygenSaturation:
        return 'Oxygen Saturation';
      case MetricType.temperature:
        return 'Temperature';
    }
  }

  Future<String> _savePDF(Uint8List pdfBytes) async {
    return 'path/to/saved/pdf.pdf';
  }
}
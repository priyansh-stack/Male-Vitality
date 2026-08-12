import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_metric.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/mood_entry.dart';
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

  // ==========================================
  // USER PROFILES & SETTINGS
  // ==========================================
  
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

  // ==========================================
  // HEALTH METRICS (CRUD)
  // ==========================================

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

      return snapshot.docs.map((doc) => HealthMetric.fromMap(doc.data())).toList();
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

      return snapshot.docs.map((doc) => HealthMetric.fromMap(doc.data())).toList();
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

        final allMetrics = snapshot.docs.map((doc) => HealthMetric.fromMap(doc.data())).toList();
        return allMetrics.where((metric) => metric.type == metricType).toList();

      } catch (e) {
        // Fallback for missing indexes
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

      return snapshot.docs.map((doc) => HealthMetric.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get metrics in range: $e');
    }
  }

  // ==========================================
  // PDF EXPORT
  // ==========================================

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
    summary.writeln('Total Metrics: ${metrics.length}\n');

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

  // ==========================================
  // THIRD-PARTY IMPORTS
  // ==========================================

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

  // ==========================================
  // HELPERS
  // ==========================================

  int _getDaysofDepressed(TrendDepressed trend) {
    switch (trend) {
      case TrendDepressed.sevenDays: return 7;
      case TrendDepressed.thirtyDays: return 30;
      case TrendDepressed.ninetyDays: return 90;
      case TrendDepressed.oneYear: return 365;
    }
  }

  String _getMetricLabel(MetricType type) {
    switch (type) {
      case MetricType.bloodPressure: return 'Blood Pressure';
      case MetricType.weight: return 'Weight';
      case MetricType.glucose: return 'Glucose';
      case MetricType.heartRate: return 'Heart Rate';
      case MetricType.steps: return 'Steps';
      case MetricType.sleep: return 'Sleep';
      case MetricType.calories: return 'Calories';
      case MetricType.hydration: return 'Hydration';
      case MetricType.oxygenSaturation: return 'Oxygen Saturation';
      case MetricType.temperature: return 'Temperature';
    }
  }

  Future<String> _savePDF(Uint8List pdfBytes) async {
    // Note: Actual file saving logic would go here using path_provider
    return 'path/to/saved/pdf.pdf';
  }

  
  // MOOD ENTRIES (NEW)
 
  Future<List<MoodEntry>> getMoodEntries(String userId, {int days = 7}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('mood_entries')
          .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MoodEntry.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Failed to get mood entries: $e');
      return [];
    }
  }

  Future<MoodEntry> saveMoodEntry(MoodEntry entry) async {
    final docRef = await firestore
        .collection('users')
        .doc(entry.userId)
        .collection('mood_entries')
        .add(entry.toMap());

    return entry.copyWith(id: docRef.id);
  }

  Future<void> deleteMoodEntry(String userId, String entryId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('mood_entries')
        .doc(entryId)
        .delete();
  }

  Future<MoodEntry> updateMoodEntry(MoodEntry entry) async {
    await firestore
        .collection('users')
        .doc(entry.userId)
        .collection('mood_entries')
        .doc(entry.id)
        .update(entry.toMap());
    return entry;
  }
}
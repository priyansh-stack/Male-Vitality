import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_metric.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/mood_entry.dart';
import 'package:life_stage_health_app/core/services/database_service.dart';
import 'package:life_stage_health_app/core/services/pdf_generate.dart';
import '../models/user_profile.dart';
import '../models/health_import.dart';
import '../models/health_daily.dart';
import 'firebase_service.dart';

class _CachedItem<T> {
  final T data;
  final DateTime timestamp;
  _CachedItem(this.data) : timestamp = DateTime.now();
  bool isExpired(Duration ttl) => DateTime.now().difference(timestamp) > ttl;
}

class FirestoreUsageMonitor {
  static int _reads = 0;
  static int _writes = 0;
  static int _cacheHits = 0;

  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);

  static int get reads => _reads;
  static int get writes => _writes;
  static int get cacheHits => _cacheHits;

  static void recordRead([int count = 1]) {
    _reads += count;
    notifier.value++;
  }

  static void recordWrite([int count = 1]) {
    _writes += count;
    notifier.value++;
  }

  static void recordCacheHit([int count = 1]) {
    _cacheHits += count;
    notifier.value++;
  }

  static void reset() {
    _reads = 0;
    _writes = 0;
    _cacheHits = 0;
    notifier.value++;
  }
}

class FirestoreService {
  final FirebaseFirestore firestore;

  const FirestoreService({required this.firestore});

  static final Map<String, UserProfile> _profileStore = {};
  static final Map<String, Map<String, HealthImportSource>> _healthImportStore =
      {};
  static final Map<String, _CachedItem<List<HealthMetric>>> _metricsCache = {};
  static final Map<String, _CachedItem<List<MoodEntry>>> _moodCache = {};
  static final Map<String, _CachedItem<HealthDaily?>> _healthDailyCache = {};
  static final Map<String, _CachedItem<List<HealthDaily>>>
  _recentHealthDailiesCache = {};
  static const Duration _cacheTtl = Duration(minutes: 3);

  Future<void> saveUserProfile(UserProfile profile) async {
    _profileStore[profile.uid] = profile;

    if (FirebaseService.isInitialized) {
      try {
        final userRef = firestore.collection('users').doc(profile.uid);
        FirestoreUsageMonitor.recordWrite(4);

        // 1. Write common profile attributes to users/{uid}/common/profile
        await userRef.collection('common').doc('profile').set({
          'uid': profile.uid,
          'email': profile.email,
          'displayName': profile.displayName,
          'fullName': profile.displayName,
          'dateOfBirth': profile.dateOfBirth.toIso8601String(),
          'age': profile.age,
          'gender': profile.gender,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 2. Write Male Vitality specific profile to users/{uid}/apps/male_vitality/profile/main
        await userRef
            .collection('apps')
            .doc('male_vitality')
            .collection('profile')
            .doc('main')
            .set(profile.toMap());

        // 3. Write lifestyle to users/{uid}/apps/male_vitality/lifestyle/factors
        await userRef
            .collection('apps')
            .doc('male_vitality')
            .collection('lifestyle')
            .doc('factors')
            .set(profile.lifestyle.toMap());

        // 4. Update onboarding state in apps/male_vitality/onboarding/state
        if (profile.onboardingCompleted) {
          await userRef
              .collection('apps')
              .doc('male_vitality')
              .collection('onboarding')
              .doc('state')
              .set({
            'completed': true,
            'completedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        if (profile.emergencyContact != null) {
          FirestoreUsageMonitor.recordWrite(1);
          await userRef
              .collection('apps')
              .doc('male_vitality')
              .collection('emergency')
              .doc('contact')
              .set(profile.emergencyContact!.toMap());
        }

        // 5. Legacy writes for smooth backward compatibility
        await userRef.set({
          'uid': profile.uid,
          'email': profile.email,
          'displayName': profile.displayName,
          'fullName': profile.displayName,
          'dateOfBirth': profile.dateOfBirth.toIso8601String(),
          'age': profile.age,
          'gender': profile.gender,
          'lifeStage': profile.lifeStage.name,
          'onboarding_completed': profile.onboardingCompleted,
          'onboardingCompleted': profile.onboardingCompleted,
          'healthConditions': profile.healthConditions,
          'insuranceDetails': profile.insuranceDetails,
          'last_active': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint(
          '⚡ UserProfile synced to Cloud Firestore [users/${profile.uid}/apps/male_vitality]',
        );
      } catch (e) {
        debugPrint('⚠️ Firestore write error: $e');
      }
    }
  }

  Future<bool> isMaleVitalityOnboarded(String uid) async {
    if (!FirebaseService.isInitialized || uid.isEmpty) return false;
    try {
      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('apps')
          .doc('male_vitality')
          .collection('onboarding')
          .doc('state')
          .get();
      if (doc.exists && doc.data()?['completed'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('⚠️ Error checking Male Vitality onboarding status: $e');
      return false;
    }
  }

  Future<void> completeMaleVitalityOnboarding(String uid) async {
    if (!FirebaseService.isInitialized || uid.isEmpty) return;
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('apps')
          .doc('male_vitality')
          .collection('onboarding')
          .doc('state')
          .set({
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('⚠️ Error completing Male Vitality onboarding: $e');
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    if (_profileStore.containsKey(uid)) {
      FirestoreUsageMonitor.recordCacheHit();
      return _profileStore[uid];
    }

    if (FirebaseService.isInitialized) {
      try {
        // 1. Primary: users/{uid}/apps/male_vitality/profile/main
        final appDoc = await firestore
            .collection('users')
            .doc(uid)
            .collection('apps')
            .doc('male_vitality')
            .collection('profile')
            .doc('main')
            .get();

        FirestoreUsageMonitor.recordRead(1);
        if (appDoc.exists && appDoc.data() != null) {
          final profile = UserProfile.fromMap(appDoc.data()!);
          _profileStore[uid] = profile;
          return profile;
        }

        // 2. Fallback: subcollection profile/main
        final doc = await firestore
            .collection('users')
            .doc(uid)
            .collection('profile')
            .doc('main')
            .get();
        FirestoreUsageMonitor.recordRead(1);
        if (doc.exists && doc.data() != null) {
          final data = Map<String, dynamic>.from(doc.data()!);
          final isOnboarded = await isMaleVitalityOnboarded(uid);
          data['onboardingCompleted'] = isOnboarded;
          data['onboarding_completed'] = isOnboarded;
          final profile = UserProfile.fromMap(data);
          _profileStore[uid] = profile;
          return profile;
        }

        // 3. Fallback: check root document users/{uid}
        final rootDoc = await firestore.collection('users').doc(uid).get();
        FirestoreUsageMonitor.recordRead(1);
        if (rootDoc.exists && rootDoc.data() != null) {
          final data = Map<String, dynamic>.from(rootDoc.data()!);
          final isOnboarded = await isMaleVitalityOnboarded(uid);
          if (isOnboarded) {
            final profile = UserProfile.fromMap(data);
            _profileStore[uid] = profile;
            return profile;
          }
        }
      } catch (e) {
        debugPrint('⚠️ Firestore read error: $e');
      }
    }
    return _profileStore[uid];
  }

  Future<void> saveUserVisibleMetrics(
    String userId,
    Set<MetricType> metrics,
  ) async {
    try {
      // Primary: users/{userId}/apps/male_vitality/preferences/settings
      await firestore
          .collection('users')
          .doc(userId)
          .collection('apps')
          .doc('male_vitality')
          .collection('preferences')
          .doc('settings')
          .set({
        'visibleMetrics': metrics.map((e) => e.toString()).toList(),
      }, SetOptions(merge: true));

      // Legacy fallback
      await firestore.collection('users').doc(userId).set({
        'visibleMetrics': metrics.map((e) => e.toString()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user visible metrics: $e');
    }
  }

  Future<Set<MetricType>> getUserVisibleMetrics(String userId) async {
    try {
      final appDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('apps')
          .doc('male_vitality')
          .collection('preferences')
          .doc('settings')
          .get();
      if (appDoc.exists && appDoc.data()!.containsKey('visibleMetrics')) {
        final list = List<String>.from(appDoc.data()!['visibleMetrics']);
        return list
            .map(
              (e) =>
                  MetricType.values.firstWhere((type) => type.toString() == e),
            )
            .toSet();
      }

      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data()!.containsKey('visibleMetrics')) {
        final list = List<String>.from(doc.data()!['visibleMetrics']);
        return list
            .map(
              (e) =>
                  MetricType.values.firstWhere((type) => type.toString() == e),
            )
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
      // Primary: users/{userId}/shared_health/metrics/records/{id}
      await firestore
          .collection('users')
          .doc(metric.userId)
          .collection('shared_health')
          .doc('metrics')
          .collection('records')
          .doc(metric.id)
          .set(metric.toMap());

      // Legacy fallback
      await firestore
          .collection('users')
          .doc(metric.userId)
          .collection('health_metrics')
          .doc(metric.id)
          .set(metric.toMap());

      FirestoreUsageMonitor.recordWrite(2);
      _metricsCache.removeWhere((k, _) => k.startsWith('${metric.userId}-'));
      debugPrint('Health metric saved: ${metric.id} for user ${metric.userId}');
    } catch (e) {
      throw Exception('Failed to save health metric: $e');
    }
  }

  Future<List<HealthMetric>> getRecentMetrics(
    String userId, {
    int days = 7,
  }) async {
    final cacheKey = '$userId-$days';
    final cached = _metricsCache[cacheKey];
    if (cached != null && !cached.isExpired(_cacheTtl)) {
      FirestoreUsageMonitor.recordCacheHit();
      return cached.data;
    }

    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      // 1. Primary read from shared_health/metrics/records
      var snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('shared_health')
          .doc('metrics')
          .collection('records')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: startDate.toIso8601String(),
          )
          .orderBy('timestamp', descending: true)
          .get();

      // 2. Fallback read from legacy health_metrics
      if (snapshot.docs.isEmpty) {
        snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('health_metrics')
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: startDate.toIso8601String(),
            )
            .orderBy('timestamp', descending: true)
            .get();
      }

      FirestoreUsageMonitor.recordRead(
        snapshot.docs.isNotEmpty ? snapshot.docs.length : 1,
      );
      final list = snapshot.docs
          .map((doc) => HealthMetric.fromMap(doc.data()))
          .toList();
      _metricsCache[cacheKey] = _CachedItem(list);
      return list;
    } catch (e) {
      debugPrint('Failed to get recent metrics: $e');
      return [];
    }
  }

  Future<List<HealthMetric>> getAllMetrics(String userId) async {
    final cacheKey = '$userId-all';
    final cached = _metricsCache[cacheKey];
    if (cached != null && !cached.isExpired(_cacheTtl)) {
      FirestoreUsageMonitor.recordCacheHit();
      return cached.data;
    }

    try {
      var snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('shared_health')
          .doc('metrics')
          .collection('records')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('health_metrics')
            .orderBy('timestamp', descending: true)
            .get();
      }

      FirestoreUsageMonitor.recordRead(
        snapshot.docs.isNotEmpty ? snapshot.docs.length : 1,
      );
      final list = snapshot.docs
          .map((doc) => HealthMetric.fromMap(doc.data()))
          .toList();
      _metricsCache[cacheKey] = _CachedItem(list);
      return list;
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
        var snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('shared_health')
            .doc('metrics')
            .collection('records')
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: startDate.toIso8601String(),
            )
            .orderBy('timestamp', descending: false)
            .limit(100)
            .get();

        if (snapshot.docs.isEmpty) {
          snapshot = await firestore
              .collection('users')
              .doc(userId)
              .collection('health_metrics')
              .where(
                'timestamp',
                isGreaterThanOrEqualTo: startDate.toIso8601String(),
              )
              .orderBy('timestamp', descending: false)
              .limit(100)
              .get();
        }

        final allMetrics = snapshot.docs
            .map((doc) => HealthMetric.fromMap(doc.data()))
            .toList();
        return allMetrics.where((metric) => metric.type == metricType).toList();
      } catch (e) {
        // Fallback for missing indexes
        final recentMetrics = await getRecentMetrics(userId, days: days);
        return recentMetrics
            .where(
              (metric) =>
                  metric.type == metricType &&
                  metric.timeStamp.isAfter(startDate),
            )
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
      var snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('shared_health')
          .doc('metrics')
          .collection('records')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: startDate.toIso8601String(),
          )
          .where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('health_metrics')
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: startDate.toIso8601String(),
            )
            .where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String())
            .orderBy('timestamp', descending: true)
            .get();
      }

      return snapshot.docs
          .map((doc) => HealthMetric.fromMap(doc.data()))
          .toList();
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
        summary.writeln(
          '  Latest: ${entry.value.first.displayValue} ${entry.value.first.unit}',
        );
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

    return SummaryResult(pdfPath: path, summary: summary.toString());
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
        // Save under user subcollection: users/{uid}/apps/male_vitality/health_imports/{provider}
        await firestore
            .collection('users')
            .doc(uid)
            .collection('apps')
            .doc('male_vitality')
            .collection('health_imports')
            .doc(provider)
            .set(importSource.toMap());

        debugPrint(
          '⚡ Health import saved to Cloud Firestore [users/$uid/apps/male_vitality/health_imports/$provider]',
        );
      } catch (e) {
        debugPrint('⚠️ Firestore health import error: $e');
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
    // Note: Actual file saving logic would go here using path_provider
    return 'path/to/saved/pdf.pdf';
  }

  // MOOD ENTRIES (NEW)

  Future<List<MoodEntry>> getMoodEntries(String userId, {int days = 7}) async {
    final cacheKey = '$userId-$days';
    final cached = _moodCache[cacheKey];
    if (cached != null && !cached.isExpired(_cacheTtl)) {
      FirestoreUsageMonitor.recordCacheHit();
      return cached.data;
    }

    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      // 1. Primary: users/{userId}/apps/male_vitality/mood_entries
      var snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('apps')
          .doc('male_vitality')
          .collection('mood_entries')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: startDate.toIso8601String(),
          )
          .orderBy('timestamp', descending: true)
          .get();

      // 2. Fallback: users/{userId}/mood_entries
      if (snapshot.docs.isEmpty) {
        snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('mood_entries')
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: startDate.toIso8601String(),
            )
            .orderBy('timestamp', descending: true)
            .get();
      }

      FirestoreUsageMonitor.recordRead(
        snapshot.docs.isNotEmpty ? snapshot.docs.length : 1,
      );
      final list = snapshot.docs
          .map((doc) => MoodEntry.fromMap(doc.data()))
          .toList();
      _moodCache[cacheKey] = _CachedItem(list);
      return list;
    } catch (e) {
      debugPrint('Failed to get mood entries: $e');
      return [];
    }
  }

  Future<MoodEntry> saveMoodEntry(MoodEntry entry) async {
    // Primary write: users/{entry.userId}/apps/male_vitality/mood_entries
    final docRef = await firestore
        .collection('users')
        .doc(entry.userId)
        .collection('apps')
        .doc('male_vitality')
        .collection('mood_entries')
        .add(entry.toMap());

    FirestoreUsageMonitor.recordWrite(1);
    _moodCache.removeWhere((k, _) => k.startsWith('${entry.userId}-'));
    return entry.copyWith(id: docRef.id);
  }

  Future<void> deleteMoodEntry(String userId, String entryId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('apps')
        .doc('male_vitality')
        .collection('mood_entries')
        .doc(entryId)
        .delete();
    FirestoreUsageMonitor.recordWrite(1);
    _moodCache.removeWhere((k, _) => k.startsWith('$userId-'));
  }

  Future<MoodEntry> updateMoodEntry(MoodEntry entry) async {
    await firestore
        .collection('users')
        .doc(entry.userId)
        .collection('apps')
        .doc('male_vitality')
        .collection('mood_entries')
        .doc(entry.id)
        .update(entry.toMap());
    FirestoreUsageMonitor.recordWrite(1);
    _moodCache.removeWhere((k, _) => k.startsWith('${entry.userId}-'));
    return entry;
  }

  // ==========================================
  // HEALTH DAILY (FITBIT / GOOGLE HEALTH CONSUMER)
  // ==========================================

  /// Returns canonical Firestore document path for user healthDaily document.
  static String healthDailyDocPath(String userId, String date) =>
      'users/$userId/shared_health/daily/records/$date';

  /// Retrieves today's health aggregate document.
  /// Uses local date to prevent UTC shift errors.
  Future<HealthDaily?> getTodayHealthDaily(String userId) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return getHealthDailyForDate(userId, today);
  }

  /// Retrieves a specific day's health aggregate at users/{userId}/shared_health/daily/records/{date}
  /// with automatic fallback to users/{userId}/healthDaily/{date}.
  Future<HealthDaily?> getHealthDailyForDate(String userId, String date) async {
    if (userId.isEmpty || date.isEmpty) return null;

    final cacheKey = '$userId-$date';
    final cached = _healthDailyCache[cacheKey];
    if (cached != null && !cached.isExpired(_cacheTtl)) {
      FirestoreUsageMonitor.recordCacheHit();
      return cached.data;
    }

    if (!FirebaseService.isInitialized) return null;

    try {
      // 1. Primary: shared_health/daily/records/{date}
      var doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('shared_health')
          .doc('daily')
          .collection('records')
          .doc(date)
          .get();

      // 2. Fallback: healthDaily/{date}
      if (!doc.exists || doc.data() == null) {
        doc = await firestore
            .collection('users')
            .doc(userId)
            .collection('healthDaily')
            .doc(date)
            .get();
      }

      FirestoreUsageMonitor.recordRead(1);

      if (doc.exists && doc.data() != null) {
        final daily = HealthDaily.fromFirestore(doc);
        _healthDailyCache[cacheKey] = _CachedItem(daily);
        return daily;
      } else {
        _healthDailyCache[cacheKey] = _CachedItem(null);
        return null;
      }
    } catch (e) {
      debugPrint(
        '⚠️ [FirestoreService] Error fetching healthDaily ($date) for user $userId: $e',
      );
      return null;
    }
  }

  /// Retrieves recent daily health summaries up to [limit] records (default 7 days).
  /// Primary read from users/{userId}/shared_health/daily/records with fallback to users/{userId}/healthDaily.
  Future<List<HealthDaily>> getRecentHealthDailies(
    String userId, {
    int limit = 7,
  }) async {
    if (userId.isEmpty) return [];

    final cacheKey = '$userId-recent-$limit';
    final cached = _recentHealthDailiesCache[cacheKey];
    if (cached != null && !cached.isExpired(_cacheTtl)) {
      FirestoreUsageMonitor.recordCacheHit();
      return cached.data;
    }

    if (!FirebaseService.isInitialized) return [];

    try {
      // 1. Primary read: shared_health/daily/records
      var snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('shared_health')
          .doc('daily')
          .collection('records')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      // 2. Fallback: healthDaily
      if (snapshot.docs.isEmpty) {
        snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('healthDaily')
            .orderBy('date', descending: true)
            .limit(limit)
            .get();
      }

      FirestoreUsageMonitor.recordRead(
        snapshot.docs.isNotEmpty ? snapshot.docs.length : 1,
      );

      final list = snapshot.docs
          .map((doc) => HealthDaily.fromFirestore(doc))
          .toList();

      _recentHealthDailiesCache[cacheKey] = _CachedItem(list);
      return list;
    } catch (e) {
      debugPrint(
        '⚠️ [FirestoreService] Error fetching recent healthDailies for user $userId: $e',
      );
      return [];
    }
  }

  /// Listens to real-time updates for today's health aggregate document.
  Stream<HealthDaily?> watchTodayHealthDaily(String userId) {
    if (userId.isEmpty || !FirebaseService.isInitialized) {
      return const Stream.empty();
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return firestore
        .collection('users')
        .doc(userId)
        .collection('shared_health')
        .doc('daily')
        .collection('records')
        .doc(today)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            final daily = HealthDaily.fromFirestore(doc);
            _healthDailyCache['$userId-$today'] = _CachedItem(daily);
            return daily;
          }
          return null;
        })
        .handleError((error) {
          debugPrint(
            '⚠️ [FirestoreService] watchTodayHealthDaily error: $error',
          );
          return null;
        });
  }

  /// Listens to real-time updates for recent health aggregate documents.
  Stream<List<HealthDaily>> watchRecentHealthDailies(
    String userId, {
    int limit = 7,
  }) {
    if (userId.isEmpty || !FirebaseService.isInitialized) {
      return const Stream.empty();
    }

    return firestore
        .collection('users')
        .doc(userId)
        .collection('shared_health')
        .doc('daily')
        .collection('records')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => HealthDaily.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          debugPrint(
            '⚠️ [FirestoreService] watchRecentHealthDailies error: $error',
          );
          return <HealthDaily>[];
        });
  }

  /// Clears in-memory caches for the specified user upon logout or session disconnect.
  void clearUserCache(String userId) {
    _profileStore.remove(userId);
    _healthImportStore.remove(userId);
    _metricsCache.removeWhere((k, _) => k.startsWith('$userId-'));
    _moodCache.removeWhere((k, _) => k.startsWith('$userId-'));
    _healthDailyCache.removeWhere((k, _) => k.startsWith('$userId-'));
    _recentHealthDailiesCache.removeWhere((k, _) => k.startsWith('$userId-'));
    debugPrint(
      '⚡ [FirestoreService] In-memory cache cleared for user: $userId',
    );
  }
}

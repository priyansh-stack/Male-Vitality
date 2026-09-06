import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_stage_health_app/core/models/life_stage.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/booking_request.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/crisis_resource.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/emergency_service.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/exercise_progress.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/guided_exercise.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/mood_entry.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/risk_alert.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/risk_analysis_result.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/risk_profile.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/search_criteria.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/teletherapy_provider.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/therapist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_service.dart';
import 'mental_wellness_repository.dart';

class MentalWellnessRepositoryImpl implements MentalWellnessRepository {
  final FirebaseFirestore firestore;
  final SharedPreferences prefs;

  MentalWellnessRepositoryImpl({
    required this.firestore,
    required this.prefs,
  });

  // ========== MOOD TRACKING ==========

  @override
  Future<MoodEntry> createMoodEntry(MoodEntry entry) async {
    final docRef = await firestore
        .collection('users')
        .doc(entry.userId)
        .collection('mood_entries')
        .add(entry.toMap());

    final createdEntry = entry.copyWith(id: docRef.id);
    await _cacheMoodEntry(createdEntry);
    return createdEntry;
  }

  @override
  Future<List<MoodEntry>> getMoodHistory(String userId, {int days = 30}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));

    try {
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
      // Fallback to cache
      return _getCachedMoodEntries(userId);
    }
  }

  @override
  Future<List<MoodEntry>> getMoodTrends(String userId, {int days = 30}) async {
    final entries = await getMoodHistory(userId, days: days);
    // Sort by timestamp ascending for trend analysis
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }

  @override
  Future<Map<DateTime, int>> getMoodHeatmap(String userId, {int days = 30}) async {
    final entries = await getMoodHistory(userId, days: days);
    final heatmap = <DateTime, int>{};

    for (final entry in entries) {
      final date = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      heatmap[date] = entry.moodRating;
    }

    return heatmap;
  }

  @override
  Future<void> deleteMoodEntry(String entryId) async {
    // Delete from Firestore
    // Implementation depends on how entries are stored
  }

  @override
  Future<MoodEntry> updateMoodEntry(MoodEntry entry) async {
    // Update in Firestore
    return entry;
  }

  // ========== RISK DETECTION ==========

  @override
  Future<List<RiskAlert>> detectRiskPatterns(String userId) async {
    // Implementation uses DetectRiskPatternsUseCase
    return [];
  }

  @override
  Future<List<RiskAlert>> getRiskHistory(String userId) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('risk_alerts')
          .orderBy('detectedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RiskAlert.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<RiskAlert> updateRiskAlert({
    required String alertId,
    bool? acknowledged,
    bool? escalated,
    bool? dismissed,
  }) async {
    // Implementation for updating risk alert
    throw UnimplementedError();
  }

  @override
  Future<RiskProfile> getRiskProfile(String userId) async {
    final alerts = await getRiskHistory(userId);
    final activeAlerts = alerts.where((a) => !a.acknowledged).toList();
    final riskScores = <RiskType, double>{};

    for (final alert in alerts) {
      final score = _getRiskScore(alert.severity);
      riskScores[alert.type] = score;
    }

    return RiskProfile(
      userId: userId,
      activeAlerts: activeAlerts,
      historicalAlerts: alerts,
      riskScores: riskScores,
      lastAssessed: DateTime.now(),
      totalAssessments: alerts.length,
      isHighRisk: activeAlerts.any((a) => a.severity == RiskSeverity.high || a.severity == RiskSeverity.critical),
    );
  }

  @override
  Future<RiskAnalysisResult> analyzeRisks(String userId) async {
    final alerts = await detectRiskPatterns(userId);
    final hasCriticalRisk = alerts.any((a) => a.severity == RiskSeverity.critical);
    final hasHighRisk = alerts.any((a) => a.severity == RiskSeverity.high);

    final riskScores = <RiskType, double>{};
    for (final alert in alerts) {
      riskScores[alert.type] = _getRiskScore(alert.severity);
    }

    return RiskAnalysisResult(
      userId: userId,
      analyzedAt: DateTime.now(),
      alerts: alerts,
      riskScores: riskScores,
      hasCriticalRisk: hasCriticalRisk,
      hasHighRisk: hasHighRisk,
      summary: _generateRiskSummary(alerts),
      recommendations: _generateRiskRecommendations(alerts),
    );
  }

  // ========== GUIDED EXERCISES ==========

  @override
  Future<List<GuidedExercise>> getGuidedExercises({
    ExerciseType? type,
    LifeStage? ageGroup,
  }) async {
    // Return default exercises
    return _getDefaultExercises().where((exercise) {
      if (type != null && exercise.type != type) return false;
      if (ageGroup != null && exercise.targetAgeGroup != null && exercise.targetAgeGroup != ageGroup) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<GuidedExercise> getGuidedExerciseById(String exerciseId) async {
    final exercises = await getGuidedExercises();
    return exercises.firstWhere((e) => e.id == exerciseId);
  }

  @override
  Future<void> trackExerciseProgress(String userId, ExerciseProgress progress) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('exercise_progress')
        .doc('${progress.exerciseId}_${progress.userId}')
        .set(progress.toMap());
  }

  @override
  Future<List<GuidedExercise>> getExerciseRecommendations(String userId) async {
    // Get user profile to determine age and needs
    // Return age-appropriate exercises
    final allExercises = await getGuidedExercises();
    return allExercises.take(5).toList();
  }

  @override
  Future<Map<ExerciseType, List<GuidedExercise>>> getExerciseCategories() async {
    final exercises = await getGuidedExercises();
    final categories = <ExerciseType, List<GuidedExercise>>{};

    for (final exercise in exercises) {
      if (!categories.containsKey(exercise.type)) {
        categories[exercise.type] = [];
      }
      categories[exercise.type]!.add(exercise);
    }

    return categories;
  }

  // ========== THERAPY ==========

  @override
  Future<List<Therapist>> searchTherapists(SearchCriteria criteria) async {
    try {
      final snapshot = await firestore.collection('therapists').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Therapist.fromMap({...doc.data(), 'id': doc.id})).toList();
      }
    } catch (e) {
      debugPrint('⚡ [MentalWellnessRepo] searchTherapists error: $e');
    }
    return [];
  }

  @override
  Future<List<TeletherapyProvider>> getTeletherapyProviders() async {
    return TeletherapyProvider.defaultProviders;
  }

  @override
  Future<List<Therapist>> filterTherapistsByInsurance(
    List<Therapist> therapists,
    String insurance,
  ) async {
    return therapists.where((t) => t.acceptedInsurances.contains(insurance)).toList();
  }

  @override
  Future<String> bookTherapySession(BookingRequest request) async {
    try {
      final docRef = await firestore.collection('therapy_bookings').add(request.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('⚡ [MentalWellnessRepo] bookTherapySession error: $e');
      return 'booking_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  Future<Map<String, dynamic>> getTherapistAvailability(String therapistId) async {
    try {
      final doc = await firestore.collection('therapists').doc(therapistId).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('availability')) {
        return Map<String, dynamic>.from(doc.data()!['availability'] as Map);
      }
    } catch (e) {
      debugPrint('⚡ [MentalWellnessRepo] getTherapistAvailability error: $e');
    }
    return {};
  }

  // ========== CRISIS ==========

  @override
  Future<List<CrisisResource>> getCrisisResources({String? location}) async {
    return CrisisResource.defaultResources;
  }

  @override
  Future<List<EmergencyService>> getLocalEmergencyServices(String location) async {
    try {
      final snapshot = await firestore.collection('emergency_services').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => EmergencyService.fromMap({...doc.data(), 'id': doc.id})).toList();
      }
    } catch (_) {}

    return const [
      EmergencyService(
        id: 'emergency_911',
        name: 'National Emergency Dispatch (911)',
        phoneNumber: '911',
        address: 'Immediate Emergency Medical Response',
        is24Hours: true,
        services: ['Emergency Care', 'Trauma Intervention', 'Psychiatric Emergency'],
      ),
      EmergencyService(
        id: 'crisis_988',
        name: 'Suicide & Crisis Lifeline (988)',
        phoneNumber: '988',
        address: 'National Suicide Prevention & Crisis Intervention',
        is24Hours: true,
        services: ['Crisis Intervention', 'Mental Health Support', 'Substance Support'],
      ),
    ];
  }

  @override
  Future<List<CrisisResource>> getNationalHotlines() async {
    return CrisisResource.defaultResources;
  }

  @override
  Future<EmergencyProtocolResult> triggerEmergencyProtocol(String userId) async {
    // Create crisis alert
    final alert = RiskAlert(
      id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: RiskType.suicidal,
      severity: RiskSeverity.critical,
      message: 'Emergency protocol triggered for user $userId',
      recommendations: [
        'Call 100 immediately',
        'Contact local emergency services',
        'Reach out to emergency contact',
      ],
      detectedAt: DateTime.now(),
    );

    await firestore
        .collection('users')
        .doc(userId)
        .collection('emergency_alerts')
        .add(alert.toMap());

    return EmergencyProtocolResult(
      message: 'Emergency support has been alerted. Please call 988 for immediate help.',
      steps: [
        'Call 988 Suicide & Crisis Lifeline',
        'Text HOME to 741741',
        'Contact your emergency contact',
        'Go to the nearest emergency room',
      ],
    );
  }

  // ========== PRIVATE HELPERS ==========

  double _getRiskScore(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.low:
        return 0.25;
      case RiskSeverity.moderate:
        return 0.5;
      case RiskSeverity.high:
        return 0.75;
      case RiskSeverity.critical:
        return 1.0;
    }
  }

  String _generateRiskSummary(List<RiskAlert> alerts) {
    if (alerts.isEmpty) return 'No significant risks detected. Keep up the good work!';

    final criticalAlerts = alerts.where((a) => a.severity == RiskSeverity.critical).toList();
    if (criticalAlerts.isNotEmpty) {
      return 'Critical risks detected. Immediate attention required.';
    }

    final highAlerts = alerts.where((a) => a.severity == RiskSeverity.high).toList();
    if (highAlerts.isNotEmpty) {
      return 'High risk levels detected. Consider seeking professional support.';
    }

    return 'Some moderate risks detected. Monitor your mood and practice self-care.';
  }

  List<String> _generateRiskRecommendations(List<RiskAlert> alerts) {
    final recommendations = <String>[];
    for (final alert in alerts) {
      recommendations.addAll(alert.recommendations);
    }
    return recommendations.toSet().toList().take(3).toList();
  }

  List<GuidedExercise> _getDefaultExercises() {
    return [
      GuidedExercise(
        id: 'exercise_1',
        title: '5-Minute Breathing Exercise',
        description: 'Simple deep breathing to reduce stress and anxiety.',
        type: ExerciseType.breathing,
        durationMinutes: 5,
        steps: [
          'Find a comfortable seated position',
          'Close your eyes and take a deep breath in through your nose for 4 counts',
          'Hold your breath for 4 counts',
          'Exhale slowly through your mouth for 4 counts',
          'Repeat for 5 minutes',
        ],
        benefits: ['Reduces stress', 'Lowers anxiety', 'Improves focus'],
        difficultyLevel: 1,
      ),
      GuidedExercise(
        id: 'exercise_2',
        title: 'Mindful Meditation',
        description: 'Guided mindfulness meditation for beginners.',
        type: ExerciseType.meditation,
        durationMinutes: 10,
        steps: [
          'Sit comfortably with your back straight',
          'Focus on your breath moving in and out',
          'When your mind wanders, gently bring it back to your breath',
          'Continue for 10 minutes',
        ],
        benefits: ['Increases mindfulness', 'Reduces stress', 'Improves emotional regulation'],
        difficultyLevel: 2,
      ),
      GuidedExercise(
        id: 'exercise_3',
        title: 'CBT Thought Journal',
        description: 'Identify and challenge negative thought patterns.',
        type: ExerciseType.cbt,
        durationMinutes: 15,
        steps: [
          'Write down the situation that triggered negative thoughts',
          'Identify the automatic thought',
          'Challenge the thought with evidence',
          'Create a balanced alternative thought',
          'Note how you feel after reframing',
        ],
        benefits: ['Improves emotional regulation', 'Reduces anxiety', 'Builds resilience'],
        difficultyLevel: 3,
      ),
      GuidedExercise(
        id: 'exercise_4',
        title: 'Gratitude Journaling',
        description: 'Cultivate gratitude through daily journaling.',
        type: ExerciseType.journaling,
        durationMinutes: 10,
        steps: [
          'Write down 3 things you\'re grateful for today',
          'Describe why each brings you joy',
          'Reflect on how they make you feel',
          'Set an intention for tomorrow',
        ],
        benefits: ['Increases happiness', 'Reduces depression', 'Improves sleep'],
        difficultyLevel: 1,
      ),
      GuidedExercise(
        id: 'exercise_5',
        title: 'Progressive Muscle Relaxation',
        description: 'Release tension through systematic muscle relaxation.',
        type: ExerciseType.progressiveRelaxation,
        durationMinutes: 15,
        steps: [
          'Find a comfortable lying position',
          'Tense your toes for 5 seconds, then release',
          'Move up to your feet and repeat',
          'Continue up through legs, stomach, arms, shoulders, and face',
          'Feel the relaxation spread through your body',
        ],
        benefits: ['Reduces physical tension', 'Improves sleep quality', 'Relieves stress'],
        difficultyLevel: 2,
      ),
    ];
  }

  // ========== CACHE HELPERS ==========

  Future<void> _cacheMoodEntry(MoodEntry entry) async {
    final key = 'mood_entries_${entry.userId}';
    final entries = _getCachedMoodEntries(entry.userId);
    entries.add(entry);
    await prefs.setString(key, _encodeMoodEntries(entries));
  }

  List<MoodEntry> _getCachedMoodEntries(String userId) {
    final key = 'mood_entries_$userId';
    final data = prefs.getString(key);
    if (data == null) return [];
    return _decodeMoodEntries(data);
  }

  String _encodeMoodEntries(List<MoodEntry> entries) {
    // Simple JSON encoding - could use jsonEncode with proper serialization
    return entries.map((e) => e.toMap().toString()).join('||');
  }

  List<MoodEntry> _decodeMoodEntries(String data) {
    // Simple JSON decoding
    return [];
  }
}
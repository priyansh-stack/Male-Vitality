

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

abstract class MentalWellnessRepository {
  // Mood Tracking
  Future<MoodEntry> createMoodEntry(MoodEntry entry);
  Future<List<MoodEntry>> getMoodHistory(String userId, {int days});
  Future<List<MoodEntry>> getMoodTrends(String userId, {int days});
  Future<Map<DateTime, int>> getMoodHeatmap(String userId, {int days});
  Future<void> deleteMoodEntry(String entryId);
  Future<MoodEntry> updateMoodEntry(MoodEntry entry);

  // Risk Detection
  Future<List<RiskAlert>> detectRiskPatterns(String userId);
  Future<List<RiskAlert>> getRiskHistory(String userId);
  Future<RiskAlert> updateRiskAlert({
    required String alertId,
    bool? acknowledged,
    bool? escalated,
    bool? dismissed,
  });
  Future<RiskProfile> getRiskProfile(String userId);
  Future<RiskAnalysisResult> analyzeRisks(String userId);

  // Guided Exercises
  Future<List<GuidedExercise>> getGuidedExercises({
    ExerciseType? type,
    LifeStage? ageGroup,
  });
  Future<GuidedExercise> getGuidedExerciseById(String exerciseId);
  Future<void> trackExerciseProgress(String userId, ExerciseProgress progress);
  Future<List<GuidedExercise>> getExerciseRecommendations(String userId);
  Future<Map<ExerciseType, List<GuidedExercise>>> getExerciseCategories();

  // Therapy
  Future<List<Therapist>> searchTherapists(SearchCriteria criteria);
  Future<List<TeletherapyProvider>> getTeletherapyProviders();
  Future<List<Therapist>> filterTherapistsByInsurance(
    List<Therapist> therapists,
    String insurance,
  );
  Future<String> bookTherapySession(BookingRequest request);
  Future<Map<String, dynamic>> getTherapistAvailability(String therapistId);

  // Crisis
  Future<List<CrisisResource>> getCrisisResources({String? location});
  Future<List<EmergencyService>> getLocalEmergencyServices(String location);
  Future<List<CrisisResource>> getNationalHotlines();
  Future<EmergencyProtocolResult> triggerEmergencyProtocol(String userId);
}

class EmergencyProtocolResult {
  final String message;
  final List<String> steps;

  EmergencyProtocolResult({required this.message, this.steps = const []});
}
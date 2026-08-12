
import '../../models/life_stage.dart';
import 'exercise_type.dart';
import 'risk_type.dart';
import 'trigger_type.dart';

class LifeStageAdapter {
  final LifeStage lifeStage;

  const LifeStageAdapter(this.lifeStage);

  // Get recommended exercise types for this life stage
  List<ExerciseType> getRecommendedExerciseTypes() {
    switch (lifeStage) {
      case LifeStage.teen:
        return [
          ExerciseType.breathing,
          ExerciseType.mindfulness,
          ExerciseType.journaling,
          ExerciseType.affirmations,
        ];
      case LifeStage.youngAdult:
        return [
          ExerciseType.meditation,
          ExerciseType.breathing,
          ExerciseType.cbt,
          ExerciseType.journaling,
          ExerciseType.mindfulness,
        ];
      case LifeStage.adult:
        return [
          ExerciseType.meditation,
          ExerciseType.breathing,
          ExerciseType.cbt,
          ExerciseType.journaling,
          ExerciseType.progressiveRelaxation,
          ExerciseType.yoga,
        ];
      case LifeStage.midLife:
        return [
          ExerciseType.meditation,
          ExerciseType.breathing,
          ExerciseType.progressiveRelaxation,
          ExerciseType.gratitude,
          ExerciseType.bodyScan,
          ExerciseType.taiChi,
        ];
      case LifeStage.olderAdult:
        return [
          ExerciseType.breathing,
          ExerciseType.progressiveRelaxation,
          ExerciseType.gratitude,
          ExerciseType.bodyScan,
          ExerciseType.mindfulness,
        ];
      case LifeStage.senior:
        return [
          ExerciseType.breathing,
          ExerciseType.progressiveRelaxation,
          ExerciseType.gratitude,
          ExerciseType.bodyScan,
          ExerciseType.visualization,
        ];
    }
  }

  // Get common risk types for this life stage
  List<RiskType> getCommonRiskTypes() {
    switch (lifeStage) {
      case LifeStage.teen:
        return [
          RiskType.anxiety,
          RiskType.depression,
          RiskType.stress,
          RiskType.anger,
          RiskType.eatingDisorder,
        ];
      case LifeStage.youngAdult:
        return [
          RiskType.anxiety,
          RiskType.depression,
          RiskType.stress,
          RiskType.burnout,
          RiskType.substanceUse,
        ];
      case LifeStage.adult:
        return [
          RiskType.anxiety,
          RiskType.depression,
          RiskType.stress,
          RiskType.burnout,
          RiskType.ptsd,
          RiskType.ocd,
        ];
      case LifeStage.midLife:
        return [
          RiskType.anxiety,
          RiskType.depression,
          RiskType.stress,
          RiskType.burnout,
          RiskType.grief,
          RiskType.anger,
        ];
      case LifeStage.olderAdult:
        return [
          RiskType.depression,
          RiskType.anxiety,
          RiskType.stress,
          RiskType.grief,
          RiskType.ptsd,
        ];
      case LifeStage.senior:
        return [
          RiskType.depression,
          RiskType.anxiety,
          RiskType.grief,
          RiskType.stress,
          RiskType.anger,
        ];
    }
  }

  // Get common triggers for this life stage
  List<TriggerType> getCommonTriggers() {
    switch (lifeStage) {
      case LifeStage.teen:
        return [
          TriggerType.stress,
          TriggerType.relationships,
          TriggerType.social,
          TriggerType.sleep,
          TriggerType.overstimulation,
        ];
      case LifeStage.youngAdult:
        return [
          TriggerType.stress,
          TriggerType.work,
          TriggerType.relationships,
          TriggerType.financial,
          TriggerType.sleep,
        ];
      case LifeStage.adult:
        return [
          TriggerType.stress,
          TriggerType.work,
          TriggerType.relationships,
          TriggerType.financial,
          TriggerType.health,
        ];
      case LifeStage.midLife:
        return [
          TriggerType.stress,
          TriggerType.work,
          TriggerType.relationships,
          TriggerType.health,
          TriggerType.conflict,
        ];
      case LifeStage.olderAdult:
        return [
          TriggerType.health,
          TriggerType.stress,
          TriggerType.relationships,
          TriggerType.loneliness,
          TriggerType.uncertainty,
        ];
      case LifeStage.senior:
        return [
          TriggerType.health,
          TriggerType.loneliness,
          TriggerType.stress,
          TriggerType.grief,
          TriggerType.uncertainty,
        ];
    }
  }

  // Get age-appropriate coping strategies
  List<String> getCopingStrategies() {
    switch (lifeStage) {
      case LifeStage.teen:
        return [
          'Talk to a trusted adult or friend',
          'Use deep breathing techniques',
          'Journal your feelings',
          'Take breaks from social media',
          'Get regular exercise',
        ];
      case LifeStage.youngAdult:
        return [
          'Build a support network',
          'Practice work-life balance',
          'Use meditation and mindfulness',
          'Set healthy boundaries',
          'Seek professional help when needed',
        ];
      case LifeStage.adult:
        return [
          'Prioritize self-care',
          'Maintain work-life balance',
          'Stay connected with friends and family',
          'Practice stress management',
          'Seek therapy when needed',
        ];
      case LifeStage.midLife:
        return [
          'Accept change and transition',
          'Focus on meaningful activities',
          'Maintain social connections',
          'Practice mindfulness',
          'Re-evaluate life priorities',
        ];
      case LifeStage.olderAdult:
        return [
          'Stay socially active',
          'Engage in meaningful activities',
          'Practice gratitude',
          'Maintain physical health',
          'Seek support groups',
        ];
      case LifeStage.senior:
        return [
          'Stay connected with community',
          'Engage in gentle exercise',
          'Practice acceptance and contentment',
          'Seek spiritual connection',
          'Share life experience with others',
        ];
    }
  }

  // Get recommended exercise duration based on life stage
  Duration getRecommendedExerciseDuration() {
    switch (lifeStage) {
      case LifeStage.teen:
        return const Duration(minutes: 5);
      case LifeStage.youngAdult:
        return const Duration(minutes: 10);
      case LifeStage.adult:
        return const Duration(minutes: 10);
      case LifeStage.midLife:
        return const Duration(minutes: 15);
      case LifeStage.olderAdult:
        return const Duration(minutes: 15);
      case LifeStage.senior:
        return const Duration(minutes: 20);
    }
  }

  // Get age-appropriate recommendations
  Map<String, dynamic> getRecommendations() {
    return {
      'exerciseTypes': getRecommendedExerciseTypes().map((e) => e.displayName).toList(),
      'commonRisks': getCommonRiskTypes().map((r) => r.displayName).toList(),
      'commonTriggers': getCommonTriggers().map((t) => t.displayName).toList(),
      'copingStrategies': getCopingStrategies(),
      'recommendedDuration': getRecommendedExerciseDuration().inMinutes,
    };
  }

  // Get life stage specific message
  String getWelcomeMessage() {
    switch (lifeStage) {
      case LifeStage.teen:
        return 'Welcome to your teen wellness journey. We understand the unique challenges you face during this transformative time.';
      case LifeStage.youngAdult:
        return 'Welcome to young adulthood! We\'re here to support you in building healthy habits for the future.';
      case LifeStage.adult:
        return 'Welcome! We\'re committed to supporting your mental wellness as you navigate adult life.';
      case LifeStage.midLife:
        return 'Welcome to midlife! We\'re here to support you through life transitions and changes.';
      case LifeStage.olderAdult:
        return 'Welcome! We\'re dedicated to supporting your mental wellness in your golden years.';
      case LifeStage.senior:
        return 'Welcome! We\'re here to support your mental wellness journey in your senior years.';
    }
  }

  // Get resources specific to this life stage
  List<Map<String, String>> getResources() {
    switch (lifeStage) {
      case LifeStage.teen:
        return [
          {'title': 'Teen Mental Health', 'url': 'https://www.nimh.nih.gov/health/topics/teen-mental-health'},
          {'title': 'Crisis Text Line for Teens', 'url': 'https://www.crisistextline.org'},
          {'title': 'JED Foundation', 'url': 'https://www.jedfoundation.org'},
        ];
      case LifeStage.youngAdult:
        return [
          {'title': 'Young Adult Mental Health', 'url': 'https://www.nami.org/Your-Journey/Young-Adults'},
          {'title': 'Active Minds', 'url': 'https://www.activeminds.org'},
          {'title': 'National Suicide Prevention Lifeline', 'url': 'https://988lifeline.org'},
        ];
      case LifeStage.adult:
        return [
          {'title': 'Adult Mental Health Resources', 'url': 'https://www.mhanational.org/adult-mental-health'},
          {'title': 'Psychology Today', 'url': 'https://www.psychologytoday.com'},
          {'title': '988 Suicide & Crisis Lifeline', 'url': 'https://988lifeline.org'},
        ];
      case LifeStage.midLife:
        return [
          {'title': 'Midlife Mental Health', 'url': 'https://www.helpguide.org/articles/aging/midlife-crisis.htm'},
          {'title': 'Men\'s Mental Health', 'url': 'https://www.menshealth.com'},
          {'title': 'Women\'s Mental Health', 'url': 'https://www.womenshealth.gov'},
        ];
      case LifeStage.olderAdult:
        return [
          {'title': 'Senior Mental Health', 'url': 'https://www.nimh.nih.gov/health/topics/older-adults-and-mental-health'},
          {'title': 'AARP Mental Health', 'url': 'https://www.aarp.org/health/mental-health'},
          {'title': 'Elder Helpline', 'url': 'https://www.agingcare.com'},
        ];
      case LifeStage.senior:
        return [
          {'title': 'Mental Health for Seniors', 'url': 'https://www.samhsa.gov/older-adults'},
          {'title': 'Senior Wellness', 'url': 'https://www.ncoa.org/healthy-aging'},
          {'title': 'Alzheimer\'s Support', 'url': 'https://www.alz.org'},
        ];
    }
  }
}
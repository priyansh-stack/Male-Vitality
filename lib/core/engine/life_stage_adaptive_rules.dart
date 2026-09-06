import 'package:flutter/material.dart';
import '../models/life_stage.dart';

enum HealthModuleId {
  dashboard,
  preventiveCare,
  mentalWellness,
  fitnessNutrition,
  sleepOptimizer,
  substanceUse,
  stiAssessment,
  hormoneSexualHealth,
  fertilityTracker,
  medicationManager,
  polypharmacyAlerts,
  telehealth,
  fallDetection,
  cognitiveExercise,
  caregiverPortal,
}

class ModuleMetadata {
  final HealthModuleId id;
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color accentColor;

  const ModuleMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.accentColor,
  });
}

class LifeStageAdaptiveRules {
  static const Map<HealthModuleId, ModuleMetadata> allModules = {
    HealthModuleId.dashboard: ModuleMetadata(
      id: HealthModuleId.dashboard,
      title: 'Health Dashboard',
      description: 'Vital signs, daily score, and today\'s focus.',
      icon: Icons.dashboard_rounded,
      route: '/dashboard',
      accentColor: Color(0xFF3B82F6),
    ),
    HealthModuleId.preventiveCare: ModuleMetadata(
      id: HealthModuleId.preventiveCare,
      title: 'Preventive Care',
      description: 'USPSTF & CDC clinical screening schedules and reminders.',
      icon: Icons.health_and_safety_rounded,
      route: '/preventive-care',
      accentColor: Color(0xFF10B981),
    ),
    HealthModuleId.mentalWellness: ModuleMetadata(
      id: HealthModuleId.mentalWellness,
      title: 'Mental Wellness',
      description: 'PHQ-2, GAD-2 mood checks, breathing exercises, and crisis help.',
      icon: Icons.psychology_rounded,
      route: '/wellness',
      accentColor: Color(0xFF8B5CF6),
    ),
    HealthModuleId.fitnessNutrition: ModuleMetadata(
      id: HealthModuleId.fitnessNutrition,
      title: 'Fitness & Nutrition',
      description: 'Age-appropriate workout routines, macro goals, and hydration.',
      icon: Icons.fitness_center_rounded,
      route: '/fitness-nutrition',
      accentColor: Color(0xFFF97316),
    ),
    HealthModuleId.sleepOptimizer: ModuleMetadata(
      id: HealthModuleId.sleepOptimizer,
      title: 'Sleep Optimizer',
      description: 'Circadian tracking, smart wake targets, and sleep hygiene.',
      icon: Icons.bedtime_rounded,
      route: '/sleep-optimizer',
      accentColor: Color(0xFF6366F1),
    ),
    HealthModuleId.substanceUse: ModuleMetadata(
      id: HealthModuleId.substanceUse,
      title: 'Substance & Alcohol Assessment',
      description: 'AUDIT-C screening, harm reduction, and SAMHSA helpline.',
      icon: Icons.local_bar_rounded,
      route: '/substance-assessment',
      accentColor: Color(0xFFEC4899),
    ),
    HealthModuleId.stiAssessment: ModuleMetadata(
      id: HealthModuleId.stiAssessment,
      title: 'STI Risk & Testing Locator',
      description: 'Confidential risk evaluation and free test center discovery.',
      icon: Icons.shield_rounded,
      route: '/sexual-health/sti',
      accentColor: Color(0xFFE11D48),
    ),
    HealthModuleId.hormoneSexualHealth: ModuleMetadata(
      id: HealthModuleId.hormoneSexualHealth,
      title: 'Hormone & Sexual Health',
      description: 'Testosterone ADAM score, ED causes, prostate health, and fertility.',
      icon: Icons.male_rounded,
      route: '/sexual-health',
      accentColor: Color(0xFF2563EB),
    ),
    HealthModuleId.fertilityTracker: ModuleMetadata(
      id: HealthModuleId.fertilityTracker,
      title: 'Male Fertility Guide',
      description: 'Sperm quality optimization, motility factors, and specialist advice.',
      icon: Icons.child_care_rounded,
      route: '/sexual-health/fertility',
      accentColor: Color(0xFF14B8A6),
    ),
    HealthModuleId.medicationManager: ModuleMetadata(
      id: HealthModuleId.medicationManager,
      title: 'Medication Manager',
      description: 'Dosage reminders, refill tracking, and adherence logs.',
      icon: Icons.medication_rounded,
      route: '/medications',
      accentColor: Color(0xFF0284C7),
    ),
    HealthModuleId.polypharmacyAlerts: ModuleMetadata(
      id: HealthModuleId.polypharmacyAlerts,
      title: 'Drug Interaction & Polypharmacy',
      description: 'Automated 5+ drug interaction safety and contraindication alerts.',
      icon: Icons.warning_amber_rounded,
      route: '/medications/interactions',
      accentColor: Color(0xFFDC2626),
    ),
    HealthModuleId.telehealth: ModuleMetadata(
      id: HealthModuleId.telehealth,
      title: 'Telehealth & Provider Consult',
      description: 'Video consults with urologists and comprehensive PDF summary sharing.',
      icon: Icons.video_camera_front_rounded,
      route: '/telehealth',
      accentColor: Color(0xFF059669),
    ),
    HealthModuleId.fallDetection: ModuleMetadata(
      id: HealthModuleId.fallDetection,
      title: 'Fall Detection & Safety',
      description: 'Sensor-based fall monitor and instant emergency contact alerts.',
      icon: Icons.personal_injury_rounded,
      route: '/senior-care/fall-detection',
      accentColor: Color(0xFFEF4444),
    ),
    HealthModuleId.cognitiveExercise: ModuleMetadata(
      id: HealthModuleId.cognitiveExercise,
      title: 'Cognitive Brain Training',
      description: 'Daily memory, processing speed, and neuro-plasticity exercises.',
      icon: Icons.extension_rounded,
      route: '/senior-care/brain-training',
      accentColor: Color(0xFF7C3AED),
    ),
    HealthModuleId.caregiverPortal: ModuleMetadata(
      id: HealthModuleId.caregiverPortal,
      title: 'Caregiver Portal',
      description: 'Delegated read/collaborative dashboard for family and caregivers.',
      icon: Icons.supervisor_account_rounded,
      route: '/senior-care/caregiver',
      accentColor: Color(0xFF4B5563),
    ),
  };

  /// Returns whether a feature module is enabled by default for a life stage (PRD Table Section 7)
  static bool isModuleEnabledByDefault(LifeStage stage, HealthModuleId moduleId) {
    switch (moduleId) {
      case HealthModuleId.dashboard:
      case HealthModuleId.preventiveCare:
      case HealthModuleId.mentalWellness:
      case HealthModuleId.fitnessNutrition:
      case HealthModuleId.sleepOptimizer:
        return true;

      case HealthModuleId.substanceUse:
      case HealthModuleId.stiAssessment:
        // Enabled for Teen, Young Adult, Adult (13–39)
        return stage == LifeStage.teen ||
            stage == LifeStage.youngAdult ||
            stage == LifeStage.adult;

      case HealthModuleId.hormoneSexualHealth:
        // Enabled for 26+
        return stage != LifeStage.teen && stage != LifeStage.youngAdult;

      case HealthModuleId.fertilityTracker:
        // Enabled for Adult & Mid-Life (26–54)
        return stage == LifeStage.adult || stage == LifeStage.midLife;

      case HealthModuleId.medicationManager:
        // Enabled for Mid-Life, Older Adult, Senior (40+)
        return stage == LifeStage.midLife ||
            stage == LifeStage.olderAdult ||
            stage == LifeStage.senior;

      case HealthModuleId.polypharmacyAlerts:
      case HealthModuleId.cognitiveExercise:
      case HealthModuleId.caregiverPortal:
        // Enabled for 55+
        return stage == LifeStage.olderAdult || stage == LifeStage.senior;

      case HealthModuleId.telehealth:
        // Enabled for 18+
        return stage != LifeStage.teen;

      case HealthModuleId.fallDetection:
        // Senior 70+
        return stage == LifeStage.senior;
    }
  }

  /// Returns the ordered list of enabled modules for a user's life stage
  static List<ModuleMetadata> getModulesForStage(LifeStage stage) {
    return allModules.values
        .where((module) => isModuleEnabledByDefault(stage, module.id))
        .toList();
  }

  /// Returns life-stage priority headline for the dashboard
  static String getLifeStageFocusHeadline(LifeStage stage) {
    switch (stage) {
      case LifeStage.teen:
        return 'Growth, Mental Resilience & Athletic Safety';
      case LifeStage.youngAdult:
        return 'Cardiovascular Baseline, Habit Building & Safe Living';
      case LifeStage.adult:
        return 'Metabolic Health, Stress Mitigation & Hormone Vigilance';
      case LifeStage.midLife:
        return 'Cardiovascular Defense, Prostate & Diabetes Screening';
      case LifeStage.olderAdult:
        return 'Cancer Screening, Bone Density & Medication Stewardship';
      case LifeStage.senior:
        return 'Cognitive Sharpness, Fall Prevention & Polypharmacy Safety';
    }
  }
}

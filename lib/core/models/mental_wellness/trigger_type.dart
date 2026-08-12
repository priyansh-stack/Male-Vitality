import 'package:flutter/material.dart';

enum TriggerType {
  stress,
  sleep,
  relationships,
  work,
  health,
  nutrition,
  exercise,
  financial,
  social,
  trauma,
  seasonal,
  hormonal,
  medication,
  substance,
  weather,
  travel,
  conflict,
  loneliness,
  overstimulation,
  uncertainty, grief,
}

extension TriggerTypeExtension on TriggerType {
  String get displayName {
    switch (this) {
      case TriggerType.stress:
        return 'Stress';
      case TriggerType.sleep:
        return 'Sleep Issues';
      case TriggerType.relationships:
        return 'Relationships';
      case TriggerType.work:
        return 'Work';
      case TriggerType.health:
        return 'Health Concerns';
      case TriggerType.nutrition:
        return 'Nutrition';
      case TriggerType.exercise:
        return 'Exercise';
      case TriggerType.financial:
        return 'Financial';
      case TriggerType.social:
        return 'Social';
      case TriggerType.trauma:
        return 'Trauma';
      case TriggerType.seasonal:
        return 'Seasonal Changes';
      case TriggerType.hormonal:
        return 'Hormonal Changes';
      case TriggerType.medication:
        return 'Medication';
      case TriggerType.substance:
        return 'Substance Use';
      case TriggerType.weather:
        return 'Weather';
      case TriggerType.travel:
        return 'Travel';
      case TriggerType.conflict:
        return 'Conflict';
      case TriggerType.loneliness:
        return 'Loneliness';
      case TriggerType.overstimulation:
        return 'Overstimulation';
      case TriggerType.uncertainty:
        return 'Uncertainty';
      case TriggerType.grief:
        return 'Greif';
    }
  }

  String get shortName {
    switch (this) {
      case TriggerType.stress:
        return 'Stress';
      case TriggerType.sleep:
        return 'Sleep';
      case TriggerType.relationships:
        return 'Relationships';
      case TriggerType.work:
        return 'Work';
      case TriggerType.health:
        return 'Health';
      case TriggerType.nutrition:
        return 'Nutrition';
      case TriggerType.exercise:
        return 'Exercise';
      case TriggerType.financial:
        return 'Financial';
      case TriggerType.social:
        return 'Social';
      case TriggerType.trauma:
        return 'Trauma';
      case TriggerType.seasonal:
        return 'Seasonal';
      case TriggerType.hormonal:
        return 'Hormonal';
      case TriggerType.medication:
        return 'Medication';
      case TriggerType.substance:
        return 'Substance';
      case TriggerType.weather:
        return 'Weather';
      case TriggerType.travel:
        return 'Travel';
      case TriggerType.conflict:
        return 'Conflict';
      case TriggerType.loneliness:
        return 'Loneliness';
      case TriggerType.overstimulation:
        return 'Overstimulation';
      case TriggerType.uncertainty:
        return 'Uncertainty';
      case TriggerType.grief:
        return 'Greif';
    }
  }

  IconData get icon {
    switch (this) {
      case TriggerType.stress:
        return Icons.stream;
      case TriggerType.sleep:
        return Icons.bedtime;
      case TriggerType.relationships:
        return Icons.people;
      case TriggerType.work:
        return Icons.work;
      case TriggerType.health:
        return Icons.health_and_safety;
      case TriggerType.nutrition:
        return Icons.restaurant;
      case TriggerType.exercise:
        return Icons.fitness_center;
      case TriggerType.financial:
        return Icons.attach_money;
      case TriggerType.social:
        return Icons.group;
      case TriggerType.trauma:
        return Icons.warning;
      case TriggerType.seasonal:
        return Icons.wb_sunny;
      case TriggerType.hormonal:
        return Icons.cable;
      case TriggerType.medication:
        return Icons.medication;
      case TriggerType.substance:
        return Icons.local_drink;
      case TriggerType.weather:
        return Icons.cloud;
      case TriggerType.travel:
        return Icons.flight;
      case TriggerType.conflict:
        return Icons.developer_mode;
      case TriggerType.loneliness:
        return Icons.person_off;
      case TriggerType.overstimulation:
        return Icons.volume_up;
      case TriggerType.uncertainty:
        return Icons.question_mark;
      case TriggerType.grief:
        return Icons.blur_circular;
    }
  }

  Color get color {
    switch (this) {
      case TriggerType.stress:
        return Color(0xFFEF4444);
      case TriggerType.sleep:
        return Color(0xFF6366F1);
      case TriggerType.relationships:
        return Color(0xFFEC4899);
      case TriggerType.work:
        return Color(0xFFF59E0B);
      case TriggerType.health:
        return Color(0xFF10B981);
      case TriggerType.nutrition:
        return Color(0xFF8B5CF6);
      case TriggerType.exercise:
        return Color(0xFF06B6D4);
      case TriggerType.financial:
        return Color(0xFF3B82F6);
      case TriggerType.social:
        return Color(0xFF14B8A6);
      case TriggerType.trauma:
        return Color(0xFFDC2626);
      case TriggerType.seasonal:
        return Color(0xFFF472B6);
      case TriggerType.hormonal:
        return Color(0xFF8B5CF6);
      case TriggerType.medication:
        return Color(0xFF6366F1);
      case TriggerType.substance:
        return Color(0xFFF59E0B);
      case TriggerType.weather:
        return Color(0xFF60A5FA);
      case TriggerType.travel:
        return Color(0xFF34D399);
      case TriggerType.conflict:
        return Color(0xFFEF4444);
      case TriggerType.loneliness:
        return Color(0xFF6B7280);
      case TriggerType.overstimulation:
        return Color(0xFFF97316);
      case TriggerType.uncertainty:
        return Color(0xFF8B5CF6);
      case TriggerType.grief:
        return Color.fromARGB(0, 0, 0, 0);
    }
  }

  List<String> get copingStrategies {
    switch (this) {
      case TriggerType.stress:
        return ['Deep breathing', 'Meditation', 'Take a break'];
      case TriggerType.sleep:
        return ['Sleep hygiene', 'Relaxation routine', 'Avoid screens'];
      case TriggerType.relationships:
        return ['Open communication', 'Boundaries', 'Seek support'];
      case TriggerType.work:
        return ['Time management', 'Take breaks', 'Set boundaries'];
      case TriggerType.health:
        return ['Consult doctor', 'Self-care', 'Rest'];
      case TriggerType.nutrition:
        return ['Balanced diet', 'Hydrate', 'Mindful eating'];
      case TriggerType.exercise:
        return ['Get moving', 'Stretch', 'Walk'];
      case TriggerType.financial:
        return ['Budgeting', 'Financial planning', 'Seek advice'];
      case TriggerType.social:
        return ['Connect with others', 'Join groups', 'Reach out'];
      case TriggerType.trauma:
        return ['Seek therapy', 'Grounding techniques', 'Support groups'];
      case TriggerType.seasonal:
        return ['Light therapy', 'Outdoor time', 'Stay active'];
      case TriggerType.hormonal:
        return ['Medical consult', 'Self-care', 'Rest'];
      case TriggerType.medication:
        return ['Consult doctor', 'Follow schedule', 'Monitor effects'];
      case TriggerType.substance:
        return ['Seek support', 'Professional help', 'Avoid triggers'];
      case TriggerType.weather:
        return ['Stay indoors', 'Self-care', 'Plan activities'];
      case TriggerType.travel:
        return ['Plan ahead', 'Rest', 'Stay hydrated'];
      case TriggerType.conflict:
        return ['Take a break', 'Communicate', 'Seek mediation'];
      case TriggerType.loneliness:
        return ['Connect with others', 'Volunteer', 'Join groups'];
      case TriggerType.overstimulation:
        return ['Quiet time', 'Limit exposure', 'Deep breathing'];
      case TriggerType.uncertainty:
        return ['Focus on what you control', 'Plan', 'Stay present'];
      case TriggerType.grief:
        return ['Stay Still','Try Deep Breathing'];
    }
  }
}
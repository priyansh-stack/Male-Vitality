import 'package:flutter/material.dart';

enum RiskType {
  depression,
  anxiety,
  suicidal,
  panic,
  stress,
  burnout,
  ptsd,
  ocd,
  eatingDisorder,
  substanceUse,
  grief,
  anger,
}

extension RiskTypeExtension on RiskType {
  String get displayName {
    switch (this) {
      case RiskType.depression:
        return 'Depression';
      case RiskType.anxiety:
        return 'Anxiety';
      case RiskType.suicidal:
        return 'Suicidal Ideation';
      case RiskType.panic:
        return 'Panic Disorder';
      case RiskType.stress:
        return 'Chronic Stress';
      case RiskType.burnout:
        return 'Burnout';
      case RiskType.ptsd:
        return 'PTSD';
      case RiskType.ocd:
        return 'OCD';
      case RiskType.eatingDisorder:
        return 'Eating Disorder';
      case RiskType.substanceUse:
        return 'Substance Use';
      case RiskType.grief:
        return 'Grief';
      case RiskType.anger:
        return 'Anger Management';
    }
  }

  String get shortName {
    switch (this) {
      case RiskType.depression:
        return 'Depression';
      case RiskType.anxiety:
        return 'Anxiety';
      case RiskType.suicidal:
        return 'Suicidal';
      case RiskType.panic:
        return 'Panic';
      case RiskType.stress:
        return 'Stress';
      case RiskType.burnout:
        return 'Burnout';
      case RiskType.ptsd:
        return 'PTSD';
      case RiskType.ocd:
        return 'OCD';
      case RiskType.eatingDisorder:
        return 'Eating';
      case RiskType.substanceUse:
        return 'Substance';
      case RiskType.grief:
        return 'Grief';
      case RiskType.anger:
        return 'Anger';
    }
  }

  Color get color {
    switch (this) {
      case RiskType.depression:
        return Color(0xFF6366F1);
      case RiskType.anxiety:
        return Color(0xFFF59E0B);
      case RiskType.suicidal:
        return Color(0xFFDC2626);
      case RiskType.panic:
        return Color(0xFFEC4899);
      case RiskType.stress:
        return Color(0xFFF97316);
      case RiskType.burnout:
        return Color(0xFF8B5CF6);
      case RiskType.ptsd:
        return Color(0xFFEF4444);
      case RiskType.ocd:
        return Color(0xFF3B82F6);
      case RiskType.eatingDisorder:
        return Color(0xFF8B5CF6);
      case RiskType.substanceUse:
        return Color(0xFFF59E0B);
      case RiskType.grief:
        return Color(0xFF6B7280);
      case RiskType.anger:
        return Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (this) {
      case RiskType.depression:
        return Icons.sentiment_dissatisfied;
      case RiskType.anxiety:
        return Icons.psychology;
      case RiskType.suicidal:
        return Icons.warning_amber;
      case RiskType.panic:
        return Icons.flash_on;
      case RiskType.stress:
        return Icons.stream;
      case RiskType.burnout:
        return Icons.battery_alert;
      case RiskType.ptsd:
        return Icons.bolt;
      case RiskType.ocd:
        return Icons.autorenew;
      case RiskType.eatingDisorder:
        return Icons.restaurant;
      case RiskType.substanceUse:
        return Icons.local_drink;
      case RiskType.grief:
        return Icons.heart_broken;
      case RiskType.anger:
        return Icons.whatshot;
    }
  }

  String get description {
    switch (this) {
      case RiskType.depression:
        return 'Persistent feelings of sadness, hopelessness, and loss of interest';
      case RiskType.anxiety:
        return 'Excessive worry, fear, and nervousness';
      case RiskType.suicidal:
        return 'Thoughts of self-harm or ending one\'s life';
      case RiskType.panic:
        return 'Sudden episodes of intense fear with physical symptoms';
      case RiskType.stress:
        return 'Chronic stress affecting daily functioning';
      case RiskType.burnout:
        return 'Emotional, physical, and mental exhaustion';
      case RiskType.ptsd:
        return 'Trauma-related stress disorder';
      case RiskType.ocd:
        return 'Obsessive thoughts and compulsive behaviors';
      case RiskType.eatingDisorder:
        return 'Disordered eating patterns and body image issues';
      case RiskType.substanceUse:
        return 'Harmful use of substances like alcohol or drugs';
      case RiskType.grief:
        return 'Intense mourning and loss';
      case RiskType.anger:
        return 'Difficulty controlling anger and aggression';
    }
  }

  List<String> get warningSigns {
    switch (this) {
      case RiskType.depression:
        return [
          'Changes in sleep or appetite',
          'Loss of interest in activities',
          'Fatigue or low energy',
          'Difficulty concentrating',
        ];
      case RiskType.anxiety:
        return [
          'Excessive worry',
          'Restlessness or feeling on edge',
          'Muscle tension',
          'Difficulty sleeping',
        ];
      case RiskType.suicidal:
        return [
          'Talking about wanting to die',
          'Feeling hopeless or trapped',
          'Withdrawing from others',
          'Extreme mood swings',
        ];
      case RiskType.panic:
        return [
          'Sudden intense fear',
          'Heart palpitations',
          'Shortness of breath',
          'Feeling of losing control',
        ];
      case RiskType.stress:
        return [
          'Irritability',
          'Headaches',
          'Sleep problems',
          'Difficulty relaxing',
        ];
      case RiskType.burnout:
        return [
          'Exhaustion',
          'Cynicism',
          'Reduced performance',
          'Feeling overwhelmed',
        ];
      default:
        return ['Seek professional evaluation for proper diagnosis'];
    }
  }
}
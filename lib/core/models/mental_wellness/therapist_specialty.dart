import 'package:flutter/material.dart';

enum TherapistSpecialty {
  cbt,
  dbt,
  trauma,
  family,
  addiction,
  anxiety,
  depression,
  ptsd,
  ocd,
  adhd,
  eatingDisorder,
  grief,
  couples,
  child,
  adolescent,
  senior,
  lgbtq,
  veterans,
  chronicIllness,
  perinatal,
  angerManagement,
  selfEsteem,
  mindfulness,
  solutionFocused,
  psychodynamic,
}

extension TherapistSpecialtyExtension on TherapistSpecialty {
  String get displayName {
    switch (this) {
      case TherapistSpecialty.cbt:
        return 'Cognitive Behavioral Therapy (CBT)';
      case TherapistSpecialty.dbt:
        return 'Dialectical Behavior Therapy (DBT)';
      case TherapistSpecialty.trauma:
        return 'Trauma Therapy';
      case TherapistSpecialty.family:
        return 'Family Therapy';
      case TherapistSpecialty.addiction:
        return 'Addiction Counseling';
      case TherapistSpecialty.anxiety:
        return 'Anxiety Treatment';
      case TherapistSpecialty.depression:
        return 'Depression Treatment';
      case TherapistSpecialty.ptsd:
        return 'PTSD Treatment';
      case TherapistSpecialty.ocd:
        return 'OCD Treatment';
      case TherapistSpecialty.adhd:
        return 'ADHD Management';
      case TherapistSpecialty.eatingDisorder:
        return 'Eating Disorder Treatment';
      case TherapistSpecialty.grief:
        return 'Grief Counseling';
      case TherapistSpecialty.couples:
        return 'Couples Therapy';
      case TherapistSpecialty.child:
        return 'Child Therapy';
      case TherapistSpecialty.adolescent:
        return 'Adolescent Therapy';
      case TherapistSpecialty.senior:
        return 'Senior Mental Health';
      case TherapistSpecialty.lgbtq:
        return 'LGBTQ+ Affirming Therapy';
      case TherapistSpecialty.veterans:
        return 'Veterans Mental Health';
      case TherapistSpecialty.chronicIllness:
        return 'Chronic Illness Support';
      case TherapistSpecialty.perinatal:
        return 'Perinatal Mental Health';
      case TherapistSpecialty.angerManagement:
        return 'Anger Management';
      case TherapistSpecialty.selfEsteem:
        return 'Self-Esteem Building';
      case TherapistSpecialty.mindfulness:
        return 'Mindfulness-Based Therapy';
      case TherapistSpecialty.solutionFocused:
        return 'Solution-Focused Therapy';
      case TherapistSpecialty.psychodynamic:
        return 'Psychodynamic Therapy';
    }
  }

  String get shortName {
    switch (this) {
      case TherapistSpecialty.cbt:
        return 'CBT';
      case TherapistSpecialty.dbt:
        return 'DBT';
      case TherapistSpecialty.trauma:
        return 'Trauma';
      case TherapistSpecialty.family:
        return 'Family';
      case TherapistSpecialty.addiction:
        return 'Addiction';
      case TherapistSpecialty.anxiety:
        return 'Anxiety';
      case TherapistSpecialty.depression:
        return 'Depression';
      case TherapistSpecialty.ptsd:
        return 'PTSD';
      case TherapistSpecialty.ocd:
        return 'OCD';
      case TherapistSpecialty.adhd:
        return 'ADHD';
      case TherapistSpecialty.eatingDisorder:
        return 'Eating';
      case TherapistSpecialty.grief:
        return 'Grief';
      case TherapistSpecialty.couples:
        return 'Couples';
      case TherapistSpecialty.child:
        return 'Child';
      case TherapistSpecialty.adolescent:
        return 'Adolescent';
      case TherapistSpecialty.senior:
        return 'Senior';
      case TherapistSpecialty.lgbtq:
        return 'LGBTQ+';
      case TherapistSpecialty.veterans:
        return 'Veterans';
      case TherapistSpecialty.chronicIllness:
        return 'Chronic Illness';
      case TherapistSpecialty.perinatal:
        return 'Perinatal';
      case TherapistSpecialty.angerManagement:
        return 'Anger';
      case TherapistSpecialty.selfEsteem:
        return 'Self-Esteem';
      case TherapistSpecialty.mindfulness:
        return 'Mindfulness';
      case TherapistSpecialty.solutionFocused:
        return 'SFBT';
      case TherapistSpecialty.psychodynamic:
        return 'Psychodynamic';
    }
  }

  IconData get icon {
    switch (this) {
      case TherapistSpecialty.cbt:
        return Icons.psychology;
      case TherapistSpecialty.dbt:
        return Icons.balance;
      case TherapistSpecialty.trauma:
        return Icons.warning;
      case TherapistSpecialty.family:
        return Icons.family_restroom;
      case TherapistSpecialty.addiction:
        return Icons.local_drink;
      case TherapistSpecialty.anxiety:
        return Icons.psychology;
      case TherapistSpecialty.depression:
        return Icons.sentiment_dissatisfied;
      case TherapistSpecialty.ptsd:
        return Icons.bolt;
      case TherapistSpecialty.ocd:
        return Icons.autorenew;
      case TherapistSpecialty.adhd:
        return Icons.attractions;
      case TherapistSpecialty.eatingDisorder:
        return Icons.restaurant;
      case TherapistSpecialty.grief:
        return Icons.heart_broken;
      case TherapistSpecialty.couples:
        return Icons.people;
      case TherapistSpecialty.child:
        return Icons.face_3;
      case TherapistSpecialty.adolescent:
        return Icons.face_4;
      case TherapistSpecialty.senior:
        return Icons.face_5;
      case TherapistSpecialty.lgbtq:
        return Icons.seven_mp;
      case TherapistSpecialty.veterans:
        return Icons.mail;
      case TherapistSpecialty.chronicIllness:
        return Icons.health_and_safety;
      case TherapistSpecialty.perinatal:
        return Icons.pregnant_woman;
      case TherapistSpecialty.angerManagement:
        return Icons.whatshot;
      case TherapistSpecialty.selfEsteem:
        return Icons.thumb_up;
      case TherapistSpecialty.mindfulness:
        return Icons.spa;
      case TherapistSpecialty.solutionFocused:
        return Icons.lightbulb;
      case TherapistSpecialty.psychodynamic:
        return Icons.psychology;
    }
  }

  Color get color {
    switch (this) {
      case TherapistSpecialty.cbt:
        return Color(0xFF6366F1);
      case TherapistSpecialty.dbt:
        return Color(0xFF8B5CF6);
      case TherapistSpecialty.trauma:
        return Color(0xFFEF4444);
      case TherapistSpecialty.family:
        return Color(0xFFF59E0B);
      case TherapistSpecialty.addiction:
        return Color(0xFFF97316);
      case TherapistSpecialty.anxiety:
        return Color(0xFF06B6D4);
      case TherapistSpecialty.depression:
        return Color(0xFF6366F1);
      case TherapistSpecialty.ptsd:
        return Color(0xFFDC2626);
      case TherapistSpecialty.ocd:
        return Color(0xFF3B82F6);
      case TherapistSpecialty.adhd:
        return Color(0xFF10B981);
      case TherapistSpecialty.eatingDisorder:
        return Color(0xFFEC4899);
      case TherapistSpecialty.grief:
        return Color(0xFF6B7280);
      case TherapistSpecialty.couples:
        return Color(0xFFEC4899);
      case TherapistSpecialty.child:
        return Color(0xFF06B6D4);
      case TherapistSpecialty.adolescent:
        return Color(0xFFF59E0B);
      case TherapistSpecialty.senior:
        return Color(0xFF6366F1);
      case TherapistSpecialty.lgbtq:
        return Color(0xFFEC4899);
      case TherapistSpecialty.veterans:
        return Color(0xFF10B981);
      case TherapistSpecialty.chronicIllness:
        return Color(0xFF8B5CF6);
      case TherapistSpecialty.perinatal:
        return Color(0xFFF472B6);
      case TherapistSpecialty.angerManagement:
        return Color(0xFFDC2626);
      case TherapistSpecialty.selfEsteem:
        return Color(0xFF10B981);
      case TherapistSpecialty.mindfulness:
        return Color(0xFF06B6D4);
      case TherapistSpecialty.solutionFocused:
        return Color(0xFFF59E0B);
      case TherapistSpecialty.psychodynamic:
        return Color(0xFF6366F1);
    }
  }

  String get description {
    switch (this) {
      case TherapistSpecialty.cbt:
        return 'Focuses on identifying and changing negative thought patterns';
      case TherapistSpecialty.dbt:
        return 'Combines CBT with mindfulness for emotional regulation';
      case TherapistSpecialty.trauma:
        return 'Specialized treatment for trauma and PTSD';
      case TherapistSpecialty.family:
        return 'Addresses family dynamics and relationships';
      case TherapistSpecialty.addiction:
        return 'Treatment for substance use and behavioral addictions';
      case TherapistSpecialty.anxiety:
        return 'Specialized treatment for anxiety disorders';
      case TherapistSpecialty.depression:
        return 'Treatment for depression and mood disorders';
      case TherapistSpecialty.ptsd:
        return 'Specialized treatment for post-traumatic stress disorder';
      case TherapistSpecialty.ocd:
        return 'Treatment for obsessive-compulsive disorder';
      case TherapistSpecialty.adhd:
        return 'Management of ADHD symptoms and challenges';
      case TherapistSpecialty.eatingDisorder:
        return 'Treatment for eating disorders and body image issues';
      case TherapistSpecialty.grief:
        return 'Support for loss and bereavement';
      case TherapistSpecialty.couples:
        return 'Relationship counseling for couples';
      case TherapistSpecialty.child:
        return 'Mental health support for children';
      case TherapistSpecialty.adolescent:
        return 'Mental health support for teenagers';
      case TherapistSpecialty.senior:
        return 'Mental health support for older adults';
      case TherapistSpecialty.lgbtq:
        return 'Affirming therapy for LGBTQ+ individuals';
      case TherapistSpecialty.veterans:
        return 'Mental health support for veterans';
      case TherapistSpecialty.chronicIllness:
        return 'Support for living with chronic illness';
      case TherapistSpecialty.perinatal:
        return 'Mental health support during pregnancy and postpartum';
      case TherapistSpecialty.angerManagement:
        return 'Techniques for managing anger and aggression';
      case TherapistSpecialty.selfEsteem:
        return 'Building self-confidence and self-worth';
      case TherapistSpecialty.mindfulness:
        return 'Using mindfulness techniques for mental health';
      case TherapistSpecialty.solutionFocused:
        return 'Goal-oriented, brief therapy approach';
      case TherapistSpecialty.psychodynamic:
        return 'Explores unconscious patterns and past experiences';
    }
  }

  List<String> get commonTechniques {
    switch (this) {
      case TherapistSpecialty.cbt:
        return ['Cognitive restructuring', 'Behavioral activation', 'Exposure therapy'];
      case TherapistSpecialty.dbt:
        return ['Mindfulness', 'Distress tolerance', 'Emotion regulation'];
      case TherapistSpecialty.trauma:
        return ['EMDR', 'Trauma-focused CBT', 'Somatic experiencing'];
      case TherapistSpecialty.family:
        return ['Family systems therapy', 'Communication training'];
      case TherapistSpecialty.addiction:
        return ['Motivational interviewing', 'Relapse prevention'];
      case TherapistSpecialty.anxiety:
        return ['Exposure therapy', 'Acceptance and commitment therapy'];
      case TherapistSpecialty.depression:
        return ['Behavioral activation', 'Cognitive restructuring'];
      case TherapistSpecialty.ptsd:
        return ['Prolonged exposure', 'EMDR', 'Trauma-focused CBT'];
      case TherapistSpecialty.ocd:
        return ['Exposure and response prevention'];
      case TherapistSpecialty.adhd:
        return ['Skill building', 'Time management', 'Executive functioning'];
      case TherapistSpecialty.eatingDisorder:
        return ['CBT', 'Family-based therapy', 'Nutrition counseling'];
      case TherapistSpecialty.grief:
        return ['Complicated grief therapy', 'Supportive counseling'];
      case TherapistSpecialty.couples:
        return ['Gottman method', 'Emotionally focused therapy'];
      case TherapistSpecialty.child:
        return ['Play therapy', 'Art therapy'];
      case TherapistSpecialty.adolescent:
        return ['CBT', 'Motivational interviewing'];
      case TherapistSpecialty.senior:
        return ['Life review therapy', 'Problem-solving therapy'];
      case TherapistSpecialty.lgbtq:
        return ['Affirming therapy', 'Identity development'];
      case TherapistSpecialty.veterans:
        return ['Prolonged exposure', 'Cognitive processing therapy'];
      case TherapistSpecialty.chronicIllness:
        return ['Acceptance and commitment therapy', 'Mindfulness'];
      case TherapistSpecialty.perinatal:
        return ['CBT', 'Interpersonal therapy'];
      case TherapistSpecialty.angerManagement:
        return ['Cognitive restructuring', 'Relaxation training'];
      case TherapistSpecialty.selfEsteem:
        return ['Positive affirmations', 'Strengths-based therapy'];
      case TherapistSpecialty.mindfulness:
        return ['Mindfulness-Based Stress Reduction', 'Meditation'];
      case TherapistSpecialty.solutionFocused:
        return ['Goal setting', 'Scaling questions'];
      case TherapistSpecialty.psychodynamic:
        return ['Free association', 'Dream analysis'];
    }
  }
}
import 'package:flutter/material.dart';

enum ExerciseType {
  meditation,
  breathing,
  cbt,
  journaling,
  mindfulness,
  progressiveRelaxation,
  visualization,
  gratitude,
  affirmations,
  bodyScan,
  yoga,
  taiChi,
}

extension ExerciseTypeExtension on ExerciseType {
  String get displayName {
    switch (this) {
      case ExerciseType.meditation:
        return 'Meditation';
      case ExerciseType.breathing:
        return 'Breathing';
      case ExerciseType.cbt:
        return 'CBT';
      case ExerciseType.journaling:
        return 'Journaling';
      case ExerciseType.mindfulness:
        return 'Mindfulness';
      case ExerciseType.progressiveRelaxation:
        return 'Progressive Relaxation';
      case ExerciseType.visualization:
        return 'Visualization';
      case ExerciseType.gratitude:
        return 'Gratitude';
      case ExerciseType.affirmations:
        return 'Affirmations';
      case ExerciseType.bodyScan:
        return 'Body Scan';
      case ExerciseType.yoga:
        return 'Yoga';
      case ExerciseType.taiChi:
        return 'Tai Chi';
    }
  }

  String get shortName {
    switch (this) {
      case ExerciseType.meditation:
        return 'Meditate';
      case ExerciseType.breathing:
        return 'Breathe';
      case ExerciseType.cbt:
        return 'CBT';
      case ExerciseType.journaling:
        return 'Journal';
      case ExerciseType.mindfulness:
        return 'Mindful';
      case ExerciseType.progressiveRelaxation:
        return 'Relax';
      case ExerciseType.visualization:
        return 'Visualize';
      case ExerciseType.gratitude:
        return 'Grateful';
      case ExerciseType.affirmations:
        return 'Affirm';
      case ExerciseType.bodyScan:
        return 'Body Scan';
      case ExerciseType.yoga:
        return 'Yoga';
      case ExerciseType.taiChi:
        return 'Tai Chi';
    }
  }

  IconData get icon {
    switch (this) {
      case ExerciseType.meditation:
        return Icons.self_improvement;
      case ExerciseType.breathing:
        return Icons.air;
      case ExerciseType.cbt:
        return Icons.psychology;
      case ExerciseType.journaling:
        return Icons.edit_note;
      case ExerciseType.mindfulness:
        return Icons.spa;
      case ExerciseType.progressiveRelaxation:
        return Icons.bedtime;
      case ExerciseType.visualization:
        return Icons.visibility;
      case ExerciseType.gratitude:
        return Icons.favorite;
      case ExerciseType.affirmations:
        return Icons.record_voice_over;
      case ExerciseType.bodyScan:
        return Icons.sensors;
      case ExerciseType.yoga:
        return Icons.accessibility_new;
      case ExerciseType.taiChi:
        return Icons.self_improvement;
    }
  }

  Color get color {
    switch (this) {
      case ExerciseType.meditation:
        return Color(0xFF6366F1);
      case ExerciseType.breathing:
        return Color(0xFF06B6D4);
      case ExerciseType.cbt:
        return Color(0xFF8B5CF6);
      case ExerciseType.journaling:
        return Color(0xFFF59E0B);
      case ExerciseType.mindfulness:
        return Color(0xFF10B981);
      case ExerciseType.progressiveRelaxation:
        return Color(0xFFEC4899);
      case ExerciseType.visualization:
        return Color(0xFF3B82F6);
      case ExerciseType.gratitude:
        return Color(0xFFF472B6);
      case ExerciseType.affirmations:
        return Color(0xFF8B5CF6);
      case ExerciseType.bodyScan:
        return Color(0xFF14B8A6);
      case ExerciseType.yoga:
        return Color(0xFFF59E0B);
      case ExerciseType.taiChi:
        return Color(0xFF10B981);
    }
  }

  List<String> get benefits {
    switch (this) {
      case ExerciseType.meditation:
        return ['Reduces stress', 'Improves focus', 'Enhances emotional regulation'];
      case ExerciseType.breathing:
        return ['Calms nervous system', 'Reduces anxiety', 'Lowers blood pressure'];
      case ExerciseType.cbt:
        return ['Challenges negative thoughts', 'Builds resilience', 'Improves coping skills'];
      case ExerciseType.journaling:
        return ['Clarifies thoughts', 'Reduces emotional distress', 'Increases self-awareness'];
      case ExerciseType.mindfulness:
        return ['Increases present-moment awareness', 'Reduces rumination', 'Improves well-being'];
      case ExerciseType.progressiveRelaxation:
        return ['Reduces muscle tension', 'Improves sleep', 'Relieves stress'];
      case ExerciseType.visualization:
        return ['Boosts confidence', 'Reduces anxiety', 'Improves performance'];
      case ExerciseType.gratitude:
        return ['Increases happiness', 'Reduces depression', 'Improves sleep'];
      case ExerciseType.affirmations:
        return ['Boosts self-esteem', 'Reduces negative self-talk', 'Builds confidence'];
      case ExerciseType.bodyScan:
        return ['Reduces physical tension', 'Improves body awareness', 'Promotes relaxation'];
      case ExerciseType.yoga:
        return ['Improves flexibility', 'Reduces stress', 'Enhances mind-body connection'];
      case ExerciseType.taiChi:
        return ['Improves balance', 'Reduces stress', 'Enhances focus'];
    }
  }

  int get defaultDurationMinutes {
    switch (this) {
      case ExerciseType.meditation:
        return 10;
      case ExerciseType.breathing:
        return 5;
      case ExerciseType.cbt:
        return 15;
      case ExerciseType.journaling:
        return 10;
      case ExerciseType.mindfulness:
        return 10;
      case ExerciseType.progressiveRelaxation:
        return 15;
      case ExerciseType.visualization:
        return 10;
      case ExerciseType.gratitude:
        return 5;
      case ExerciseType.affirmations:
        return 5;
      case ExerciseType.bodyScan:
        return 15;
      case ExerciseType.yoga:
        return 20;
      case ExerciseType.taiChi:
        return 15;
    }
  }

  String get description {
    switch (this) {
      case ExerciseType.meditation:
        return 'Focus on the present moment and develop mindfulness';
      case ExerciseType.breathing:
        return 'Control your breath to reduce stress and anxiety';
      case ExerciseType.cbt:
        return 'Identify and challenge negative thought patterns';
      case ExerciseType.journaling:
        return 'Write down your thoughts and feelings';
      case ExerciseType.mindfulness:
        return 'Practice being present in the moment';
      case ExerciseType.progressiveRelaxation:
        return 'Systematically relax different muscle groups';
      case ExerciseType.visualization:
        return 'Use mental imagery to achieve relaxation';
      case ExerciseType.gratitude:
        return 'Cultivate appreciation for what you have';
      case ExerciseType.affirmations:
        return 'Use positive statements to build confidence';
      case ExerciseType.bodyScan:
        return 'Scan your body for tension and release it';
      case ExerciseType.yoga:
        return 'Combine physical postures with breath control';
      case ExerciseType.taiChi:
        return 'Practice slow, flowing movements for relaxation';
    }
  }
}
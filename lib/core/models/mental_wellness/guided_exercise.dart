import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../models/life_stage.dart';

enum ExerciseType {
  meditation,
  breathing,
  cbt,
  journaling,
  mindfulness,
  progressiveRelaxation,
  visualization,
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
    }
  }

  Color get color {
    switch (this) {
      case ExerciseType.meditation:
        return Color(0xFF6366F1); // Indigo
      case ExerciseType.breathing:
        return Color(0xFF06B6D4); // Cyan
      case ExerciseType.cbt:
        return Color(0xFF8B5CF6); // Purple
      case ExerciseType.journaling:
        return Color(0xFFF59E0B); // Amber
      case ExerciseType.mindfulness:
        return Color(0xFF10B981); // Emerald
      case ExerciseType.progressiveRelaxation:
        return Color(0xFFEC4899); // Pink
      case ExerciseType.visualization:
        return Color(0xFF3B82F6); // Blue
    }
  }
}

class GuidedExercise extends Equatable {
  final String id;
  final String title;
  final String description;
  final ExerciseType type;
  final int durationMinutes;
  final String? audioUrl;
  final String? videoUrl;
  final List<String> steps;
  final LifeStage? targetAgeGroup; // null = all ages
  final int difficultyLevel; // 1-5
  final List<String> benefits;
  final String? imageUrl;

  const GuidedExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    this.audioUrl,
    this.videoUrl,
    this.steps = const [],
    this.targetAgeGroup,
    this.difficultyLevel = 1,
    this.benefits = const [],
    this.imageUrl,
  });

  factory GuidedExercise.fromMap(Map<String, dynamic> map) {
    return GuidedExercise(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ExerciseType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => ExerciseType.meditation,
      ),
      durationMinutes: map['durationMinutes'] ?? 5,
      audioUrl: map['audioUrl'],
      videoUrl: map['videoUrl'],
      steps: List<String>.from(map['steps'] ?? []),
      targetAgeGroup: map['targetAgeGroup'] != null
          ? LifeStage.values.firstWhere(
              (e) => e.name == map['targetAgeGroup'],
              orElse: () => LifeStage.adult,
            )
          : null,
      difficultyLevel: map['difficultyLevel'] ?? 1,
      benefits: List<String>.from(map['benefits'] ?? []),
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'durationMinutes': durationMinutes,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'steps': steps,
      'targetAgeGroup': targetAgeGroup?.name,
      'difficultyLevel': difficultyLevel,
      'benefits': benefits,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [
    id, title, description, type, durationMinutes, audioUrl, videoUrl,
    steps, targetAgeGroup, difficultyLevel, benefits, imageUrl
  ];
}
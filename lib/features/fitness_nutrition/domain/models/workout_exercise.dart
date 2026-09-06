import '../../../../core/models/life_stage.dart';

class WorkoutExercise {
  final String id;
  final String name;
  final String category; // e.g. "Strength", "Mobility", "Cardio", "Balance"
  final String targetMuscles;
  final int sets;
  final int reps;
  final int durationSeconds;
  final String instructions;
  final String mobilityModification;
  final String videoUrl;

  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.category,
    required this.targetMuscles,
    required this.sets,
    required this.reps,
    this.durationSeconds = 0,
    required this.instructions,
    required this.mobilityModification,
    this.videoUrl = '',
  });
}

class WorkoutRoutine {
  final String id;
  final String title;
  final String goal; // "Muscle Hypertrophy", "Cardiovascular Defense", "Fall Prevention & Joint Care"
  final LifeStage targetStage;
  final int durationMinutes;
  final int estimatedCalories;
  final List<WorkoutExercise> exercises;

  const WorkoutRoutine({
    required this.id,
    required this.title,
    required this.goal,
    required this.targetStage,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.exercises,
  });
}

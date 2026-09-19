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

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'goal': goal,
    'targetStage': targetStage.name,
    'durationMinutes': durationMinutes,
    'estimatedCalories': estimatedCalories,
    'exercises': exercises.map((e) => {
      'id': e.id,
      'name': e.name,
      'category': e.category,
      'targetMuscles': e.targetMuscles,
      'sets': e.sets,
      'reps': e.reps,
      'durationSeconds': e.durationSeconds,
      'instructions': e.instructions,
      'mobilityModification': e.mobilityModification,
      'videoUrl': e.videoUrl,
    }).toList(),
  };

  factory WorkoutRoutine.fromMap(Map<String, dynamic> map) {
    LifeStage stage = LifeStage.adult;
    try {
      stage = LifeStage.values.firstWhere((s) => s.name == map['targetStage']);
    } catch (_) {}
    return WorkoutRoutine(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Custom Routine',
      goal: map['goal'] ?? 'Custom Goal',
      targetStage: stage,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      estimatedCalories: (map['estimatedCalories'] as num?)?.toInt() ?? 200,
      exercises: (map['exercises'] as List<dynamic>?)?.map((e) {
        final m = e as Map<String, dynamic>;
        return WorkoutExercise(
          id: m['id'] ?? '',
          name: m['name'] ?? '',
          category: m['category'] ?? '',
          targetMuscles: m['targetMuscles'] ?? '',
          sets: (m['sets'] as num?)?.toInt() ?? 3,
          reps: (m['reps'] as num?)?.toInt() ?? 10,
          durationSeconds: (m['durationSeconds'] as num?)?.toInt() ?? 0,
          instructions: m['instructions'] ?? '',
          mobilityModification: m['mobilityModification'] ?? '',
          videoUrl: m['videoUrl'] ?? '',
        );
      }).toList() ?? [],
    );
  }
}

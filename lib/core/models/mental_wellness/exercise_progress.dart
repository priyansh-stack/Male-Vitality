import 'package:equatable/equatable.dart';

class ExerciseProgress extends Equatable {
  final String exerciseId;
  final String userId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int stepsCompleted;
  final int totalSteps;
  final Duration timeSpent;
  final bool isComplete;
  final int? rating; // 1-5
  final String? feedback;

  const ExerciseProgress({
    required this.exerciseId,
    required this.userId,
    required this.startedAt,
    this.completedAt,
    this.stepsCompleted = 0,
    this.totalSteps = 0,
    this.timeSpent = Duration.zero,
    this.isComplete = false,
    this.rating,
    this.feedback,
  });

  factory ExerciseProgress.fromMap(Map<String, dynamic> map) {
    return ExerciseProgress(
      exerciseId: map['exerciseId'] ?? '',
      userId: map['userId'] ?? '',
      startedAt: DateTime.parse(map['startedAt'] ?? DateTime.now().toIso8601String()),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      stepsCompleted: map['stepsCompleted'] ?? 0,
      totalSteps: map['totalSteps'] ?? 0,
      timeSpent: Duration(milliseconds: map['timeSpentMs'] ?? 0),
      isComplete: map['isComplete'] ?? false,
      rating: map['rating'],
      feedback: map['feedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'userId': userId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'stepsCompleted': stepsCompleted,
      'totalSteps': totalSteps,
      'timeSpentMs': timeSpent.inMilliseconds,
      'isComplete': isComplete,
      'rating': rating,
      'feedback': feedback,
    };
  }

  // double getCompletionPercentage {
  //   if (totalSteps == 0) return 0.0;
  //   return stepsCompleted / totalSteps;
  // }

  @override
  List<Object?> get props => [
    exerciseId, userId, startedAt, completedAt, stepsCompleted,
    totalSteps, timeSpent, isComplete, rating, feedback
  ];
}
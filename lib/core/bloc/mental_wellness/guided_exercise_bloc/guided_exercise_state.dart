part of 'guided_exercise_bloc.dart';


abstract class GuidedExerciseState extends Equatable {
  const GuidedExerciseState();
  @override
  List<Object?> get props => [];
}

class ExerciseInitialState extends GuidedExerciseState {}

class ExerciseLoadingState extends GuidedExerciseState {
  final String? message;
  const ExerciseLoadingState({this.message});
  @override
  List<Object?> get props => [message];
}

class ExerciseLibraryLoadedState extends GuidedExerciseState {
  final List<GuidedExercise> exercises;
  final Map<ExerciseType, List<GuidedExercise>> categorized;
  final Map<String, int> progress;

  const ExerciseLibraryLoadedState({
    required this.exercises,
    required this.categorized,
    this.progress = const {},
  });

  @override
  List<Object> get props => [exercises, categorized, progress];
}

class ExercisePlayerState extends GuidedExerciseState {
  final GuidedExercise exercise;
  final int currentStep;
  final Duration elapsedTime;
  final bool isPlaying;
  final bool isComplete;

  const ExercisePlayerState({
    required this.exercise,
    this.currentStep = 0,
    this.elapsedTime = Duration.zero,
    this.isPlaying = false,
    this.isComplete = false,
  });

  ExercisePlayerState copyWith({
    GuidedExercise? exercise,
    int? currentStep,
    Duration? elapsedTime,
    bool? isPlaying,
    bool? isComplete,
  }) {
    return ExercisePlayerState(
      exercise: exercise ?? this.exercise,
      currentStep: currentStep ?? this.currentStep,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isPlaying: isPlaying ?? this.isPlaying,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object> get props => [exercise, currentStep, elapsedTime, isPlaying, isComplete];
}

class ExercisePausedState extends GuidedExerciseState {
  final GuidedExercise exercise;
  final int currentStep;
  final Duration elapsedTime;

  const ExercisePausedState({
    required this.exercise,
    required this.currentStep,
    required this.elapsedTime,
  });

  @override
  List<Object> get props => [exercise, currentStep, elapsedTime];
}

class ExerciseCompletedState extends GuidedExerciseState {
  final GuidedExercise exercise;
  final Duration totalTime;
  final int? rating;

  const ExerciseCompletedState({
    required this.exercise,
    required this.totalTime,
    this.rating,
  });

  @override
  List<Object?> get props => [exercise, totalTime, rating];
}

class ExerciseErrorState extends GuidedExerciseState {
  final String message;

  const ExerciseErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
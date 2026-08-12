part of 'guided_exercise_bloc.dart';


abstract class GuidedExerciseEvent extends Equatable {
  const GuidedExerciseEvent();
  @override
  List<Object?> get props => [];
}

class LoadGuidedExercisesEvent extends GuidedExerciseEvent {
  final ExerciseType? type;
  final LifeStage? ageGroup;

  const LoadGuidedExercisesEvent({this.type, this.ageGroup});

  @override
  List<Object?> get props => [type, ageGroup];
}

class LoadGuidedExerciseByIdEvent extends GuidedExerciseEvent {
  final String exerciseId;

  const LoadGuidedExerciseByIdEvent({required this.exerciseId});

  @override
  List<Object> get props => [exerciseId];
}

class StartGuidedExerciseEvent extends GuidedExerciseEvent {
  final String exerciseId;

  const StartGuidedExerciseEvent({required this.exerciseId});

  @override
  List<Object> get props => [exerciseId];
}

class PauseGuidedExerciseEvent extends GuidedExerciseEvent {}

class ResumeGuidedExerciseEvent extends GuidedExerciseEvent {}

class CompleteGuidedExerciseEvent extends GuidedExerciseEvent {
  final int? rating;
  final String? feedback;

  const CompleteGuidedExerciseEvent({this.rating, this.feedback});

  @override
  List<Object?> get props => [rating, feedback];
}

class FilterExercisesByTypeEvent extends GuidedExerciseEvent {
  final ExerciseType type;

  const FilterExercisesByTypeEvent({required this.type});

  @override
  List<Object> get props => [type];
}

class FilterExercisesByAgeGroupEvent extends GuidedExerciseEvent {
  final LifeStage ageGroup;

  const FilterExercisesByAgeGroupEvent({required this.ageGroup});

  @override
  List<Object> get props => [ageGroup];
}

class ResetExerciseFiltersEvent extends GuidedExerciseEvent {}

class TrackExerciseStepEvent extends GuidedExerciseEvent {
  final int stepIndex;

  const TrackExerciseStepEvent({required this.stepIndex});

  @override
  List<Object> get props => [stepIndex];
}
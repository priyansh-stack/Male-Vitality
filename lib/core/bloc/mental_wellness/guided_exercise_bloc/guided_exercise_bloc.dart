import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/filter_exercises_by_age_group_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_exercise_categories_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_exercise_recommendations_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_guided_exercise_by_id_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_guided_exercises_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/track_exercise_progress_usecase.dart';
import '../../../models/mental_wellness/guided_exercise.dart';
import '../../../models/mental_wellness/exercise_progress.dart';
import '../../../models/life_stage.dart';
part 'guided_exercise_event.dart';
part 'guided_exercise_state.dart';

class GuidedExerciseBloc extends Bloc<GuidedExerciseEvent, GuidedExerciseState> {
  final GetGuidedExercisesUseCase getGuidedExercisesUseCase;
  final GetGuidedExerciseByIdUseCase getGuidedExerciseByIdUseCase;
  final TrackExerciseProgressUseCase trackExerciseProgressUseCase;
  final GetExerciseRecommendationsUseCase getExerciseRecommendationsUseCase;
  final FilterExercisesByAgeGroupUseCase filterExercisesByAgeGroupUseCase;
  final GetExerciseCategoriesUseCase getExerciseCategoriesUseCase;

  Timer? _exerciseTimer;

  GuidedExerciseBloc({
    required this.getGuidedExercisesUseCase,
    required this.getGuidedExerciseByIdUseCase,
    required this.trackExerciseProgressUseCase,
    required this.getExerciseRecommendationsUseCase,
    required this.filterExercisesByAgeGroupUseCase,
    required this.getExerciseCategoriesUseCase,
  }) : super(ExerciseInitialState()) {
    on<LoadGuidedExercisesEvent>(_onLoadExercises);
    on<LoadGuidedExerciseByIdEvent>(_onLoadExerciseById);
    on<StartGuidedExerciseEvent>(_onStartExercise);
    on<PauseGuidedExerciseEvent>(_onPauseExercise);
    on<ResumeGuidedExerciseEvent>(_onResumeExercise);
    on<CompleteGuidedExerciseEvent>(_onCompleteExercise);
    on<FilterExercisesByTypeEvent>(_onFilterByType);
    on<FilterExercisesByAgeGroupEvent>(_onFilterByAgeGroup);
    on<ResetExerciseFiltersEvent>(_onResetFilters);
    on<TrackExerciseStepEvent>(_onTrackStep);
  }

  Future<void> _onLoadExercises(
    LoadGuidedExercisesEvent event,
    Emitter<GuidedExerciseState> emit,
  ) async {
    emit(const ExerciseLoadingState(message: 'Loading exercises...'));

    try {
      final exercises = await getGuidedExercisesUseCase.execute(
        type: event.type,
        ageGroup: event.ageGroup,
      );

      final categorized = await getExerciseCategoriesUseCase.execute();
      final progress = <String, int>{}; // Load from local storage

      emit(ExerciseLibraryLoadedState(
        exercises: exercises,
        categorized: categorized,
        progress: progress,
      ));
    } catch (e) {
      emit(ExerciseErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadExerciseById(
    LoadGuidedExerciseByIdEvent event,
    Emitter<GuidedExerciseState> emit,
  ) async {
    emit(const ExerciseLoadingState(message: 'Loading exercise...'));

    try {
      final exercise = await getGuidedExerciseByIdUseCase.execute(event.exerciseId);
      emit(ExercisePlayerState(
        exercise: exercise,
        currentStep: 0,
        elapsedTime: Duration.zero,
        isPlaying: false,
        isComplete: false,
      ));
    } catch (e) {
      emit(ExerciseErrorState(message: e.toString()));
    }
  }

  Future<void> _onStartExercise(
    StartGuidedExerciseEvent event,
    Emitter<GuidedExerciseState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExercisePlayerState) {
      emit(currentState.copyWith(
        isPlaying: true,
        elapsedTime: Duration.zero,
      ));
      _startExerciseTimer();
    } else {
      // Load exercise first
      add(LoadGuidedExerciseByIdEvent(exerciseId: event.exerciseId));
    }
  }

  void _startExerciseTimer() {
    _exerciseTimer?.cancel();
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is ExercisePlayerState && currentState.isPlaying) {
        final newState = currentState.copyWith(
          elapsedTime: currentState.elapsedTime + const Duration(seconds: 1),
        );
        // ignore: invalid_use_of_visible_for_testing_member
        emit(newState);
      }
    });
  }

  Future<void> _onPauseExercise(
    PauseGuidedExerciseEvent event,
    Emitter<GuidedExerciseState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExercisePlayerState) {
      _exerciseTimer?.cancel();
      emit(ExercisePausedState(
        exercise: currentState.exercise,
        currentStep: currentState.currentStep,
        elapsedTime: currentState.elapsedTime,
      ));
    }
  }

  Future<void> _onResumeExercise(
    ResumeGuidedExerciseEvent event,
    Emitter<GuidedExerciseState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExercisePausedState) {
      emit(ExercisePlayerState(
        exercise: currentState.exercise,
        currentStep: currentState.currentStep,
        elapsedTime: currentState.elapsedTime,
        isPlaying: true,
        isComplete: false,
      ));
      _startExerciseTimer();
    }
  }

  Future<void> _onCompleteExercise(
    CompleteGuidedExerciseEvent event,
    Emitter<GuidedExerciseState> emit,
  ) async {
    _exerciseTimer?.cancel();

    final currentState = state;
    if (currentState is ExercisePlayerState) {
      try {
        await trackExerciseProgressUseCase.execute(
          userId: '', // Get from auth
          exerciseId: currentState.exercise.id,
          progress: ExerciseProgress(
            exerciseId: currentState.exercise.id,
            userId: '',
            startedAt: DateTime.now().subtract(currentState.elapsedTime),
            stepsCompleted: currentState.currentStep + 1,
            totalSteps: currentState.exercise.steps.length,
            timeSpent: currentState.elapsedTime,
            isComplete: true,
            rating: event.rating,
            feedback: event.feedback,
          ),
        );

        emit(ExerciseCompletedState(
          exercise: currentState.exercise,
          totalTime: currentState.elapsedTime,
          rating: event.rating,
        ));
      } catch (e) {
        emit(ExerciseErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _onFilterByType(
    FilterExercisesByTypeEvent event,
    Emitter<GuidedExerciseState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExerciseLibraryLoadedState) {
      final filtered = currentState.exercises
          .where((e) => e.type == event.type)
          .toList();

      final categorized = <ExerciseType, List<GuidedExercise>>{};
      categorized[event.type] = filtered;

      emit(ExerciseLibraryLoadedState(
        exercises: filtered,
        categorized: categorized,
        progress: currentState.progress,
      ));
    } else {
      add(LoadGuidedExercisesEvent(type: event.type));
    }
  }

  Future<void> _onFilterByAgeGroup(
    FilterExercisesByAgeGroupEvent event,
    Emitter<GuidedExerciseState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExerciseLibraryLoadedState) {
      final filtered = currentState.exercises
          .where((e) => e.targetAgeGroup == null || e.targetAgeGroup == event.ageGroup)
          .toList();

      emit(ExerciseLibraryLoadedState(
        exercises: filtered,
        categorized: currentState.categorized,
        progress: currentState.progress,
      ));
    } else {
      add(LoadGuidedExercisesEvent(ageGroup: event.ageGroup));
    }
  }

  void _onResetFilters(
    ResetExerciseFiltersEvent event,
    Emitter<GuidedExerciseState> emit,
  ) {
    add(const LoadGuidedExercisesEvent());
  }

  void _onTrackStep(
    TrackExerciseStepEvent event,
    Emitter<GuidedExerciseState> emit,
  ) {
    final currentState = state;
    if (currentState is ExercisePlayerState) {
      emit(currentState.copyWith(currentStep: event.stepIndex));
    }
  }

  @override
  Future<void> close() {
    _exerciseTimer?.cancel();
    return super.close();
  }
}
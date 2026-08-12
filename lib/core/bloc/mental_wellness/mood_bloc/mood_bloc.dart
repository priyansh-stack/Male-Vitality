import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/create_mood_entry_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/delete_mood_entry_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_mood_heatmap_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_mood_history_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_mood_trends_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/update_mood_entry_usecase.dart';
import '../../../models/mental_wellness/mood_entry.dart';
part 'mood_event.dart';
part 'mood_state.dart';

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final CreateMoodEntryUseCase createMoodEntryUseCase;
  final GetMoodHistoryUseCase getMoodHistoryUseCase;
  final GetMoodTrendsUseCase getMoodTrendsUseCase;
  final GetMoodHeatmapUseCase getMoodHeatmapUseCase;
  final DeleteMoodEntryUseCase deleteMoodEntryUseCase;
  final UpdateMoodEntryUseCase updateMoodEntryUseCase;

  MoodBloc({
    required this.createMoodEntryUseCase,
    required this.getMoodHistoryUseCase,
    required this.getMoodTrendsUseCase,
    required this.getMoodHeatmapUseCase,
    required this.deleteMoodEntryUseCase,
    required this.updateMoodEntryUseCase,
  }) : super(MoodInitialState()) {
    on<SubmitMoodEntryEvent>(_onSubmitMoodEntry);
    on<LoadMoodHistoryEvent>(_onLoadMoodHistory);
    on<LoadMoodTrendsEvent>(_onLoadMoodTrends);
    on<LoadMoodHeatmapEvent>(_onLoadMoodHeatmap);
    on<DeleteMoodEntryEvent>(_onDeleteMoodEntry);
    on<UpdateMoodEntryEvent>(_onUpdateMoodEntry);
    on<ResetMoodStateEvent>(_onResetMoodState);
  }

  // Only the _onSubmitMoodEntry method changes:

  Future<void> _onSubmitMoodEntry(
    SubmitMoodEntryEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodSubmittingState());

    try {
      final entry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: event.userId, 
        timestamp: DateTime.now(),
        moodRating: event.moodRating,
        phq2Score: event.phq2Score,
        gad2Score: event.gad2Score,
        notes: event.notes,
        triggers: event.triggers,
        context: event.context,
      );

      final createdEntry = await createMoodEntryUseCase.execute(entry);
      emit(MoodCheckinCompletedState(entry: createdEntry));
    } catch (e) {
      emit(MoodErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadMoodHistory(
    LoadMoodHistoryEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoadingState(message: 'Loading mood history...'));

    try {
      final entries = await getMoodHistoryUseCase.execute(
        userId: event.userId,
        days: event.days,
      );
      emit(MoodHistoryLoadedState(
        entries: entries,
        moodHeatmap: _generateHeatmap(entries),
      ));
    } catch (e) {
      emit(MoodErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadMoodTrends(
    LoadMoodTrendsEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoadingState(message: 'Loading mood trends...'));

    try {
      final entries = await getMoodTrendsUseCase.execute(
        userId: event.userId,
        days: event.days,
      );
      emit(MoodTrendsLoadedState(
        entries: entries,
        trends: _calculateTrends(entries),
      ));
    } catch (e) {
      emit(MoodErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadMoodHeatmap(
    LoadMoodHeatmapEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoadingState(message: 'Loading mood heatmap...'));

    try {
      final heatmap = await getMoodHeatmapUseCase.execute(
        userId: event.userId,
        days: event.days,
      );
      emit(MoodHeatmapLoadedState(heatmap: heatmap));
    } catch (e) {
      emit(MoodErrorState(message: e.toString()));
    }
  }

  Future<void> _onDeleteMoodEntry(
    DeleteMoodEntryEvent event,
    Emitter<MoodState> emit,
  ) async {
    try {
      await deleteMoodEntryUseCase.execute(event.entryId);
      // Reload history after deletion
      final currentState = state;
      if (currentState is MoodHistoryLoadedState) {
        // This will trigger a refresh
      }
    } catch (e) {
      emit(MoodErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateMoodEntry(
    UpdateMoodEntryEvent event,
    Emitter<MoodState> emit,
  ) async {
    try {
      await updateMoodEntryUseCase.execute(event.entry);
    } catch (e) {
      emit(MoodErrorState(message: e.toString()));
    }
  }

  void _onResetMoodState(
    ResetMoodStateEvent event,
    Emitter<MoodState> emit,
  ) {
    emit(MoodInitialState());
  }

  Map<DateTime, int> _generateHeatmap(List<MoodEntry> entries) {
    final heatmap = <DateTime, int>{};
    for (final entry in entries) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      heatmap[date] = entry.moodRating;
    }
    return heatmap;
  }

  Map<String, dynamic> _calculateTrends(List<MoodEntry> entries) {
    if (entries.isEmpty) return {};

    final trends = <String, dynamic>{};
    final sorted = List<MoodEntry>.from(entries)..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate average mood
    final avgMood = entries.map((e) => e.moodRating).reduce((a, b) => a + b) / entries.length;
    trends['averageMood'] = avgMood;

    // Calculate trend direction
    if (entries.length >= 2) {
      final firstHalf = entries.take(entries.length ~/ 2).map((e) => e.moodRating).toList();
      final secondHalf = entries.skip(entries.length ~/ 2).map((e) => e.moodRating).toList();
      final firstAvg = firstHalf.isNotEmpty ? firstHalf.reduce((a, b) => a + b) / firstHalf.length : 0;
      final secondAvg = secondHalf.isNotEmpty ? secondHalf.reduce((a, b) => a + b) / secondHalf.length : 0;
      trends['trendDirection'] = secondAvg - firstAvg;
      trends['isImproving'] = secondAvg > firstAvg;
    }

    // Get highest and lowest mood
    trends['highestMood'] = entries.map((e) => e.moodRating).reduce((a, b) => a > b ? a : b);
    trends['lowestMood'] = entries.map((e) => e.moodRating).reduce((a, b) => a < b ? a : b);

    return trends;
  }
}
part of 'mood_bloc.dart';


abstract class MoodState extends Equatable {
  const MoodState();
  @override
  List<Object?> get props => [];
}

class MoodInitialState extends MoodState {}

class MoodLoadingState extends MoodState {
  final String? message;
  const MoodLoadingState({this.message});
  @override
  List<Object?> get props => [message];
}

class MoodCheckinReadyState extends MoodState {
  final int? currentMood;
  final int? phq2Score;
  final int? gad2Score;
  final bool checkinCompleted;

  const MoodCheckinReadyState({
    this.currentMood,
    this.phq2Score,
    this.gad2Score,
    this.checkinCompleted = false,
  });

  MoodCheckinReadyState copyWith({
    int? currentMood,
    int? phq2Score,
    int? gad2Score,
    bool? checkinCompleted,
  }) {
    return MoodCheckinReadyState(
      currentMood: currentMood ?? this.currentMood,
      phq2Score: phq2Score ?? this.phq2Score,
      gad2Score: gad2Score ?? this.gad2Score,
      checkinCompleted: checkinCompleted ?? this.checkinCompleted,
    );
  }

  @override
  List<Object?> get props => [currentMood, phq2Score, gad2Score, checkinCompleted];
}

class MoodHistoryLoadedState extends MoodState {
  final List<MoodEntry> entries;
  final Map<DateTime, int> moodHeatmap;

  const MoodHistoryLoadedState({
    required this.entries,
    required this.moodHeatmap,
  });

  @override
  List<Object> get props => [entries, moodHeatmap];
}

class MoodTrendsLoadedState extends MoodState {
  final List<MoodEntry> entries;
  final Map<String, dynamic> trends;

  const MoodTrendsLoadedState({
    required this.entries,
    required this.trends,
  });

  @override
  List<Object> get props => [entries, trends];
}

class MoodHeatmapLoadedState extends MoodState {
  final Map<DateTime, int> heatmap;

  const MoodHeatmapLoadedState({required this.heatmap});

  @override
  List<Object> get props => [heatmap];
}

class MoodSubmittingState extends MoodState {}

class MoodCheckinCompletedState extends MoodState {
  final MoodEntry entry;

  const MoodCheckinCompletedState({required this.entry});

  @override
  List<Object> get props => [entry];
}

class MoodErrorState extends MoodState {
  final String message;

  const MoodErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
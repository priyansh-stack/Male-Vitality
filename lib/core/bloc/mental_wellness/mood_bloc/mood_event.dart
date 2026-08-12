part of 'mood_bloc.dart';



abstract class MoodEvent extends Equatable {
  const MoodEvent();
  @override
  List<Object?> get props => [];
}

class SubmitMoodEntryEvent extends MoodEvent {
  final String userId;
  final int moodRating;
  final int? phq2Score;
  final int? gad2Score;
  final String? notes;
  final List<String> triggers;
  final Map<String, dynamic> context;

  const SubmitMoodEntryEvent({
    required this.userId,
    required this.moodRating,
    this.phq2Score,
    this.gad2Score,
    this.notes,
    this.triggers = const [],
    this.context = const {},
  });

  @override
  List<Object?> get props => [userId, moodRating, phq2Score, gad2Score, notes, triggers, context];
}

class LoadMoodHistoryEvent extends MoodEvent {
  final String userId;
  final int days;

  const LoadMoodHistoryEvent({
    required this.userId,
    this.days = 30,
  });

  @override
  List<Object> get props => [userId, days];
}

class LoadMoodTrendsEvent extends MoodEvent {
  final String userId;
  final int days;

  const LoadMoodTrendsEvent({
    required this.userId,
    this.days = 30,
  });

  @override
  List<Object> get props => [userId, days];
}

class LoadMoodHeatmapEvent extends MoodEvent {
  final String userId;
  final int days;

  const LoadMoodHeatmapEvent({
    required this.userId,
    this.days = 30,
  });

  @override
  List<Object> get props => [userId, days];
}

class DeleteMoodEntryEvent extends MoodEvent {
  final String entryId;

  const DeleteMoodEntryEvent(this.entryId);

  @override
  List<Object> get props => [entryId];
}

class UpdateMoodEntryEvent extends MoodEvent {
  final MoodEntry entry;

  const UpdateMoodEntryEvent(this.entry);

  @override
  List<Object> get props => [entry];
}

class ResetMoodStateEvent extends MoodEvent {}
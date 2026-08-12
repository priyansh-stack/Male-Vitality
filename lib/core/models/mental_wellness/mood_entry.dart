import 'package:equatable/equatable.dart';

class MoodEntry extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp;
  final int moodRating; // 1-10
  final int? phq2Score; // 0-6 for depression
  final int? gad2Score; // 0-6 for anxiety
  final String? notes;
  final List<String> triggers; // stress, sleep, relationships, work
  final Map<String, dynamic> context; // sleep_quality, exercise, etc.

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.moodRating,
    this.phq2Score,
    this.gad2Score,
    this.notes,
    this.triggers = const [],
    this.context = const {},
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      moodRating: map['moodRating'] ?? 5,
      phq2Score: map['phq2Score'],
      gad2Score: map['gad2Score'],
      notes: map['notes'],
      triggers: List<String>.from(map['triggers'] ?? []),
      context: Map<String, dynamic>.from(map['context'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'moodRating': moodRating,
      'phq2Score': phq2Score,
      'gad2Score': gad2Score,
      'notes': notes,
      'triggers': triggers,
      'context': context,
    };
  }

  MoodEntry copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    int? moodRating,
    int? phq2Score,
    int? gad2Score,
    String? notes,
    List<String>? triggers,
    Map<String, dynamic>? context,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      moodRating: moodRating ?? this.moodRating,
      phq2Score: phq2Score ?? this.phq2Score,
      gad2Score: gad2Score ?? this.gad2Score,
      notes: notes ?? this.notes,
      triggers: triggers ?? this.triggers,
      context: context ?? this.context,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, timestamp, moodRating, phq2Score, gad2Score, notes, triggers, context
  ];
}
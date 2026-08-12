import 'dart:convert';
import '../../../core/models/mental_wellness/mood_entry.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class ExportMoodDataUseCase {
  final MentalWellnessRepository repository;

  ExportMoodDataUseCase({required this.repository});

  Future<Map<String, dynamic>> execute({
    required String userId,
    int days = 90,
  }) async {
    final entries = await repository.getMoodHistory(userId, days: days);

    return {
      'userId': userId,
      'exportDate': DateTime.now().toIso8601String(),
      'totalEntries': entries.length,
      'dateRange': {
        'startDate': entries.isNotEmpty
            ? entries.last.timestamp.toIso8601String()
            : DateTime.now().toIso8601String(),
        'endDate': entries.isNotEmpty
            ? entries.first.timestamp.toIso8601String()
            : DateTime.now().toIso8601String(),
      },
      'entries': entries.map((e) => e.toMap()).toList(),
    };
  }

  // Export as CSV
  String toCsv(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Mood,PHQ-2,GAD-2,Triggers,Notes');

    final entries = (data['entries'] as List).map((e) => MoodEntry.fromMap(e)).toList();
    for (final entry in entries) {
      buffer.writeln(
        '${entry.timestamp.toIso8601String()},'
        '${entry.moodRating},'
        '${entry.phq2Score ?? ""},'
        '${entry.gad2Score ?? ""},'
        '"${entry.triggers.join('; ')}",'
        '"${entry.notes ?? ""}"'
      );
    }

    return buffer.toString();
  }

  // Export as JSON
  String toJson(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  // Get file name with date
  String getFileName() {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 16);
    return 'mood_export_$timestamp';
  }
}
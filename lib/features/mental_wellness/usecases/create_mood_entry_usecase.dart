import '../../../core/models/mental_wellness/mood_entry.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class CreateMoodEntryUseCase {
  final MentalWellnessRepository repository;

  CreateMoodEntryUseCase({required this.repository});

  Future<MoodEntry> execute(MoodEntry entry) {
    return repository.createMoodEntry(entry);
  }
}
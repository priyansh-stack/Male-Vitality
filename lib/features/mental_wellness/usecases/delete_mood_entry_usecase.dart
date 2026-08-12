import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class DeleteMoodEntryUseCase {
  final MentalWellnessRepository repository;

  DeleteMoodEntryUseCase({required this.repository});

  Future<void> execute(String entryId) {
    return repository.deleteMoodEntry(entryId);
  }
}
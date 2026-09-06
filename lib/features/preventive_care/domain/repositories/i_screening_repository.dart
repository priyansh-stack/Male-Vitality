import '../models/screening_record.dart';

abstract class IScreeningRepository {
  Future<List<ScreeningRecord>> getScreeningRecords(String userId);
  Future<void> saveScreeningRecord(ScreeningRecord record);
  Future<void> markScreeningCompleted(
    String userId,
    String recordId,
    DateTime completedDate,
    String notes, {
    String? documentUrl,
  });
  Future<void> deleteScreeningRecord(String userId, String recordId);
}

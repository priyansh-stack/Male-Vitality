import '../models/sleep_entry.dart';

abstract class ISleepRepository {
  Future<List<SleepEntry>> getSleepHistory(String userId, {int days = 7});
  Future<void> logSleep(SleepEntry entry);
  Future<bool> hasChronicSleepDeprivation(String userId);
}

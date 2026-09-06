class SleepEntry {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime bedtime;
  final DateTime wakeTime;
  final double durationHours;
  final int qualityScore; // 1 - 100
  final int deepSleepMinutes;
  final int remSleepMinutes;
  final String notes;

  const SleepEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.durationHours,
    required this.qualityScore,
    this.deepSleepMinutes = 90,
    this.remSleepMinutes = 100,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'bedtime': bedtime.toIso8601String(),
        'wakeTime': wakeTime.toIso8601String(),
        'durationHours': durationHours,
        'qualityScore': qualityScore,
        'deepSleepMinutes': deepSleepMinutes,
        'remSleepMinutes': remSleepMinutes,
        'notes': notes,
      };

  factory SleepEntry.fromMap(Map<String, dynamic> map, String id) {
    return SleepEntry(
      id: id,
      userId: map['userId'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      bedtime: map['bedtime'] != null ? DateTime.parse(map['bedtime']) : DateTime.now().subtract(const Duration(hours: 7)),
      wakeTime: map['wakeTime'] != null ? DateTime.parse(map['wakeTime']) : DateTime.now(),
      durationHours: (map['durationHours'] as num?)?.toDouble() ?? 7.0,
      qualityScore: map['qualityScore'] ?? 80,
      deepSleepMinutes: map['deepSleepMinutes'] ?? 90,
      remSleepMinutes: map['remSleepMinutes'] ?? 100,
      notes: map['notes'] ?? '',
    );
  }
}

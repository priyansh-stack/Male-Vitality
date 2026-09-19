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
    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val != null) {
        try {
          final toDate = (val as dynamic).toDate;
          if (toDate != null) return toDate() as DateTime;
        } catch (_) {}
      }
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    final date = parseDate(map['date'] ?? map['startTime']);

    final bedtime = map['bedtime'] != null
        ? parseDate(map['bedtime'])
        : (map['startTime'] != null
            ? parseDate(map['startTime'])
            : date.subtract(const Duration(hours: 7)));

    final wakeTime = map['wakeTime'] != null
        ? parseDate(map['wakeTime'])
        : (map['endTime'] != null
            ? parseDate(map['endTime'])
            : bedtime.add(const Duration(hours: 7)));

    double durationHours;
    if (map['durationHours'] != null) {
      durationHours = (map['durationHours'] as num).toDouble();
    } else if (map['durationMinutes'] != null) {
      durationHours = (map['durationMinutes'] as num).toDouble() / 60.0;
    } else if (map['sleepMinutes'] != null) {
      durationHours = (map['sleepMinutes'] as num).toDouble() / 60.0;
    } else {
      final diffMin = wakeTime.difference(bedtime).inMinutes;
      durationHours = diffMin > 0 ? (diffMin / 60.0) : 7.0;
    }

    final qualityScore = (map['sleepScore'] as num?)?.toInt() ??
        (map['qualityScore'] as num?)?.toInt() ??
        (map['sleep_score'] as num?)?.toInt() ??
        80;

    final deep = (map['deepMinutes'] as num?)?.toInt() ??
        (map['deepSleepMinutes'] as num?)?.toInt() ??
        (map['deep_sleep_minutes'] as num?)?.toInt() ??
        (durationHours * 60 * 0.20).round();

    final rem = (map['remMinutes'] as num?)?.toInt() ??
        (map['remSleepMinutes'] as num?)?.toInt() ??
        (map['rem_sleep_minutes'] as num?)?.toInt() ??
        (durationHours * 60 * 0.22).round();

    final notes = map['notes'] as String? ??
        (map['source'] != null ? 'Synced via ${map['source']}' : 'Fitbit Hardware Telemetry');

    return SleepEntry(
      id: id,
      userId: map['userId'] ?? '',
      date: date,
      bedtime: bedtime,
      wakeTime: wakeTime,
      durationHours: double.parse(durationHours.toStringAsFixed(1)),
      qualityScore: qualityScore,
      deepSleepMinutes: deep,
      remSleepMinutes: rem,
      notes: notes,
    );
  }
}

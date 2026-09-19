import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Normalized daily health summary stored in Firestore at
/// `users/{uid}/healthDaily/{yyyy-MM-dd}`.
///
/// Designed to be provider-neutral (consumes data written by Fitbit / Google Health
/// and ready for future Apple Health integration).
///
/// All numeric fields are nullable and defensively parsed.
class HealthDaily extends Equatable {
  final String date; // yyyy-MM-dd (local date)
  final int? steps;
  final int? calories;
  final double? distanceMeters;
  final int? activeMinutes;
  final int? restingHeartRate;
  final int? sleepMinutes;
  final int? sleepScore;
  final double? hrvRmssd; // ms (rMSSD / avgHrv)
  final double? spo2Percentage; // % (avgSpo2)
  final double? breathingRate; // breaths per minute
  final String? syncStatus;
  final DateTime? lastSyncedAt;
  final String? source;

  const HealthDaily({
    required this.date,
    this.steps,
    this.calories,
    this.distanceMeters,
    this.activeMinutes,
    this.restingHeartRate,
    this.sleepMinutes,
    this.sleepScore,
    this.hrvRmssd,
    this.spo2Percentage,
    this.breathingRate,
    this.syncStatus,
    this.lastSyncedAt,
    this.source,
  });

  /// Distance in kilometers with automatic fallback to steps calculation if missing.
  double get distanceKm {
    if (distanceMeters != null && distanceMeters! > 0) {
      return distanceMeters! / 1000.0;
    }
    if (steps != null && steps! > 0) {
      return (steps! * 0.762) / 1000.0;
    }
    return 0.0;
  }

  /// Formatted sleep duration (e.g., "7h 30m" or null if no sleep data).
  String? get sleepFormatted {
    if (sleepMinutes == null || sleepMinutes! <= 0) return null;
    final hours = sleepMinutes! ~/ 60;
    final minutes = sleepMinutes! % 60;
    return '${hours}h ${minutes}m';
  }

  /// Convenience aliases for cross-app compatibility
  double? get avgHrv => hrvRmssd;
  double? get avgSpo2 => spo2Percentage;
  DateTime? get updatedAt => lastSyncedAt;

  /// True if no actual telemetry metrics are recorded
  bool get isEmpty =>
      steps == null &&
      calories == null &&
      distanceMeters == null &&
      restingHeartRate == null &&
      sleepMinutes == null &&
      hrvRmssd == null &&
      spo2Percentage == null;

  /// Deserializes from a Map with an explicit date
  factory HealthDaily.fromMap(String date, Map<String, dynamic> map) {
    return HealthDaily.fromJson(map, fallbackDate: date);
  }

  /// Deserializes a Firestore DocumentSnapshot defensively.
  factory HealthDaily.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final docDate = (data['date'] as String?)?.trim();
    final effectiveDate = (docDate != null && docDate.isNotEmpty)
        ? docDate
        : doc.id;
    return HealthDaily.fromJson(data, fallbackDate: effectiveDate);
  }

  /// Deserializes a Map with defensive type casting for int, double, num, String, and Timestamp.
  factory HealthDaily.fromJson(
    Map<String, dynamic> json, {
    String fallbackDate = '',
  }) {
    final dateVal = json['date'] as String? ?? fallbackDate;

    return HealthDaily(
      date: dateVal,
      steps: _parseInt(json['steps']),
      calories: _parseInt(json['calories']),
      distanceMeters: _parseDouble(json['distanceMeters']),
      activeMinutes: _parseInt(json['activeMinutes']),
      restingHeartRate: _parseInt(json['restingHeartRate']),
      sleepMinutes: _parseInt(json['sleepMinutes']),
      sleepScore: _parseInt(json['sleepScore']),
      hrvRmssd: _parseDouble(json['hrvRmssd']) ?? _parseDouble(json['avgHrv']),
      spo2Percentage:
          _parseDouble(json['spo2Percentage']) ?? _parseDouble(json['avgSpo2']),
      breathingRate: _parseDouble(json['breathingRate']),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      lastSyncedAt:
          _parseDateTime(json['lastSyncedAt']) ??
          _parseDateTime(json['updatedAt']) ??
          _parseDateTime(json['syncedAt']),
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      if (steps != null) 'steps': steps,
      if (calories != null) 'calories': calories,
      if (distanceMeters != null) 'distanceMeters': distanceMeters,
      if (activeMinutes != null) 'activeMinutes': activeMinutes,
      if (restingHeartRate != null) 'restingHeartRate': restingHeartRate,
      if (sleepMinutes != null) 'sleepMinutes': sleepMinutes,
      if (sleepScore != null) 'sleepScore': sleepScore,
      if (hrvRmssd != null) 'hrvRmssd': hrvRmssd,
      if (hrvRmssd != null) 'avgHrv': hrvRmssd,
      if (spo2Percentage != null) 'spo2Percentage': spo2Percentage,
      if (spo2Percentage != null) 'avgSpo2': spo2Percentage,
      if (breathingRate != null) 'breathingRate': breathingRate,
      if (syncStatus != null) 'syncStatus': syncStatus,
      if (lastSyncedAt != null)
        'lastSyncedAt': Timestamp.fromDate(lastSyncedAt!),
      if (lastSyncedAt != null)
        'updatedAt': Timestamp.fromDate(lastSyncedAt!),
      if (source != null) 'source': source,
    };
  }

  HealthDaily copyWith({
    String? date,
    int? steps,
    int? calories,
    double? distanceMeters,
    int? activeMinutes,
    int? restingHeartRate,
    int? sleepMinutes,
    int? sleepScore,
    double? hrvRmssd,
    double? spo2Percentage,
    double? breathingRate,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? source,
  }) {
    return HealthDaily(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      sleepScore: sleepScore ?? this.sleepScore,
      hrvRmssd: hrvRmssd ?? this.hrvRmssd,
      spo2Percentage: spo2Percentage ?? this.spo2Percentage,
      breathingRate: breathingRate ?? this.breathingRate,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      source: source ?? this.source,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  @override
  List<Object?> get props => [
    date,
    steps,
    calories,
    distanceMeters,
    activeMinutes,
    restingHeartRate,
    sleepMinutes,
    sleepScore,
    hrvRmssd,
    spo2Percentage,
    breathingRate,
    syncStatus,
    lastSyncedAt,
    source,
  ];
}

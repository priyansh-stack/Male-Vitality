import 'package:equatable/equatable.dart';
import 'risk_alert.dart';

class RiskProfile extends Equatable {
  final String userId;
  final List<RiskAlert> activeAlerts;
  final List<RiskAlert> historicalAlerts;
  final Map<RiskType, double> riskScores; // 0.0 - 1.0
  final DateTime lastAssessed;
  final int totalAssessments;
  final bool isHighRisk;

  const RiskProfile({
    required this.userId,
    this.activeAlerts = const [],
    this.historicalAlerts = const [],
    this.riskScores = const {},
    required this.lastAssessed,
    this.totalAssessments = 0,
    this.isHighRisk = false,
  });

  factory RiskProfile.fromMap(Map<String, dynamic> map) {
    return RiskProfile(
      userId: map['userId'] ?? '',
      activeAlerts: (map['activeAlerts'] as List<dynamic>?)
          ?.map((e) => RiskAlert.fromMap(Map<String, dynamic>.from(e)))
          .toList() ?? [],
      historicalAlerts: (map['historicalAlerts'] as List<dynamic>?)
          ?.map((e) => RiskAlert.fromMap(Map<String, dynamic>.from(e)))
          .toList() ?? [],
      riskScores: (map['riskScores'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(
                RiskType.values.firstWhere((e) => e.toString() == key),
                (value as num).toDouble(),
              ))
          .map((key, value) => MapEntry(key, value)) ?? {},
      lastAssessed: DateTime.parse(map['lastAssessed'] ?? DateTime.now().toIso8601String()),
      totalAssessments: map['totalAssessments'] ?? 0,
      isHighRisk: map['isHighRisk'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'activeAlerts': activeAlerts.map((e) => e.toMap()).toList(),
      'historicalAlerts': historicalAlerts.map((e) => e.toMap()).toList(),
      'riskScores': riskScores.map((key, value) => MapEntry(key.toString(), value)),
      'lastAssessed': lastAssessed.toIso8601String(),
      'totalAssessments': totalAssessments,
      'isHighRisk': isHighRisk,
    };
  }

  double getOverallRiskScore() {
    if (riskScores.isEmpty) return 0.0;
    return riskScores.values.reduce((a, b) => a + b) / riskScores.length;
  }

  bool hasActiveRisk(RiskType type) {
    return activeAlerts.any((alert) => alert.type == type);
  }

  @override
  List<Object?> get props => [
    userId, activeAlerts, historicalAlerts, riskScores, lastAssessed, totalAssessments, isHighRisk
  ];
}
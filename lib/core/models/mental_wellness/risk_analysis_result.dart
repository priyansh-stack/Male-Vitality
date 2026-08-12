import 'package:equatable/equatable.dart';
import 'risk_alert.dart';

class RiskAnalysisResult extends Equatable {
  final String userId;
  final DateTime analyzedAt;
  final List<RiskAlert> alerts;
  final Map<RiskType, double> riskScores;
  final bool hasCriticalRisk;
  final bool hasHighRisk;
  final String summary;
  final List<String> recommendations;

  const RiskAnalysisResult({
    required this.userId,
    required this.analyzedAt,
    this.alerts = const [],
    this.riskScores = const {},
    this.hasCriticalRisk = false,
    this.hasHighRisk = false,
    this.summary = '',
    this.recommendations = const [],
  });

  factory RiskAnalysisResult.fromMap(Map<String, dynamic> map) {
    return RiskAnalysisResult(
      userId: map['userId'] ?? '',
      analyzedAt: DateTime.parse(map['analyzedAt'] ?? DateTime.now().toIso8601String()),
      alerts: (map['alerts'] as List<dynamic>?)
          ?.map((e) => RiskAlert.fromMap(Map<String, dynamic>.from(e)))
          .toList() ?? [],
      riskScores: (map['riskScores'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(
                RiskType.values.firstWhere((e) => e.toString() == key),
                (value as num).toDouble(),
              ))
          .map((key, value) => MapEntry(key, value)) ?? {},
      hasCriticalRisk: map['hasCriticalRisk'] ?? false,
      hasHighRisk: map['hasHighRisk'] ?? false,
      summary: map['summary'] ?? '',
      recommendations: List<String>.from(map['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'analyzedAt': analyzedAt.toIso8601String(),
      'alerts': alerts.map((e) => e.toMap()).toList(),
      'riskScores': riskScores.map((key, value) => MapEntry(key.toString(), value)),
      'hasCriticalRisk': hasCriticalRisk,
      'hasHighRisk': hasHighRisk,
      'summary': summary,
      'recommendations': recommendations,
    };
  }

  RiskSeverity getHighestSeverity() {
    if (hasCriticalRisk) return RiskSeverity.critical;
    if (hasHighRisk) return RiskSeverity.high;
    if (alerts.any((a) => a.severity == RiskSeverity.moderate)) {
      return RiskSeverity.moderate;
    }
    if (alerts.isNotEmpty) return RiskSeverity.low;
    return RiskSeverity.low;
  }

  bool get hasAnyRisk => alerts.isNotEmpty;

  @override
  List<Object?> get props => [
    userId, analyzedAt, alerts, riskScores, hasCriticalRisk,
    hasHighRisk, summary, recommendations
  ];
}
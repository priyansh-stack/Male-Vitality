import 'dart:ui';

import 'package:equatable/equatable.dart';

enum RiskType {
  depression,
  anxiety,
  suicidal,
  panic,
  stress,
  burnout,
}

enum RiskSeverity {
  low,
  moderate,
  high,
  critical,
}

extension RiskTypeExtension on RiskType {
  String get displayName {
    switch (this) {
      case RiskType.depression:
        return 'Depression';
      case RiskType.anxiety:
        return 'Anxiety';
      case RiskType.suicidal:
        return 'Suicidal Ideation';
      case RiskType.panic:
        return 'Panic Disorder';
      case RiskType.stress:
        return 'Chronic Stress';
      case RiskType.burnout:
        return 'Burnout';
    }
  }

  Color get color {
    switch (this) {
      case RiskType.depression:
        return Color(0xFF6366F1);
      case RiskType.anxiety:
        return Color(0xFFF59E0B);
      case RiskType.suicidal:
        return Color(0xFFDC2626);
      case RiskType.panic:
        return Color(0xFFEC4899);
      case RiskType.stress:
        return Color(0xFFF97316);
      case RiskType.burnout:
        return Color(0xFF8B5CF6);
    }
  }
}

extension RiskSeverityExtension on RiskSeverity {
  String get displayName {
    switch (this) {
      case RiskSeverity.low:
        return 'Low';
      case RiskSeverity.moderate:
        return 'Moderate';
      case RiskSeverity.high:
        return 'High';
      case RiskSeverity.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case RiskSeverity.low:
        return Color(0xFF10B981);
      case RiskSeverity.moderate:
        return Color(0xFFF59E0B);
      case RiskSeverity.high:
        return Color(0xFFF97316);
      case RiskSeverity.critical:
        return Color(0xFFDC2626);
    }
  }

  int get priority {
    switch (this) {
      case RiskSeverity.low:
        return 1;
      case RiskSeverity.moderate:
        return 2;
      case RiskSeverity.high:
        return 3;
      case RiskSeverity.critical:
        return 4;
    }
  }
}

class RiskAlert extends Equatable {
  final String id;
  final String userId;
  final RiskType type;
  final RiskSeverity severity;
  final String message;
  final List<String> recommendations;
  final DateTime detectedAt;
  final bool acknowledged;
  final bool escalated;
  final DateTime? acknowledgedAt;
  final Map<String, dynamic> contextData;

  const RiskAlert({
    required this.id,
    required this.userId,
    required this.type,
    required this.severity,
    required this.message,
    this.recommendations = const [],
    required this.detectedAt,
    this.acknowledged = false,
    this.escalated = false,
    this.acknowledgedAt,
    this.contextData = const {},
  });

  factory RiskAlert.fromMap(Map<String, dynamic> map) {
    return RiskAlert(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: RiskType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => RiskType.stress,
      ),
      severity: RiskSeverity.values.firstWhere(
        (e) => e.toString() == map['severity'],
        orElse: () => RiskSeverity.low,
      ),
      message: map['message'] ?? '',
      recommendations: List<String>.from(map['recommendations'] ?? []),
      detectedAt: DateTime.parse(map['detectedAt'] ?? DateTime.now().toIso8601String()),
      acknowledged: map['acknowledged'] ?? false,
      escalated: map['escalated'] ?? false,
      acknowledgedAt: map['acknowledgedAt'] != null
          ? DateTime.parse(map['acknowledgedAt'])
          : null,
      contextData: Map<String, dynamic>.from(map['contextData'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'severity': severity.toString(),
      'message': message,
      'recommendations': recommendations,
      'detectedAt': detectedAt.toIso8601String(),
      'acknowledged': acknowledged,
      'escalated': escalated,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'contextData': contextData,
    };
  }

  RiskAlert copyWith({
    String? id,
    String? userId,
    RiskType? type,
    RiskSeverity? severity,
    String? message,
    List<String>? recommendations,
    DateTime? detectedAt,
    bool? acknowledged,
    bool? escalated,
    DateTime? acknowledgedAt,
    Map<String, dynamic>? contextData,
  }) {
    return RiskAlert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      recommendations: recommendations ?? this.recommendations,
      detectedAt: detectedAt ?? this.detectedAt,
      acknowledged: acknowledged ?? this.acknowledged,
      escalated: escalated ?? this.escalated,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      contextData: contextData ?? this.contextData,
    );
  }

  bool get requiresImmediateAction => severity == RiskSeverity.high || severity == RiskSeverity.critical;

  @override
  List<Object?> get props => [
    id, userId, type, severity, message, recommendations,
    detectedAt, acknowledged, escalated, acknowledgedAt, contextData
  ];
}
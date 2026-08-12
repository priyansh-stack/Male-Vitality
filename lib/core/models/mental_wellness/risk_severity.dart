import 'package:flutter/material.dart';

enum RiskSeverity {
  low,
  moderate,
  high,
  critical,
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

  String get shortName {
    switch (this) {
      case RiskSeverity.low:
        return 'Low';
      case RiskSeverity.moderate:
        return 'Mod';
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

  Color get backgroundColor {
    switch (this) {
      case RiskSeverity.low:
        return Color(0xFFD1FAE5);
      case RiskSeverity.moderate:
        return Color(0xFFFEF3C7);
      case RiskSeverity.high:
        return Color(0xFFFED7AA);
      case RiskSeverity.critical:
        return Color(0xFFFEE2E2);
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

  String get emoji {
    switch (this) {
      case RiskSeverity.low:
        return '🟢';
      case RiskSeverity.moderate:
        return '🟡';
      case RiskSeverity.high:
        return '🟠';
      case RiskSeverity.critical:
        return '🔴';
    }
  }

  String get recommendation {
    switch (this) {
      case RiskSeverity.low:
        return 'Continue monitoring and maintain wellness practices';
      case RiskSeverity.moderate:
        return 'Consider seeking professional support and increase self-care';
      case RiskSeverity.high:
        return 'Please consult with a mental health professional as soon as possible';
      case RiskSeverity.critical:
        return 'Immediate attention required. Please contact emergency services or call 988';
    }
  }

  bool get requiresImmediateAction {
    return this == RiskSeverity.high || this == RiskSeverity.critical;
  }

  bool get requiresProfessionalConsultation {
    return this == RiskSeverity.moderate || this == RiskSeverity.high;
  }
}
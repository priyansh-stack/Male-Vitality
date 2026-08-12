// This file consolidates all enum imports for easy access

import 'dart:ui';

export 'exercise_type.dart';
export 'risk_type.dart';
export 'risk_severity.dart';
export 'trigger_type.dart';
export 'therapist_specialty.dart';
export 'life_stage_adapter.dart';

// Additional shared enums

enum MentalHealthStatus {
  stable,
  improving,
  declining,
  critical,
}

extension MentalHealthStatusExtension on MentalHealthStatus {
  String get displayName {
    switch (this) {
      case MentalHealthStatus.stable:
        return 'Stable';
      case MentalHealthStatus.improving:
        return 'Improving';
      case MentalHealthStatus.declining:
        return 'Declining';
      case MentalHealthStatus.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case MentalHealthStatus.stable:
        return Color(0xFF10B981);
      case MentalHealthStatus.improving:
        return Color(0xFF06B6D4);
      case MentalHealthStatus.declining:
        return Color(0xFFF59E0B);
      case MentalHealthStatus.critical:
        return Color(0xFFDC2626);
    }
  }
}

enum CrisisAction {
  call988,
  text741741,
  call911,
  warmLine,
  therapist,
  emergencyRoom,
}

extension CrisisActionExtension on CrisisAction {
  String get displayName {
    switch (this) {
      case CrisisAction.call988:
        return 'Call 988';
      case CrisisAction.text741741:
        return 'Text HOME to 741741';
      case CrisisAction.call911:
        return 'Call 911';
      case CrisisAction.warmLine:
        return 'Warm Line';
      case CrisisAction.therapist:
        return 'Contact Therapist';
      case CrisisAction.emergencyRoom:
        return 'Go to ER';
    }
  }

  String get phoneNumber {
    switch (this) {
      case CrisisAction.call988:
        return '988';
      case CrisisAction.text741741:
        return '741741';
      case CrisisAction.call911:
        return '911';
      case CrisisAction.warmLine:
        return '1-800-662-4357';
      case CrisisAction.therapist:
        return '';
      case CrisisAction.emergencyRoom:
        return '911';
    }
  }

  bool get isImmediate {
    switch (this) {
      case CrisisAction.call988:
      case CrisisAction.text741741:
      case CrisisAction.call911:
      case CrisisAction.emergencyRoom:
        return true;
      case CrisisAction.warmLine:
      case CrisisAction.therapist:
        return false;
    }
  }
}
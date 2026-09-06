class FallAlert {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String locationEstimate;
  final bool isResolved;
  final String status; // "Alert Sent", "User Cancelled", "Emergency Contact Notified"

  const FallAlert({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.locationEstimate,
    this.isResolved = false,
    this.status = 'Alert Sent',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
        'locationEstimate': locationEstimate,
        'isResolved': isResolved,
        'status': status,
      };

  factory FallAlert.fromMap(Map<String, dynamic> map, String id) {
    return FallAlert(
      id: id,
      userId: map['userId'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      locationEstimate: map['locationEstimate'] ?? 'Home Location',
      isResolved: map['isResolved'] ?? false,
      status: map['status'] ?? 'Alert Sent',
    );
  }
}

class CognitiveScore {
  final String id;
  final String userId;
  final DateTime date;
  final String gameType; // "Memory Match", "Reaction Speed", "Pattern Recognition"
  final int score;
  final int timeSeconds;

  const CognitiveScore({
    required this.id,
    required this.userId,
    required this.date,
    required this.gameType,
    required this.score,
    required this.timeSeconds,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'gameType': gameType,
        'score': score,
        'timeSeconds': timeSeconds,
      };

  factory CognitiveScore.fromMap(Map<String, dynamic> map, String id) {
    return CognitiveScore(
      id: id,
      userId: map['userId'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      gameType: map['gameType'] ?? 'Memory Match',
      score: map['score'] ?? 0,
      timeSeconds: map['timeSeconds'] ?? 0,
    );
  }
}

class CaregiverProfile {
  final String linkId;
  final String seniorUserId;
  final String caregiverName;
  final String caregiverEmail;
  final String caregiverPhone;
  final String relationship; // e.g. "Son", "Daughter", "Nurse"
  final bool canViewVitals;
  final bool canViewMedications;
  final bool receivesFallAlerts;

  const CaregiverProfile({
    required this.linkId,
    required this.seniorUserId,
    required this.caregiverName,
    required this.caregiverEmail,
    required this.caregiverPhone,
    required this.relationship,
    this.canViewVitals = true,
    this.canViewMedications = true,
    this.receivesFallAlerts = true,
  });

  Map<String, dynamic> toMap() => {
        'linkId': linkId,
        'seniorUserId': seniorUserId,
        'caregiverName': caregiverName,
        'caregiverEmail': caregiverEmail,
        'caregiverPhone': caregiverPhone,
        'relationship': relationship,
        'canViewVitals': canViewVitals,
        'canViewMedications': canViewMedications,
        'receivesFallAlerts': receivesFallAlerts,
      };

  factory CaregiverProfile.fromMap(Map<String, dynamic> map, String id) {
    return CaregiverProfile(
      linkId: id,
      seniorUserId: map['seniorUserId'] ?? '',
      caregiverName: map['caregiverName'] ?? '',
      caregiverEmail: map['caregiverEmail'] ?? '',
      caregiverPhone: map['caregiverPhone'] ?? '',
      relationship: map['relationship'] ?? 'Caregiver',
      canViewVitals: map['canViewVitals'] ?? true,
      canViewMedications: map['canViewMedications'] ?? true,
      receivesFallAlerts: map['receivesFallAlerts'] ?? true,
    );
  }
}

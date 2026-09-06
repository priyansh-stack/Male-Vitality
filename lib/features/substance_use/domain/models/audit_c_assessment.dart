class AuditCAssessment {
  final String id;
  final String userId;
  final DateTime timestamp;
  final int q1FrequencyScore; // 0-4 (How often do you have a drink containing alcohol?)
  final int q2QuantityScore; // 0-4 (How many drinks on a typical day when drinking?)
  final int q3BingeScore; // 0-4 (How often do you have 6 or more drinks on one occasion?)
  final String userReductionGoal;

  const AuditCAssessment({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.q1FrequencyScore,
    required this.q2QuantityScore,
    required this.q3BingeScore,
    this.userReductionGoal = 'Maintain healthy limits (< 2 drinks/day)',
  });

  /// Total AUDIT-C score (0 to 12)
  int get totalScore => q1FrequencyScore + q2QuantityScore + q3BingeScore;

  /// In men, a score of 4 or more is considered positive for hazardous drinking
  bool get isHazardousDrinking => totalScore >= 4;

  String get riskCategory {
    if (totalScore <= 3) return 'Low Risk / Within Guidelines';
    if (totalScore <= 6) return 'Moderate / Hazardous Drinking';
    if (totalScore <= 8) return 'High Risk Drinking';
    return 'Severe Risk / Alcohol Dependence Indication';
  }

  String get clinicalGuidance {
    if (totalScore <= 3) {
      return 'Your alcohol consumption falls within low-risk limits according to federal dietary guidelines (≤ 2 standard drinks daily for men).';
    } else if (totalScore <= 6) {
      return 'Your score reflects hazardous consumption patterns that elevate long-term risks for hypertension, liver enzyme elevation, and sleep fragmentation.';
    } else {
      return 'Your pattern indicates high risk. Consider speaking with a primary physician or counselor. SAMHSA confidential assistance is available 24/7.';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
        'q1FrequencyScore': q1FrequencyScore,
        'q2QuantityScore': q2QuantityScore,
        'q3BingeScore': q3BingeScore,
        'userReductionGoal': userReductionGoal,
      };

  factory AuditCAssessment.fromMap(Map<String, dynamic> map, String id) {
    return AuditCAssessment(
      id: id,
      userId: map['userId'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      q1FrequencyScore: map['q1FrequencyScore'] ?? 0,
      q2QuantityScore: map['q2QuantityScore'] ?? 0,
      q3BingeScore: map['q3BingeScore'] ?? 0,
      userReductionGoal: map['userReductionGoal'] ?? '',
    );
  }
}

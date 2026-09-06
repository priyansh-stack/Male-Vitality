enum StiRiskLevel {
  low,
  moderate,
  elevated,
}

class StiRiskAssessment {
  final String id;
  final String userId;
  final DateTime date;
  final bool hasMultiplePartners;
  final bool usesCondomsConsistently;
  final bool hasUnusualDischargeOrPain;
  final bool partnerHasStiHistory;
  final StiRiskLevel riskLevel;
  final String recommendation;

  const StiRiskAssessment({
    required this.id,
    required this.userId,
    required this.date,
    required this.hasMultiplePartners,
    required this.usesCondomsConsistently,
    required this.hasUnusualDischargeOrPain,
    required this.partnerHasStiHistory,
    required this.riskLevel,
    required this.recommendation,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'hasMultiplePartners': hasMultiplePartners,
        'usesCondomsConsistently': usesCondomsConsistently,
        'hasUnusualDischargeOrPain': hasUnusualDischargeOrPain,
        'partnerHasStiHistory': partnerHasStiHistory,
        'riskLevel': riskLevel.name,
        'recommendation': recommendation,
      };

  factory StiRiskAssessment.fromMap(Map<String, dynamic> map) => StiRiskAssessment(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
        hasMultiplePartners: map['hasMultiplePartners'] ?? false,
        usesCondomsConsistently: map['usesCondomsConsistently'] ?? true,
        hasUnusualDischargeOrPain: map['hasUnusualDischargeOrPain'] ?? false,
        partnerHasStiHistory: map['partnerHasStiHistory'] ?? false,
        riskLevel: StiRiskLevel.values.firstWhere(
          (e) => e.name == map['riskLevel'],
          orElse: () => StiRiskLevel.low,
        ),
        recommendation: map['recommendation'] ?? '',
      );

  static StiRiskAssessment evaluate({
    required String id,
    required String userId,
    required bool hasMultiplePartners,
    required bool usesCondomsConsistently,
    required bool hasUnusualDischargeOrPain,
    required bool partnerHasStiHistory,
  }) {
    StiRiskLevel level = StiRiskLevel.low;
    String rec = 'Routine annual or 3-year STI screening is recommended.';

    if (hasUnusualDischargeOrPain) {
      level = StiRiskLevel.elevated;
      rec = 'Active physical symptoms detected. We strongly advise an immediate in-person clinical exam and nucleic acid amplification test (NAAT).';
    } else if (hasMultiplePartners && !usesCondomsConsistently) {
      level = StiRiskLevel.elevated;
      rec = 'High exposure probability. Schedule a 4-panel screening (HIV, Syphilis, Chlamydia, Gonorrhea) within the next 7 days.';
    } else if (partnerHasStiHistory || hasMultiplePartners) {
      level = StiRiskLevel.moderate;
      rec = 'Moderate risk profile. Quarterly testing is recommended for peace of mind.';
    }

    return StiRiskAssessment(
      id: id,
      userId: userId,
      date: DateTime.now(),
      hasMultiplePartners: hasMultiplePartners,
      usesCondomsConsistently: usesCondomsConsistently,
      hasUnusualDischargeOrPain: hasUnusualDischargeOrPain,
      partnerHasStiHistory: partnerHasStiHistory,
      riskLevel: level,
      recommendation: rec,
    );
  }
}

class TestingCenter {
  final String name;
  final String address;
  final String distance;
  final String phone;
  final bool offersFreeTesting;

  const TestingCenter({
    required this.name,
    required this.address,
    required this.distance,
    required this.phone,
    required this.offersFreeTesting,
  });
}

class SemenAnalysisRecord {
  final String id;
  final String userId;
  final DateTime testDate;
  final int abstinenceDays; // Recommended: 2-7 days
  final double volumeMl; // WHO Lower Reference Limit: 1.4 mL
  final double spermConcentrationMillionPerMl; // WHO Limit: 16 M/mL
  final double totalMotilityPercent; // WHO Limit: 42%
  final double progressiveMotilityPercent; // WHO Limit: 30%
  final double normalMorphologyPercent; // Kruger Strict Criteria: 4%
  final String notes;

  const SemenAnalysisRecord({
    required this.id,
    required this.userId,
    required this.testDate,
    required this.abstinenceDays,
    required this.volumeMl,
    required this.spermConcentrationMillionPerMl,
    required this.totalMotilityPercent,
    required this.progressiveMotilityPercent,
    required this.normalMorphologyPercent,
    this.notes = '',
  });

  // Total Sperm Count per Ejaculate (Volume * Concentration)
  double get totalSpermCountMillion => volumeMl * spermConcentrationMillionPerMl;

  // Clinical Evaluations based on WHO Laboratory Manual (6th Edition)
  bool get isVolumeNormal => volumeMl >= 1.4;
  bool get isConcentrationNormal => spermConcentrationMillionPerMl >= 16.0;
  bool get isMotilityNormal => totalMotilityPercent >= 42.0;
  bool get isProgressiveMotilityNormal => progressiveMotilityPercent >= 30.0;
  bool get isMorphologyNormal => normalMorphologyPercent >= 4.0;

  bool get isOptimal =>
      isVolumeNormal &&
      isConcentrationNormal &&
      isMotilityNormal &&
      isProgressiveMotilityNormal &&
      isMorphologyNormal;

  List<String> get clinicalFindings {
    final findings = <String>[];
    if (!isVolumeNormal) findings.add('Low Ejaculate Volume (<1.4 mL / Hypospermia)');
    if (!isConcentrationNormal) findings.add('Low Sperm Concentration (<16 M/mL / Oligozoospermia)');
    if (!isMotilityNormal) findings.add('Reduced Sperm Motility (<42% / Asthenozoospermia)');
    if (!isProgressiveMotilityNormal) findings.add('Reduced Progressive Motility (<30%)');
    if (!isMorphologyNormal) findings.add('Suboptimal Sperm Morphology (<4% Kruger / Teratozoospermia)');
    if (findings.isEmpty) findings.add('Normozoospermia (All WHO 6th Edition Parameters Normal)');
    return findings;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'testDate': testDate.toIso8601String(),
      'abstinenceDays': abstinenceDays,
      'volumeMl': volumeMl,
      'spermConcentrationMillionPerMl': spermConcentrationMillionPerMl,
      'totalMotilityPercent': totalMotilityPercent,
      'progressiveMotilityPercent': progressiveMotilityPercent,
      'normalMorphologyPercent': normalMorphologyPercent,
      'notes': notes,
    };
  }

  factory SemenAnalysisRecord.fromMap(Map<String, dynamic> map, String docId) {
    return SemenAnalysisRecord(
      id: docId,
      userId: map['userId'] ?? '',
      testDate: DateTime.tryParse(map['testDate'] ?? '') ?? DateTime.now(),
      abstinenceDays: (map['abstinenceDays'] as num?)?.toInt() ?? 3,
      volumeMl: (map['volumeMl'] as num?)?.toDouble() ?? 2.0,
      spermConcentrationMillionPerMl: (map['spermConcentrationMillionPerMl'] as num?)?.toDouble() ?? 25.0,
      totalMotilityPercent: (map['totalMotilityPercent'] as num?)?.toDouble() ?? 50.0,
      progressiveMotilityPercent: (map['progressiveMotilityPercent'] as num?)?.toDouble() ?? 35.0,
      normalMorphologyPercent: (map['normalMorphologyPercent'] as num?)?.toDouble() ?? 5.0,
      notes: map['notes'] ?? '',
    );
  }
}

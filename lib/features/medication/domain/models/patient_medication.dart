class PatientMedication {
  final String id;
  final String userId;
  final String name; // e.g. "Lisinopril"
  final String dosage; // e.g. "10 mg"
  final String frequency; // e.g. "Once daily in morning"
  final String prescriber; // e.g. "Dr. Sarah Jenkins (Cardiology)"
  final DateTime? refillDate;
  final int totalDosesScheduled;
  final int totalDosesTaken;
  final bool isReminderEnabled;

  const PatientMedication({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.prescriber,
    this.refillDate,
    this.totalDosesScheduled = 30,
    this.totalDosesTaken = 28,
    this.isReminderEnabled = true,
  });

  double get adherenceRate {
    if (totalDosesScheduled == 0) return 1.0;
    return (totalDosesTaken / totalDosesScheduled).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'prescriber': prescriber,
        'refillDate': refillDate?.toIso8601String(),
        'totalDosesScheduled': totalDosesScheduled,
        'totalDosesTaken': totalDosesTaken,
        'isReminderEnabled': isReminderEnabled,
      };

  factory PatientMedication.fromMap(Map<String, dynamic> map, String id) {
    return PatientMedication(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? 'Daily',
      prescriber: map['prescriber'] ?? '',
      refillDate: map['refillDate'] != null ? DateTime.parse(map['refillDate']) : null,
      totalDosesScheduled: map['totalDosesScheduled'] ?? 30,
      totalDosesTaken: map['totalDosesTaken'] ?? 28,
      isReminderEnabled: map['isReminderEnabled'] ?? true,
    );
  }

  PatientMedication copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    String? frequency,
    String? prescriber,
    DateTime? refillDate,
    int? totalDosesScheduled,
    int? totalDosesTaken,
    bool? isReminderEnabled,
  }) {
    return PatientMedication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      prescriber: prescriber ?? this.prescriber,
      refillDate: refillDate ?? this.refillDate,
      totalDosesScheduled: totalDosesScheduled ?? this.totalDosesScheduled,
      totalDosesTaken: totalDosesTaken ?? this.totalDosesTaken,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
    );
  }
}

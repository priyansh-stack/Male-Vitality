class Medication {
  final String name;
  final String dosage;
  final String frequency;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
    );
  }
}

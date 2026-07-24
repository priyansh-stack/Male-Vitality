class EmergencyContact {
  final String name;
  final String relationship;
  final String phoneNumber;
  final String? email;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
    );
  }
}

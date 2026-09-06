class TelehealthDoctor {
  final String id;
  final String name;
  final String specialty; // e.g. "Urologist & Andrologist", "Cardiologist", "Men's Health PCP"
  final String bio;
  final double rating;
  final int reviewsCount;
  final String avatarUrl;
  final List<String> availableTimes;
  final String? hospitalAffiliation;
  final String? nextAvailableSlot;
  final double consultationFeeUsd;

  const TelehealthDoctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.bio = 'Licensed specialist in comprehensive men\'s health and clinical vitality.',
    required this.rating,
    required this.reviewsCount,
    required this.avatarUrl,
    this.availableTimes = const ['Today at 3:30 PM', 'Tomorrow at 10:00 AM', 'Thursday at 2:00 PM'],
    this.hospitalAffiliation,
    this.nextAvailableSlot,
    this.consultationFeeUsd = 75.0,
  });
}

class TelehealthAppointment {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final DateTime scheduledTime;
  final String status; // "Scheduled", "Completed", "Cancelled"
  final String meetingLink;

  const TelehealthAppointment({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.scheduledTime,
    this.status = 'Scheduled',
    required this.meetingLink,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'specialty': specialty,
        'scheduledTime': scheduledTime.toIso8601String(),
        'status': status,
        'meetingLink': meetingLink,
      };

  factory TelehealthAppointment.fromMap(Map<String, dynamic> map, String id) {
    return TelehealthAppointment(
      id: id,
      userId: map['userId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      specialty: map['specialty'] ?? '',
      scheduledTime: map['scheduledTime'] != null ? DateTime.parse(map['scheduledTime']) : DateTime.now(),
      status: map['status'] ?? 'Scheduled',
      meetingLink: map['meetingLink'] ?? '',
    );
  }
}

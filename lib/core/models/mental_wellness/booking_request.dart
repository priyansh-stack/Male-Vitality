import 'package:equatable/equatable.dart';

class BookingRequest extends Equatable {
  final String therapistId;
  final String userId;
  final DateTime requestedDate;
  final DateTime requestedTime;
  final String? notes;
  final bool isTeletherapy;
  final String? preferredModality;
  final String? insuranceProvider;

  const BookingRequest({
    required this.therapistId,
    required this.userId,
    required this.requestedDate,
    required this.requestedTime,
    this.notes,
    this.isTeletherapy = false,
    this.preferredModality,
    this.insuranceProvider,
  });

  factory BookingRequest.fromMap(Map<String, dynamic> map) {
    return BookingRequest(
      therapistId: map['therapistId'] ?? '',
      userId: map['userId'] ?? '',
      requestedDate: DateTime.parse(map['requestedDate'] ?? DateTime.now().toIso8601String()),
      requestedTime: DateTime.parse(map['requestedTime'] ?? DateTime.now().toIso8601String()),
      notes: map['notes'],
      isTeletherapy: map['isTeletherapy'] ?? false,
      preferredModality: map['preferredModality'],
      insuranceProvider: map['insuranceProvider'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'therapistId': therapistId,
      'userId': userId,
      'requestedDate': requestedDate.toIso8601String(),
      'requestedTime': requestedTime.toIso8601String(),
      'notes': notes,
      'isTeletherapy': isTeletherapy,
      'preferredModality': preferredModality,
      'insuranceProvider': insuranceProvider,
    };
  }

  @override
  List<Object?> get props => [
    therapistId, userId, requestedDate, requestedTime, notes,
    isTeletherapy, preferredModality, insuranceProvider
  ];
}
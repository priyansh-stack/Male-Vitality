import 'life_stage.dart';
import 'lifestyle_factors.dart';
import 'emergency_contact.dart';
import 'medication.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final DateTime dateOfBirth;
  final String gender;
  final List<String> healthConditions;
  final List<Medication> medications;
  final LifestyleFactors lifestyle;
  final EmergencyContact? emergencyContact;
  final Map<String, dynamic> insuranceDetails;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.dateOfBirth,
    required this.gender,
    required this.healthConditions,
    required this.medications,
    required this.lifestyle,
    this.emergencyContact,
    required this.insuranceDetails,
    this.onboardingCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  LifeStage get lifeStage => LifeStage.calculateFromDOB(dateOfBirth);

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'healthConditions': healthConditions,
      'medications': medications.map((m) => m.toMap()).toList(),
      'lifestyle': lifestyle.toMap(),
      'emergencyContact': emergencyContact?.toMap(),
      'insuranceDetails': insuranceDetails,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      dateOfBirth: DateTime.tryParse(map['dateOfBirth'] ?? '') ?? DateTime(1995, 1, 1),
      gender: map['gender'] ?? 'Not Specified',
      healthConditions: List<String>.from(map['healthConditions'] ?? []),
      medications: (map['medications'] as List<dynamic>?)
              ?.map((m) => Medication.fromMap(Map<String, dynamic>.from(m)))
              .toList() ??
          [],
      lifestyle: map['lifestyle'] != null
          ? LifestyleFactors.fromMap(Map<String, dynamic>.from(map['lifestyle']))
          : LifestyleFactors(),
      emergencyContact: map['emergencyContact'] != null
          ? EmergencyContact.fromMap(Map<String, dynamic>.from(map['emergencyContact']))
          : null,
      insuranceDetails: Map<String, dynamic>.from(map['insuranceDetails'] ?? {}),
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? healthConditions,
    List<Medication>? medications,
    LifestyleFactors? lifestyle,
    EmergencyContact? emergencyContact,
    Map<String, dynamic>? insuranceDetails,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      healthConditions: healthConditions ?? this.healthConditions,
      medications: medications ?? this.medications,
      lifestyle: lifestyle ?? this.lifestyle,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      insuranceDetails: insuranceDetails ?? this.insuranceDetails,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

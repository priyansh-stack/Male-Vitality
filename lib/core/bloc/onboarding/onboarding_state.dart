import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';
import '../../models/life_stage.dart';
import '../../models/lifestyle_factors.dart';
import '../../models/emergency_contact.dart';
import '../../models/medication.dart';

class OnboardingState extends Equatable {
  final int step;
  final String displayName;
  final DateTime dateOfBirth;
  final String gender;
  final List<String> selectedConditions;
  final List<Medication> medications;
  final LifestyleFactors lifestyle;
  final EmergencyContact? emergencyContact;
  final bool isSubmitting;
  final UserProfile? completedProfile;
  final String? errorMessage;

  LifeStage get detectedLifeStage => LifeStage.calculateFromDOB(dateOfBirth);

  OnboardingState({
    this.step = 0,
    this.displayName = '',
    DateTime? dateOfBirth,
    this.gender = 'Female',
    this.selectedConditions = const [],
    this.medications = const [],
    LifestyleFactors? lifestyle,
    this.emergencyContact,
    this.isSubmitting = false,
    this.completedProfile,
    this.errorMessage,
  })  : dateOfBirth = dateOfBirth ?? DateTime(1998, 6, 15),
        lifestyle = lifestyle ?? LifestyleFactors();

  OnboardingState copyWith({
    int? step,
    String? displayName,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? selectedConditions,
    List<Medication>? medications,
    LifestyleFactors? lifestyle,
    EmergencyContact? emergencyContact,
    bool? isSubmitting,
    UserProfile? completedProfile,
    String? errorMessage,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      selectedConditions: selectedConditions ?? this.selectedConditions,
      medications: medications ?? this.medications,
      lifestyle: lifestyle ?? this.lifestyle,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      completedProfile: completedProfile ?? this.completedProfile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        step,
        displayName,
        dateOfBirth,
        gender,
        selectedConditions,
        medications,
        lifestyle.toMap(),
        emergencyContact?.toMap(),
        isSubmitting,
        completedProfile?.uid,
        errorMessage,
      ];
}

import 'package:equatable/equatable.dart';
import '../../models/lifestyle_factors.dart';
import '../../models/emergency_contact.dart';
import '../../models/medication.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingStarted extends OnboardingEvent {}

class OnboardingStepChanged extends OnboardingEvent {
  final int step;
  const OnboardingStepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

class UpdatePersonalInfoEvent extends OnboardingEvent {
  final String name;
  final DateTime dob;
  final String gender;

  const UpdatePersonalInfoEvent({
    required this.name,
    required this.dob,
    required this.gender,
  });

  @override
  List<Object?> get props => [name, dob, gender];
}

class ToggleHealthConditionEvent extends OnboardingEvent {
  final String condition;
  const ToggleHealthConditionEvent(this.condition);

  @override
  List<Object?> get props => [condition];
}

class AddMedicationEvent extends OnboardingEvent {
  final Medication medication;
  const AddMedicationEvent(this.medication);

  @override
  List<Object?> get props => [medication];
}

class RemoveMedicationEvent extends OnboardingEvent {
  final int index;
  const RemoveMedicationEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateLifestyleFactorsEvent extends OnboardingEvent {
  final LifestyleFactors lifestyle;
  const UpdateLifestyleFactorsEvent(this.lifestyle);

  @override
  List<Object?> get props => [lifestyle];
}

class SaveEmergencyContactEvent extends OnboardingEvent {
  final EmergencyContact? contact;
  const SaveEmergencyContactEvent(this.contact);

  @override
  List<Object?> get props => [contact];
}

class CompleteOnboardingEvent extends OnboardingEvent {
  final String uid;
  final String email;

  const CompleteOnboardingEvent({
    required this.uid,
    required this.email,
  });

  @override
  List<Object?> get props => [uid, email];
}

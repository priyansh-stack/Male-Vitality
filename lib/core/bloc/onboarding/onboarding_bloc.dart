import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_profile.dart';
import '../../services/firestore_service.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final FirestoreService _firestoreService;

  OnboardingBloc(this._firestoreService) : super(OnboardingState()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingStepChanged>(_onStepChanged);
    on<UpdatePersonalInfoEvent>(_onUpdatePersonalInfo);
    on<ToggleHealthConditionEvent>(_onToggleHealthCondition);
    on<AddMedicationEvent>(_onAddMedication);
    on<RemoveMedicationEvent>(_onRemoveMedication);
    on<UpdateLifestyleFactorsEvent>(_onUpdateLifestyleFactors);
    on<SaveEmergencyContactEvent>(_onSaveEmergencyContact);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
    on<LoadSavedProfile>(_onLoadSavedProfile); // ✅ NEW EVENT
  }

  void _onStarted(OnboardingStarted event, Emitter<OnboardingState> emit) {
    emit(OnboardingState());
  }

  void _onStepChanged(
    OnboardingStepChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(step: event.step));
  }

  void _onUpdatePersonalInfo(
    UpdatePersonalInfoEvent event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      displayName: event.name,
      dateOfBirth: event.dob,
      gender: event.gender,
    ));
  }

  void _onToggleHealthCondition(
    ToggleHealthConditionEvent event,
    Emitter<OnboardingState> emit,
  ) {
    final list = List<String>.from(state.selectedConditions);
    if (event.condition == 'None') {
      emit(state.copyWith(selectedConditions: ['None']));
      return;
    }

    list.remove('None');
    if (list.contains(event.condition)) {
      list.remove(event.condition);
    } else {
      list.add(event.condition);
    }
    emit(state.copyWith(selectedConditions: list));
  }

  void _onAddMedication(
    AddMedicationEvent event,
    Emitter<OnboardingState> emit,
  ) {
    final list = List.of(state.medications)..add(event.medication);
    emit(state.copyWith(medications: list));
  }

  void _onRemoveMedication(
    RemoveMedicationEvent event,
    Emitter<OnboardingState> emit,
  ) {
    if (event.index >= 0 && event.index < state.medications.length) {
      final list = List.of(state.medications)..removeAt(event.index);
      emit(state.copyWith(medications: list));
    }
  }

  void _onUpdateLifestyleFactors(
    UpdateLifestyleFactorsEvent event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(lifestyle: event.lifestyle));
  }

  void _onSaveEmergencyContact(
    SaveEmergencyContactEvent event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(emergencyContact: event.contact));
  }

  //  Load saved profile from Firestore
  Future<void> _onLoadSavedProfile(
    LoadSavedProfile event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      debugPrint(' Loading saved profile for user: ${event.uid}');
      final profile = await _firestoreService.getUserProfile(event.uid);
      
      if (profile != null && profile.onboardingCompleted) {
        debugPrint(' Profile loaded successfully');
        emit(state.copyWith(
          completedProfile: profile,
          step: 5,
          displayName: profile.displayName,
          dateOfBirth: profile.dateOfBirth,
          gender: profile.gender,
          selectedConditions: profile.healthConditions,
          medications: profile.medications,
          lifestyle: profile.lifestyle,
          emergencyContact: profile.emergencyContact,
        ));
      } else {
        debugPrint(' No completed profile found');
        emit(state.copyWith(
          completedProfile: null,
          step: 0,
        ));
      }
    } catch (e) {
      debugPrint(' Error loading saved profile: $e');
      emit(state.copyWith(
        errorMessage: e.toString(),
        completedProfile: null,
      ));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      final lifeStage = state.detectedLifeStage;
      
      final profile = UserProfile(
        uid: event.uid,
        email: event.email,
        displayName: state.displayName.isNotEmpty 
            ? state.displayName 
            : event.email.split('@').first,
        dateOfBirth: state.dateOfBirth,
        gender: state.gender,
        healthConditions: state.selectedConditions,
        medications: state.medications,
        lifestyle: state.lifestyle,
        emergencyContact: state.emergencyContact,
        insuranceDetails: {
          'provider': 'Standard Health Plan',
          'policyNumber': 'SHP-${event.uid.hashCode.abs().toString().substring(0, 5)}',
          'verified': true,
        },
        onboardingCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.saveUserProfile(profile);

      emit(state.copyWith(
        isSubmitting: false,
        completedProfile: profile,
        step: 5,
      ));
      
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
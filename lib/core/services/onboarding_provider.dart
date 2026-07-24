import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/life_stage.dart';
import '../models/lifestyle_factors.dart';
import '../models/emergency_contact.dart';
import '../models/medication.dart';
import 'firestore_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  int _currentStep = 0;
  bool _isSaving = false;

  // Form Fields State
  String _displayName = '';
  DateTime _dateOfBirth = DateTime(1998, 6, 15);
  String _gender = 'Male';
  
  List<String> _selectedConditions = [];
  List<Medication> _medications = [];
  LifestyleFactors _lifestyle = LifestyleFactors();
  EmergencyContact? _emergencyContact;

  int get currentStep => _currentStep;
  bool get isSaving => _isSaving;

  String get displayName => _displayName;
  DateTime get dateOfBirth => _dateOfBirth;
  String get gender => _gender;
  List<String> get selectedConditions => List.unmodifiable(_selectedConditions);
  List<Medication> get medications => List.unmodifiable(_medications);
  LifestyleFactors get lifestyle => _lifestyle;
  EmergencyContact? get emergencyContact => _emergencyContact;

  LifeStage get detectedLifeStage => LifeStage.calculateFromDOB(_dateOfBirth);

  OnboardingProvider(this._firestoreService);

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 5) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setPersonalInfo({
    required String name,
    required DateTime dob,
    required String gender,
  }) {
    _displayName = name;
    _dateOfBirth = dob;
    _gender = gender;
    notifyListeners();
  }

  void toggleCondition(String condition) {
    if (condition == 'None') {
      _selectedConditions = ['None'];
    } else {
      _selectedConditions.remove('None');
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        _selectedConditions.add(condition);
      }
    }
    notifyListeners();
  }

  void addMedication(Medication med) {
    _medications.add(med);
    notifyListeners();
  }

  void removeMedication(int index) {
    if (index >= 0 && index < _medications.length) {
      _medications.removeAt(index);
      notifyListeners();
    }
  }

  void updateLifestyle(LifestyleFactors factors) {
    _lifestyle = factors;
    notifyListeners();
  }

  void setEmergencyContact(EmergencyContact? contact) {
    _emergencyContact = contact;
    notifyListeners();
  }

  Future<UserProfile> completeOnboarding({
    required String uid,
    required String email,
  }) async {
    _isSaving = true;
    notifyListeners();

    final profile = UserProfile(
      uid: uid,
      email: email,
      displayName: _displayName.isNotEmpty ? _displayName : email.split('@').first,
      dateOfBirth: _dateOfBirth,
      gender: _gender,
      healthConditions: _selectedConditions,
      medications: _medications,
      lifestyle: _lifestyle,
      emergencyContact: _emergencyContact,
      insuranceDetails: {
        'provider': 'Standard Health Plan',
        'policyNumber': 'SHP-${uid.hashCode.abs().toString().substring(0, 5)}',
        'verified': true,
      },
      onboardingCompleted: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestoreService.saveUserProfile(profile);

    _isSaving = false;
    notifyListeners();
    return profile;
  }
}

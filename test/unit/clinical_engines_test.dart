import 'package:flutter_test/flutter_test.dart';
import 'package:life_stage_health_app/core/engine/drug_interaction_engine.dart';
import 'package:life_stage_health_app/core/engine/life_stage_adaptive_rules.dart';
import 'package:life_stage_health_app/core/engine/preventive_care_engine.dart';
import 'package:life_stage_health_app/core/models/life_stage.dart';

void main() {
  group('DrugInteractionEngine Clinical Tests', () {
    test('detects critical interaction between PDE5 inhibitors and Nitrates', () {
      final alerts = DrugInteractionEngine.checkInteractions([
        'Sildenafil 50mg',
        'Nitroglycerin sublingual',
      ]);
      expect(alerts.isNotEmpty, isTrue);
      expect(alerts.first.severity, InteractionSeverity.critical);
      expect(alerts.first.description, contains('life-threatening drops'));
    });

    test('detects major interaction between ACE inhibitor and Potassium', () {
      final alerts = DrugInteractionEngine.checkInteractions([
        'Lisinopril 10mg',
        'Potassium Chloride supplement',
      ]);
      expect(alerts.any((a) => a.severity == InteractionSeverity.major), isTrue);
    });

    test('detects moderate interaction between Statin and Macrolide', () {
      final alerts = DrugInteractionEngine.checkInteractions([
        'Atorvastatin 20mg',
        'Clarithromycin 500mg',
      ]);
      expect(alerts.any((a) => a.severity == InteractionSeverity.moderate), isTrue);
    });

    test('flags Polypharmacy when patient has 5 or more active medications', () {
      expect(DrugInteractionEngine.isPolypharmacy(5), isTrue);
      expect(DrugInteractionEngine.isPolypharmacy(7), isTrue);
      expect(DrugInteractionEngine.isPolypharmacy(4), isFalse);
    });
  });

  group('LifeStageAdaptiveRules Engine Tests', () {
    test('verifies correct modules enabled for Teenager (13-17)', () {
      final enabledTeen = LifeStageAdaptiveRules.getModulesForStage(LifeStage.teen);
      final titles = enabledTeen.map((m) => m.title).toList();
      expect(titles, contains('Mental Wellness'));
      expect(titles, contains('Preventive Care'));
      // Senior specific modules should NOT be present
      expect(titles, isNot(contains('Fall Detection & Safety')));
    });

    test('verifies correct modules enabled for Senior (70+)', () {
      final enabledSenior = LifeStageAdaptiveRules.getModulesForStage(LifeStage.senior);
      final titles = enabledSenior.map((m) => m.title).toList();
      expect(titles, contains('Fall Detection & Safety'));
      expect(titles, contains('Cognitive Brain Training'));
      expect(titles, contains('Caregiver Portal'));
    });

    test('provides clinical priority headlines tailored per life stage', () {
      final teenHeadline = LifeStageAdaptiveRules.getLifeStageFocusHeadline(LifeStage.teen);
      expect(teenHeadline, contains('Growth'));

      final seniorHeadline = LifeStageAdaptiveRules.getLifeStageFocusHeadline(LifeStage.senior);
      expect(seniorHeadline, contains('Cognitive Sharpness'));
    });
  });

  group('PreventiveCareEngine Guideline Tests', () {
    test('schedules colonoscopy starting at age 45 (USPSTF Grade A)', () {
      final youngSchedule = PreventiveCareEngine.generateSchedule(
        age: 35,
        isSmoker: false,
        hasFamilyHeartDisease: false,
        hasFamilyCancer: false,
      );
      expect(youngSchedule.any((s) => s.title.contains('Colorectal')), isFalse);

      final midLifeSchedule = PreventiveCareEngine.generateSchedule(
        age: 50,
        isSmoker: false,
        hasFamilyHeartDisease: false,
        hasFamilyCancer: false,
      );
      expect(midLifeSchedule.any((s) => s.title.contains('Colorectal')), isTrue);
    });

    test('schedules AAA ultrasound screening for older smokers (USPSTF Grade B)', () {
      final smokerSchedule = PreventiveCareEngine.generateSchedule(
        age: 66,
        isSmoker: true,
        hasFamilyHeartDisease: false,
        hasFamilyCancer: false,
      );
      expect(smokerSchedule.any((s) => s.title.contains('Aortic Aneurysm')), isTrue);

      final nonSmokerSchedule = PreventiveCareEngine.generateSchedule(
        age: 66,
        isSmoker: false,
        hasFamilyHeartDisease: false,
        hasFamilyCancer: false,
      );
      expect(nonSmokerSchedule.any((s) => s.title.contains('Aortic Aneurysm')), isFalse);
    });
  });
}

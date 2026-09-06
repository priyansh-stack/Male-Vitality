import 'package:flutter_test/flutter_test.dart';
import 'package:life_stage_health_app/features/sexual_health/domain/models/fertility_lifestyle_audit.dart';
import 'package:life_stage_health_app/features/sexual_health/domain/models/semen_analysis_record.dart';

void main() {
  group('SemenAnalysisRecord WHO 6th Edition Clinical Tests', () {
    test('accurately classifies Normozoospermia when all parameters meet WHO reference limits', () {
      final record = SemenAnalysisRecord(
        id: 'test_1',
        userId: 'user_1',
        testDate: DateTime.now(),
        abstinenceDays: 3,
        volumeMl: 2.0, // WHO ≥ 1.4 mL
        spermConcentrationMillionPerMl: 25.0, // WHO ≥ 16 M/mL
        totalMotilityPercent: 50.0, // WHO ≥ 42%
        progressiveMotilityPercent: 35.0, // WHO ≥ 30%
        normalMorphologyPercent: 5.0, // Kruger ≥ 4%
      );

      expect(record.isVolumeNormal, isTrue);
      expect(record.isConcentrationNormal, isTrue);
      expect(record.isMotilityNormal, isTrue);
      expect(record.isProgressiveMotilityNormal, isTrue);
      expect(record.isMorphologyNormal, isTrue);
      expect(record.isOptimal, isTrue);
      expect(record.totalSpermCountMillion, equals(50.0));
      expect(record.clinicalFindings.first, contains('Normozoospermia'));
    });

    test('flags Oligozoospermia and Asthenozoospermia when below thresholds', () {
      final subRecord = SemenAnalysisRecord(
        id: 'test_2',
        userId: 'user_2',
        testDate: DateTime.now(),
        abstinenceDays: 2,
        volumeMl: 1.0, // Below 1.4 -> Hypospermia
        spermConcentrationMillionPerMl: 10.0, // Below 16 -> Oligozoospermia
        totalMotilityPercent: 30.0, // Below 42 -> Asthenozoospermia
        progressiveMotilityPercent: 20.0, // Below 30
        normalMorphologyPercent: 2.0, // Below 4 -> Teratozoospermia
      );

      expect(subRecord.isOptimal, isFalse);
      expect(subRecord.clinicalFindings.any((f) => f.contains('Hypospermia')), isTrue);
      expect(subRecord.clinicalFindings.any((f) => f.contains('Oligozoospermia')), isTrue);
      expect(subRecord.clinicalFindings.any((f) => f.contains('Asthenozoospermia')), isTrue);
      expect(subRecord.clinicalFindings.any((f) => f.contains('Teratozoospermia')), isTrue);
    });
  });

  group('FertilityLifestyleAudit Clinical Referral Tests', () {
    test('calculates 100/100 optimization score when all protective factors are present', () {
      final optimalAudit = FertilityLifestyleAudit(
        userId: 'user_1',
        updatedAt: DateTime.now(),
        avoidsHeatExposure: true,
        looseUnderwear: true,
        takesAntioxidants: true,
        nonSmokerAndVaper: true,
        moderateOrZeroAlcohol: true,
      );

      expect(optimalAudit.optimizationScore, equals(100));
      expect(optimalAudit.shouldConsultSpecialist, isFalse);
    });

    test('recommends specialist referral when trying for 12+ months (partner <35)', () {
      final audit = FertilityLifestyleAudit(
        userId: 'user_1',
        updatedAt: DateTime.now(),
        partnerAge: 29,
        monthsTryingToConceive: 13,
      );

      expect(audit.shouldConsultSpecialist, isTrue);
      expect(audit.specialistGuidelineReason, contains('12+ months'));
    });

    test('recommends accelerated specialist referral at 6 months when partner is >=35', () {
      final audit = FertilityLifestyleAudit(
        userId: 'user_1',
        updatedAt: DateTime.now(),
        partnerAge: 36,
        monthsTryingToConceive: 7,
      );

      expect(audit.shouldConsultSpecialist, isTrue);
      expect(audit.specialistGuidelineReason, contains('Partner age is ≥35'));
    });

    test('recommends immediate specialist consultation if varicocele history exists', () {
      final audit = FertilityLifestyleAudit(
        userId: 'user_1',
        updatedAt: DateTime.now(),
        hasVaricoceleHistory: true,
        monthsTryingToConceive: 1,
      );

      expect(audit.shouldConsultSpecialist, isTrue);
      expect(audit.specialistGuidelineReason, contains('varicocele'));
    });
  });
}

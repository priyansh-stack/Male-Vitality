import 'package:flutter_test/flutter_test.dart';
import 'package:life_stage_health_app/core/models/life_stage.dart';

void main() {
  group('LifeStage DOB Calculation Tests', () {
    final now = DateTime.now();

    test('calculates Teen for ages 13 to 17', () {
      final dob15 = DateTime(now.year - 15, now.month, now.day);
      expect(LifeStage.calculateFromDOB(dob15), LifeStage.teen);
    });

    test('calculates Young Adult for ages 18 to 25', () {
      final dob22 = DateTime(now.year - 22, now.month, now.day);
      expect(LifeStage.calculateFromDOB(dob22), LifeStage.youngAdult);
    });

    test('calculates Adult for ages 26 to 39', () {
      final dob32 = DateTime(now.year - 32, now.month, now.day);
      expect(LifeStage.calculateFromDOB(dob32), LifeStage.adult);
    });

    test('calculates Mid-Life for ages 40 to 54', () {
      final dob48 = DateTime(now.year - 48, now.month, now.day);
      expect(LifeStage.calculateFromDOB(dob48), LifeStage.midLife);
    });

    test('calculates Older Adult for ages 55 to 69', () {
      final dob62 = DateTime(now.year - 62, now.month, now.day);
      expect(LifeStage.calculateFromDOB(dob62), LifeStage.olderAdult);
    });

    test('calculates Senior for ages 70+', () {
      final dob75 = DateTime(now.year - 75, now.month, now.day);
      expect(LifeStage.calculateFromDOB(dob75), LifeStage.senior);
    });
  });
}

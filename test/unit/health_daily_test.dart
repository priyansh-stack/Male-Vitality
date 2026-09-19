import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_stage_health_app/core/models/health_daily.dart';
import 'package:life_stage_health_app/core/services/firestore_service.dart';

void main() {
  group('HealthDaily Model & Firestore Contract Tests', () {
    test('deserializes a complete fit_bit payload with all fields', () {
      final now = DateTime.now();
      final map = <String, dynamic>{
        'steps': 8540,
        'restingHeartRate': 65,
        'sleepMinutes': 465,
        'sleepScore': 88,
        'avgSpo2': 98.5,
        'avgHrv': 42.0,
        'calories': 2350,
        'activeMinutes': 45,
        'distanceMeters': 6420.5,
        'source': 'fitbit_google_health',
        'updatedAt': Timestamp.fromDate(now),
        'syncedAt': Timestamp.fromDate(now),
      };

      final daily = HealthDaily.fromMap('2026-09-17', map);

      expect(daily.date, '2026-09-17');
      expect(daily.steps, 8540);
      expect(daily.restingHeartRate, 65);
      expect(daily.sleepMinutes, 465);
      expect(daily.sleepScore, 88);
      expect(daily.avgSpo2, 98.5);
      expect(daily.avgHrv, 42.0);
      expect(daily.calories, 2350);
      expect(daily.activeMinutes, 45);
      expect(daily.distanceMeters, 6420.5);
      expect(daily.distanceKm, closeTo(6.42, 0.01));
      expect(daily.sleepFormatted, '7h 45m');
      expect(daily.source, 'fitbit_google_health');
      expect(
        daily.updatedAt?.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
      expect(daily.isEmpty, isFalse);
    });

    test('handles missing optional fields safely with nulls', () {
      final map = <String, dynamic>{};
      final daily = HealthDaily.fromMap('2026-09-17', map);

      expect(daily.date, '2026-09-17');
      expect(daily.steps, isNull);
      expect(daily.restingHeartRate, isNull);
      expect(daily.sleepMinutes, isNull);
      expect(daily.sleepScore, isNull);
      expect(daily.avgSpo2, isNull);
      expect(daily.avgHrv, isNull);
      expect(daily.calories, isNull);
      expect(daily.activeMinutes, isNull);
      expect(daily.distanceMeters, isNull);
      expect(daily.distanceKm, 0.0);
      expect(daily.sleepFormatted, isNull);
      expect(daily.updatedAt, isNull);
      expect(daily.isEmpty, isTrue);
    });

    test(
      'supports alternate field name fallbacks (hrvRmssd & spo2Percentage)',
      () {
        final map = <String, dynamic>{'spo2Percentage': 97.2, 'hrvRmssd': 55.4};

        final daily = HealthDaily.fromMap('2026-09-17', map);

        expect(daily.avgSpo2, 97.2);
        expect(daily.avgHrv, 55.4);
      },
    );

    test('resiliently parses string and double numbers into correct types', () {
      final map = <String, dynamic>{
        'steps': '9200',
        'restingHeartRate': 68.0,
        'sleepMinutes': '420',
        'calories': 2100.8,
        'avgSpo2': '99',
        'avgHrv': 50,
      };

      final daily = HealthDaily.fromMap('2026-09-17', map);

      expect(daily.steps, 9200);
      expect(daily.restingHeartRate, 68);
      expect(daily.sleepMinutes, 420);
      expect(daily.calories, 2100);
      expect(daily.avgSpo2, 99.0);
      expect(daily.avgHrv, 50.0);
    });

    test('parses ISO8601 string dates for timestamps', () {
      final isoString = '2026-09-17T10:30:00.000Z';
      final map = <String, dynamic>{'updatedAt': isoString};

      final daily = HealthDaily.fromMap('2026-09-17', map);

      expect(daily.updatedAt, isNotNull);
      expect(daily.updatedAt?.toUtc().hour, 10);
      expect(daily.updatedAt?.toUtc().minute, 30);
    });

    test('verifies correct user-scoped Firestore path construction', () {
      const uid = 'user_abc_123';
      const date = '2026-09-17';

      final path = FirestoreService.healthDailyDocPath(uid, date);
      expect(path, 'users/user_abc_123/healthDaily/2026-09-17');
    });

    test('equality and props support value-based comparisons', () {
      final daily1 = const HealthDaily(
        date: '2026-09-17',
        steps: 8000,
        restingHeartRate: 64,
      );

      final daily2 = const HealthDaily(
        date: '2026-09-17',
        steps: 8000,
        restingHeartRate: 64,
      );

      final daily3 = const HealthDaily(
        date: '2026-09-17',
        steps: 9000,
        restingHeartRate: 70,
      );

      expect(daily1, equals(daily2));
      expect(daily1, isNot(equals(daily3)));
    });
  });
}

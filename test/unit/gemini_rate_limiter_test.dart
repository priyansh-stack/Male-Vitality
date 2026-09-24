import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_stage_health_app/features/ai_assistant/services/gemini_rate_limiter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeminiRateLimiter Tests', () {
    late GeminiRateLimiter rateLimiter;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      rateLimiter = GeminiRateLimiter();
    });

    test('allows up to 10 requests in 2 hours and decrements quota', () async {
      for (int i = 0; i < 10; i++) {
        final remaining = await rateLimiter.getRemainingQuota();
        expect(remaining, 10 - i);
        await rateLimiter.recordRequest();
      }

      final quotaAfter10 = await rateLimiter.getRemainingQuota();
      expect(quotaAfter10, 0);
    });

    test('throws RateLimitException when exceeding 10 requests', () async {
      for (int i = 0; i < 10; i++) {
        await rateLimiter.recordRequest();
      }

      expect(
        () async => await rateLimiter.recordRequest(),
        throwsA(isA<RateLimitException>().having(
          (e) => e.remainingMinutes,
          'remainingMinutes',
          greaterThan(0),
        )),
      );
    });
  });
}

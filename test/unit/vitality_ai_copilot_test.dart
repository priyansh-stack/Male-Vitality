import 'package:flutter_test/flutter_test.dart';
import 'package:life_stage_health_app/core/models/health_daily.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/health_score.dart';
import 'package:life_stage_health_app/features/ai_assistant/cubit/vitality_copilot_cubit.dart';
import 'package:life_stage_health_app/features/ai_assistant/cubit/vitality_copilot_state.dart';
import 'package:life_stage_health_app/features/ai_assistant/services/vitality_gemini_service.dart';

class MockVitalityGeminiService extends VitalityGeminiService {
  final bool _hasKey = true;
  String replyText = 'Vitality Copilot Mock Response';

  @override
  Future<bool> hasApiKey() async => _hasKey;

  @override
  Future<bool> testApiKey(String apiKey) async => apiKey.startsWith('AIzaSy');

  @override
  Future<String> sendMessage({
    required String prompt,
    required List<ChatMessage> history,
    required String systemPrompt,
    bool isPro = false,
  }) async {
    if (!_hasKey) throw Exception('API Key missing');
    return replyText;
  }
}

void main() {
  group('VitalityCopilotCubit Tests', () {
    late MockVitalityGeminiService mockService;
    late VitalityCopilotCubit cubit;

    final healthScore = HealthScore(
      score: 84,
      calculatedAt: DateTime.now(),
      categoryScores: const {
        HealthCategory.cardioVascular: 85,
        HealthCategory.activity: 80,
        HealthCategory.sleep: 85,
      },
      recommendations: const ['Maintain current endurance protocol'],
    );

    const todayDaily = HealthDaily(
      date: '2026-09-24',
      steps: 6139,
      restingHeartRate: 69,
      sleepMinutes: 456,
      sleepScore: 86,
    );

    setUp(() {
      mockService = MockVitalityGeminiService();
      cubit = VitalityCopilotCubit(
        geminiService: mockService,
        healthScore: healthScore,
        todayHealthDaily: todayDaily,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state formats greeting with live telemetry ground truth', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.hasApiKey, true);
      expect(cubit.state.messages.isNotEmpty, true);
      expect(cubit.state.messages.first.text.contains('84 / 100'), true);
      expect(cubit.state.messages.first.text.contains('6139 steps'), true);
      expect(cubit.state.messages.first.text.contains('69 bpm resting HR'), true);
    });

    test('toggleModel switches between Flash and Pro mode', () {
      expect(cubit.state.isProModel, false);
      cubit.toggleModel();
      expect(cubit.state.isProModel, true);
      cubit.toggleModel();
      expect(cubit.state.isProModel, false);
    });

    test('sendUserPrompt handles non-emergency prompt with AI reply', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.sendUserPrompt('What is my recovery score?');

      expect(cubit.state.status, VitalityCopilotStatus.success);
      expect(cubit.state.messages.length, 3); // Greeting + User + Bot
      expect(cubit.state.messages.last.text, 'Vitality Copilot Mock Response');
      expect(cubit.state.hasEmergencyAlert, false);
    });

    test('sendUserPrompt detects clinical red flags and triggers emergency alert', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.sendUserPrompt('I am feeling intense chest pain and shortness of breath');

      expect(cubit.state.hasEmergencyAlert, true);
      expect(cubit.state.activeEmergencyMessage != null, true);
      expect(cubit.state.activeEmergencyMessage!.contains('911'), true);
    });
  });
}

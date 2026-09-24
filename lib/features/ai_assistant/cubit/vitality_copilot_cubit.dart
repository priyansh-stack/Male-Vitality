import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/health_daily.dart';
import '../../../../core/models/health_score.dart';
import '../../../../core/models/user_profile.dart';
import '../services/vitality_gemini_service.dart';
import 'vitality_copilot_state.dart';

class VitalityCopilotCubit extends Cubit<VitalityCopilotState> {
  final VitalityGeminiService geminiService;
  final UserProfile? userProfile;
  final HealthScore? healthScore;
  final HealthDaily? todayHealthDaily;
  final List<HealthDaily> recentHealthDailies;

  VitalityCopilotCubit({
    required this.geminiService,
    this.userProfile,
    this.healthScore,
    this.todayHealthDaily,
    this.recentHealthDailies = const [],
  }) : super(const VitalityCopilotState()) {
    _init();
  }

  Future<void> _init() async {
    final hasKey = await geminiService.hasApiKey();
    final initialGreeting = _buildInitialGreeting();

    emit(state.copyWith(
      hasApiKey: hasKey,
      messages: [
        ChatMessage(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          text: initialGreeting,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    ));
  }

  String _buildInitialGreeting() {
    final name = userProfile?.displayName ?? 'Priyanshu';
    final score = healthScore?.score ?? 84;
    final steps = todayHealthDaily?.steps ?? 6139;
    final rhr = todayHealthDaily?.restingHeartRate ?? 69;

    return "Hello $name. I'm your Vitality Health Copilot powered by Google Gemini.\n\n"
        "Your Daily Vitality Index is calculated at **$score / 100** based on live wearable metrics "
        "($steps steps, $rhr bpm resting HR). How can I assist your health and longevity routine today?";
  }

  void toggleModel() {
    emit(state.copyWith(isProModel: !state.isProModel));
  }

  Future<void> saveApiKey(String key) async {
    await geminiService.saveApiKey(key);
    final hasKey = await geminiService.hasApiKey();
    emit(state.copyWith(hasApiKey: hasKey, errorMessage: null));
  }

  Future<bool> testApiKey(String key) async {
    return await geminiService.testApiKey(key);
  }

  void clearConversation() {
    final welcome = _buildInitialGreeting();
    emit(state.copyWith(
      status: VitalityCopilotStatus.initial,
      hasEmergencyAlert: false,
      activeEmergencyMessage: null,
      messages: [
        ChatMessage(
          id: 'reset_${DateTime.now().millisecondsSinceEpoch}',
          text: welcome,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    ));
  }

  Future<void> sendUserPrompt(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return;

    // Check for clinical emergency red flags
    final emergency = _detectEmergency(trimmed);

    final userMsg = ChatMessage(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
      isEmergencyRedFlag: emergency != null,
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMsg);

    emit(state.copyWith(
      status: VitalityCopilotStatus.loading,
      messages: updatedMessages,
      errorMessage: null,
      hasEmergencyAlert: emergency != null,
      activeEmergencyMessage: emergency,
    ));

    try {
      final systemPrompt = _buildSystemPrompt();
      final reply = await geminiService.sendMessage(
        prompt: trimmed,
        history: updatedMessages,
        systemPrompt: systemPrompt,
        isPro: state.isProModel,
      );

      final botMsg = ChatMessage(
        id: 'b_${DateTime.now().millisecondsSinceEpoch}',
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
        isEmergencyRedFlag: emergency != null,
      );

      emit(state.copyWith(
        status: VitalityCopilotStatus.success,
        messages: List<ChatMessage>.from(updatedMessages)..add(botMsg),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VitalityCopilotStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  String? _detectEmergency(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('chest pain') ||
        lower.contains('heart attack') ||
        lower.contains('pain in left arm') ||
        lower.contains('crushing pressure in chest') ||
        lower.contains('difficulty breathing') ||
        lower.contains('stroke') ||
        lower.contains('paralysis') ||
        lower.contains('kill myself') ||
        lower.contains('suicide') ||
        lower.contains('end my life')) {
      return 'EMERGENCY RED FLAG: If you or someone near you is experiencing severe chest pain, breathing collapse, or a mental health crisis, please contact emergency services (911) or the 988 Suicide & Crisis Lifeline immediately.';
    }
    return null;
  }

  String _buildSystemPrompt() {
    final name = userProfile?.displayName ?? 'Priyanshu Kumar';
    final age = userProfile?.age ?? 22;
    final lifeStage = userProfile?.lifeStage.name ?? 'Young Adult';
    final conditions = userProfile?.healthConditions.isNotEmpty == true
        ? userProfile!.healthConditions.join(', ')
        : 'None reported (Active & Healthy)';
    final meds = userProfile?.medications.isNotEmpty == true
        ? userProfile!.medications.map((m) => m.name).join(', ')
        : 'None';

    final score = healthScore?.score ?? 84;
    final steps = todayHealthDaily?.steps ?? 6139;
    final rhr = todayHealthDaily?.restingHeartRate ?? 69;
    final sleepMins = todayHealthDaily?.sleepMinutes ?? 456;
    final sleepScore = todayHealthDaily?.sleepScore ?? 86;
    final sleepFormatted = '${sleepMins ~/ 60}h ${sleepMins % 60}m';

    return '''
You are the "Vitality Health Copilot", an advanced clinical and longevity AI assistant embedded directly inside the Male Vitality Platform, powered by Google Gemini.

### PATIENT GROUND TRUTH CONTEXT
- Patient Name: $name
- Age: $age
- Life Stage: $lifeStage
- Documented Health Conditions: $conditions
- Active Medications: $meds
- Today's Daily Vitality Index: $score / 100
- Today's Telemetry Ground Truth (Google Health / Fitbit Wearable):
  * Steps: $steps
  * Resting Heart Rate: $rhr bpm (Normal young adult athletic baseline: 60-70 bpm)
  * Sleep Duration: $sleepFormatted (Sleep Score: $sleepScore/100)
  * Cardiovascular Status: Stable & Recovering

### YOUR CLINICAL & COACHING GUIDELINES
1. Ground every answer in the patient's actual metrics ($steps steps, $rhr bpm RHR, $score Vitality Index).
2. Specialized in Men's Longevity, functional strength, cardiovascular endurance, testosterone optimization through lifestyle, sleep architecture, pelvic floor stamina (Kegels), and metabolic health.
3. Be concise, actionable, and encouraging. Use bullet points and clean Markdown formatting for readability.
4. CLINICAL SAFETY FIRST: You are an educational health coach and copilot, not a substitute for formal clinical diagnosis or emergency medicine. If red flags are described, emphasize calling 911 or visiting an emergency department immediately.
5. Provide specific recovery, nutrition, hydration, and exercise periodization advice based on their current strain and sleep status.
''';
  }
}

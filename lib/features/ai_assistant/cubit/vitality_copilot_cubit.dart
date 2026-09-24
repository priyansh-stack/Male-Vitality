import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/health_daily.dart';
import '../../../../core/models/health_score.dart';
import '../../../../core/models/user_profile.dart';
import '../services/vitality_gemini_service.dart';
import '../services/vitality_chat_library_repository.dart';
import 'vitality_copilot_state.dart';

class VitalityCopilotCubit extends Cubit<VitalityCopilotState> {
  final VitalityGeminiService geminiService;
  final VitalityChatLibraryRepository libraryRepository;
  final UserProfile? userProfile;
  final HealthScore? healthScore;
  final HealthDaily? todayHealthDaily;
  final List<HealthDaily> recentHealthDailies;

  VitalityCopilotCubit({
    required this.geminiService,
    VitalityChatLibraryRepository? libraryRepo,
    this.userProfile,
    this.healthScore,
    this.todayHealthDaily,
    this.recentHealthDailies = const [],
  })  : libraryRepository = libraryRepo ?? VitalityChatLibraryRepository(),
        super(const VitalityCopilotState()) {
    _init();
  }

  Future<void> _init() async {
    final hasKey = await geminiService.hasApiKey();
    final hasCustomKey = await geminiService.hasCustomApiKey();
    final dynamicName = _resolveDynamicUserName();
    final newSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final initialGreeting = _buildInitialGreeting(dynamicName);

    List<VitalityChatSession> userSessions = [];
    try {
      userSessions = await libraryRepository.fetchSessions();
    } catch (_) {}

    emit(state.copyWith(
      hasApiKey: hasKey,
      hasCustomApiKey: hasCustomKey,
      currentUserName: dynamicName,
      currentSessionId: newSessionId,
      sessions: userSessions,
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

  String _resolveDynamicUserName() {
    if (userProfile?.displayName != null && userProfile!.displayName.trim().isNotEmpty) {
      return userProfile!.displayName.trim();
    }
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser?.displayName != null && authUser!.displayName!.trim().isNotEmpty) {
        return authUser.displayName!.trim();
      }
      if (authUser?.email != null && authUser!.email!.contains('@')) {
        final handle = authUser.email!.split('@').first.trim();
        if (handle.isNotEmpty) return handle;
      }
    } catch (_) {}
    return 'Member';
  }

  String _buildInitialGreeting(String name) {
    final scoreStr = healthScore?.score != null ? '${healthScore!.score}' : '79';
    final stepsStr = todayHealthDaily?.steps != null ? '${todayHealthDaily!.steps}' : 'active';
    final rhrStr = todayHealthDaily?.restingHeartRate != null ? '${todayHealthDaily!.restingHeartRate} bpm' : 'monitored';

    return "Hello $name. I'm your Vitality Health Copilot powered by Google Gemini.\n\n"
        "Your Daily Vitality Index is calculated at **$scoreStr / 100** based on live wearable metrics "
        "($stepsStr steps, $rhrStr resting HR). How can I assist your health and longevity routine today?";
  }

  void toggleModel() {
    emit(state.copyWith(isProModel: !state.isProModel));
  }

  Future<void> saveApiKey(String key) async {
    await geminiService.saveApiKey(key);
    final hasKey = await geminiService.hasApiKey();
    final hasCustomKey = await geminiService.hasCustomApiKey();
    emit(state.copyWith(hasApiKey: hasKey, hasCustomApiKey: hasCustomKey, errorMessage: null));
  }

  Future<bool> testApiKey(String key) async {
    return await geminiService.testApiKey(key);
  }

  /// Starts a fresh, new chat session and saves previous state
  Future<void> startNewChat() async {
    final dynamicName = _resolveDynamicUserName();
    final newSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final welcome = _buildInitialGreeting(dynamicName);

    emit(state.copyWith(
      status: VitalityCopilotStatus.initial,
      currentSessionId: newSessionId,
      hasEmergencyAlert: false,
      activeEmergencyMessage: null,
      messages: [
        ChatMessage(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          text: welcome,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    ));
  }

  void clearConversation() {
    startNewChat();
  }

  /// Loads an existing conversation session from the user's private library
  void loadSession(VitalityChatSession session) {
    emit(state.copyWith(
      status: VitalityCopilotStatus.success,
      currentSessionId: session.id,
      messages: session.messages,
      hasEmergencyAlert: false,
      activeEmergencyMessage: null,
    ));
  }

  /// Deletes a session from the user's private library in Firestore
  Future<void> deleteSession(String sessionId) async {
    await libraryRepository.deleteSession(sessionId);
    final updated = List<VitalityChatSession>.from(state.sessions)
      ..removeWhere((s) => s.id == sessionId);

    // If the active session was deleted, start fresh
    if (state.currentSessionId == sessionId) {
      await startNewChat();
      emit(state.copyWith(sessions: updated));
    } else {
      emit(state.copyWith(sessions: updated));
    }
  }

  Future<void> reloadLibrary() async {
    emit(state.copyWith(isLoadingLibrary: true));
    try {
      final sessions = await libraryRepository.fetchSessions();
      emit(state.copyWith(sessions: sessions, isLoadingLibrary: false));
    } catch (_) {
      emit(state.copyWith(isLoadingLibrary: false));
    }
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

      final finalMessages = List<ChatMessage>.from(updatedMessages)..add(botMsg);

      emit(state.copyWith(
        status: VitalityCopilotStatus.success,
        messages: finalMessages,
      ));

      // Persist to user's private Firestore chat library
      await _persistSession(trimmed, reply, finalMessages);
    } catch (e) {
      emit(state.copyWith(
        status: VitalityCopilotStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _persistSession(String userPrompt, String botReply, List<ChatMessage> messages) async {
    try {
      final sessionId = state.currentSessionId ?? 'session_${DateTime.now().millisecondsSinceEpoch}';
      final title = userPrompt.length > 32 ? '${userPrompt.substring(0, 32)}...' : userPrompt;

      final session = VitalityChatSession(
        id: sessionId,
        title: title,
        lastMessagePreview: botReply.length > 60 ? '${botReply.substring(0, 60)}...' : botReply,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: messages,
      );

      await libraryRepository.saveSession(session);
      final updatedSessions = await libraryRepository.fetchSessions();
      emit(state.copyWith(sessions: updatedSessions, currentSessionId: sessionId));
    } catch (e) {
      debugPrint('[VitalityCopilotCubit] Error saving session to library: $e');
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
    final dynamicName = _resolveDynamicUserName();
    final ageStr = userProfile?.age != null ? '${userProfile!.age}' : 'Adult';
    final lifeStageStr = userProfile?.lifeStage.name ?? 'Adult';
    final conditions = userProfile?.healthConditions.isNotEmpty == true
        ? userProfile!.healthConditions.join(', ')
        : 'None reported (Active & Healthy)';
    final meds = userProfile?.medications.isNotEmpty == true
        ? userProfile!.medications.map((m) => m.name).join(', ')
        : 'None';

    final scoreStr = healthScore?.score != null ? '${healthScore!.score}' : 'Pending';
    final stepsStr = todayHealthDaily?.steps != null ? '${todayHealthDaily!.steps}' : 'Pending sync';
    final rhrStr = todayHealthDaily?.restingHeartRate != null ? '${todayHealthDaily!.restingHeartRate} bpm' : 'Monitored';
    final sleepMins = todayHealthDaily?.sleepMinutes ?? 0;
    final sleepScore = todayHealthDaily?.sleepScore ?? 0;
    final sleepFormatted = sleepMins > 0 ? '${sleepMins ~/ 60}h ${sleepMins % 60}m' : 'Recorded';

    return '''
You are the "Vitality Health Copilot", an advanced clinical and longevity AI assistant embedded directly inside the Male Vitality Platform, powered by Google Gemini.

### PATIENT GROUND TRUTH CONTEXT
- Patient Name: $dynamicName
- Age: $ageStr
- Life Stage: $lifeStageStr
- Documented Health Conditions: $conditions
- Active Medications: $meds
- Today's Daily Vitality Index: $scoreStr / 100
- Today's Telemetry Ground Truth (Google Health / Wearable):
  * Steps: $stepsStr
  * Resting Heart Rate: $rhrStr
  * Sleep Duration: $sleepFormatted (Sleep Score: $sleepScore/100)
  * Cardiovascular Status: Stable & Monitored

### YOUR CLINICAL & COACHING GUIDELINES
1. Ground every answer in the patient's actual metrics ($stepsStr steps, $rhrStr RHR, $scoreStr Vitality Index).
2. Specialized in Men's Longevity, functional strength, cardiovascular endurance, testosterone optimization through lifestyle, sleep architecture, pelvic floor stamina (Kegels), and metabolic health.
3. Be concise, actionable, and encouraging. Use bullet points and clean Markdown formatting for readability.
4. CLINICAL SAFETY FIRST: You are an educational health coach and copilot, not a substitute for formal clinical diagnosis or emergency medicine. If red flags are described, emphasize calling 911 or visiting an emergency department immediately.
5. Provide specific recovery, nutrition, hydration, and exercise periodization advice based on their current strain and sleep status.
''';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/bloc/Health_Dashboard/dashboard_bloc.dart';
import '../../../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubit/vitality_copilot_cubit.dart';
import '../../cubit/vitality_copilot_state.dart';
import '../../services/vitality_gemini_service.dart';
import '../widgets/vitality_key_dialog.dart';
import '../widgets/vitality_chat_library_sheet.dart';

class VitalityChatScreen extends StatefulWidget {
  const VitalityChatScreen({super.key});

  @override
  State<VitalityChatScreen> createState() => _VitalityChatScreenState();
}

class _VitalityChatScreenState extends State<VitalityChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickPrompts = [
    'Analyze my Vitality Score today',
    'How is my resting heart rate (69 bpm)?',
    'Recommend a workout based on my recovery',
    'Pelvic floor stamina & Kegel guide',
    'Tips to optimize REM & Deep Sleep',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendPrompt(String text) {
    if (text.trim().isEmpty) return;
    context.read<VitalityCopilotCubit>().sendUserPrompt(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _openKeyDialog() {
    showDialog(
      context: context,
      builder: (_) => VitalityKeyDialog(cubit: context.read<VitalityCopilotCubit>()),
    );
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract dashboard data to provide real telemetry pills
    final dashboardState = context.watch<DashboardBloc>().state;
    final onboardingState = context.watch<OnboardingBloc>().state;

    int vitalityScore = 84;
    int steps = 6139;
    int rhr = 69;
    String sleepText = '7h 36m';

    if (dashboardState is DashboardLoaded) {
      vitalityScore = dashboardState.healthScore.score;
      if (dashboardState.todayHealthDaily != null) {
        steps = dashboardState.todayHealthDaily!.steps ?? steps;
        rhr = dashboardState.todayHealthDaily!.restingHeartRate ?? rhr;
        if (dashboardState.todayHealthDaily!.sleepFormatted != null) {
          sleepText = dashboardState.todayHealthDaily!.sleepFormatted!;
        }
      }
    }

    final userProfile = onboardingState.completedProfile;

    return Scaffold(
      backgroundColor: AppTheme.darkCanvas,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI Copilot',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Gemini Longevity',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          BlocBuilder<VitalityCopilotCubit, VitalityCopilotState>(
            builder: (context, state) {
              return TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => context.read<VitalityCopilotCubit>().toggleModel(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: state.isProModel
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.25)
                        : AppTheme.cyberCyan.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.isProModel ? const Color(0xFFA78BFA) : AppTheme.cyberCyan,
                    ),
                  ),
                  child: Text(
                    state.isProModel ? 'PRO' : 'FLASH',
                    style: TextStyle(
                      color: state.isProModel ? const Color(0xFFA78BFA) : AppTheme.cyberCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            },
          ),
          BlocBuilder<VitalityCopilotCubit, VitalityCopilotState>(
            builder: (context, state) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.forum_outlined, color: Colors.white70, size: 20),
                    tooltip: 'Consultation Library',
                    onPressed: () {
                      VitalityChatLibrarySheet.show(
                        context,
                        context.read<VitalityCopilotCubit>(),
                        state,
                      );
                    },
                  ),
                  if (state.sessions.isNotEmpty)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00FFCC),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '${state.sessions.length > 9 ? '9+' : state.sessions.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.add_comment_outlined, color: Colors.white70, size: 19),
            tooltip: 'New Chat',
            onPressed: () => context.read<VitalityCopilotCubit>().startNewChat(),
          ),
          IconButton(
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.vpn_key_outlined, color: Colors.white70, size: 19),
            tooltip: 'Gemini API Key',
            onPressed: _openKeyDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<VitalityCopilotCubit, VitalityCopilotState>(
        listener: (context, state) {
          if (state.status == VitalityCopilotStatus.success || state.status == VitalityCopilotStatus.loading) {
            _scrollToBottom();
          }
          if (state.errorMessage != null) {
            final isKeyErr = state.errorMessage!.toLowerCase().contains('api key');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppTheme.neonRed,
                duration: const Duration(seconds: 4),
                action: isKeyErr
                    ? SnackBarAction(
                        label: 'Set Key',
                        textColor: Colors.white,
                        onPressed: _openKeyDialog,
                      )
                    : null,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Telemetry Context HUD Pill Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildContextPill(
                        icon: Icons.shield_outlined,
                        label: 'Vitality',
                        value: '$vitalityScore/100',
                        color: AppTheme.cyberCyan,
                      ),
                      const SizedBox(width: 8),
                      _buildContextPill(
                        icon: Icons.directions_walk_rounded,
                        label: 'Steps',
                        value: '$steps',
                        color: AppTheme.bioEmerald,
                      ),
                      const SizedBox(width: 8),
                      _buildContextPill(
                        icon: Icons.favorite_rounded,
                        label: 'RHR',
                        value: '$rhr bpm',
                        color: AppTheme.cyberBlue,
                      ),
                      const SizedBox(width: 8),
                      _buildContextPill(
                        icon: Icons.bedtime_outlined,
                        label: 'Sleep',
                        value: sleepText,
                        color: AppTheme.neonPurple,
                      ),
                    ],
                  ),
                ),
              ),

              // Emergency Red Flag Triage Banner
              if (state.hasEmergencyAlert && state.activeEmergencyMessage != null)
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.neonRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.neonRed.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: AppTheme.neonRed, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'CLINICAL SAFETY ALERT',
                            style: TextStyle(
                              color: AppTheme.neonRed,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.activeEmergencyMessage!,
                        style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _makeCall('911'),
                            icon: const Icon(Icons.call, size: 14),
                            label: const Text('Call 911', style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _makeCall('988'),
                            icon: const Icon(Icons.health_and_safety, size: 14),
                            label: const Text('Lifeline 988', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => context.push('/telehealth'),
                            child: const Text(
                              'Telehealth',
                              style: TextStyle(color: AppTheme.cyberCyan, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Active Engine Indicator Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withValues(alpha: 0.8),
                  border: Border(
                    bottom: BorderSide(color: AppTheme.cyberCyan.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: state.hasCustomApiKey ? AppTheme.bioEmerald : AppTheme.cyberCyan,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (state.hasCustomApiKey ? AppTheme.bioEmerald : AppTheme.cyberCyan).withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.hasCustomApiKey
                            ? 'Custom Gemini Key Active'
                            : (state.isProModel
                                ? 'Gemini Pro Active • 10 queries / 2h'
                                : 'Google AI Active • 10 queries / 2h'),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _openKeyDialog,
                      child: Row(
                        children: [
                          Icon(
                            state.hasCustomApiKey ? Icons.vpn_key : Icons.vpn_key_outlined,
                            color: AppTheme.cyberCyan,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            state.hasCustomApiKey ? 'Custom Key' : 'API Key',
                            style: const TextStyle(
                              color: AppTheme.cyberCyan,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages Stream
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: state.messages.length + (state.status == VitalityCopilotStatus.loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length && state.status == VitalityCopilotStatus.loading) {
                      return _buildThinkingBubble();
                    }
                    final msg = state.messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),

              // Quick prompt suggestions
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _quickPrompts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return ActionChip(
                      backgroundColor: AppTheme.darkCard,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      label: Text(
                        _quickPrompts[i],
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      onPressed: () => _sendPrompt(_quickPrompts[i]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Input bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                decoration: const BoxDecoration(
                  color: AppTheme.darkSurface,
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          textInputAction: TextInputAction.send,
                          onSubmitted: _sendPrompt,
                          decoration: InputDecoration(
                            hintText: 'Ask Copilot about vitality, recovery, sleep, stamina...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.cyberCyan, AppTheme.cyberBlue],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                        onPressed: () => _sendPrompt(_textController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContextPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.cyberCyan.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.cyberCyan,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Analyzing patient metrics & clinical guidelines...',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final isAlert = message.isEmergencyRedFlag;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [AppTheme.cyberCyan, Color(0xFFE05333)],
                )
              : null,
          color: isUser ? null : AppTheme.darkCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: Border.all(
            color: isAlert
                ? AppTheme.neonRed
                : isUser
                    ? Colors.transparent
                    : AppTheme.cyberCyan.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            SelectableText(
              message.text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 9.5,
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message copied to clipboard.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final a = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $a';
  }
}

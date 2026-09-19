import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/bloc/mental_wellness/mood_bloc/mood_bloc.dart';
import '../../../core/theme/app_theme.dart';

class MentalWellnessScreen extends StatefulWidget {
  final String userId;

  const MentalWellnessScreen({super.key, required this.userId});

  @override
  State<MentalWellnessScreen> createState() => _MentalWellnessScreenState();
}

class _MentalWellnessScreenState extends State<MentalWellnessScreen> {
  String get _effectiveUserId => widget.userId.isNotEmpty
      ? widget.userId
      : (FirebaseAuth.instance.currentUser?.uid ?? '');

  // Quick Mood Check-in local state
  int _selectedMoodScore = 4; // 1 to 5
  int _energyLevel = 7; // 1 to 10
  final Set<String> _selectedStressors = <String>{};
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmittingMood = false;

  // Box Breathing Exercise local state
  bool _isBreathingActive = false;
  int _breathingPhase = 0; // 0: Inhale, 1: Hold, 2: Exhale, 3: Hold
  int _breathingSecondsLeft = 4;
  Timer? _breathingTimer;
  int _completedBreathingCycles = 0;

  final List<Map<String, dynamic>> _moodOptions = [
    {'score': 5, 'label': 'Optimal', 'icon': Icons.sentiment_very_satisfied_rounded, 'color': AppTheme.neonEmerald},
    {'score': 4, 'label': 'Focused', 'icon': Icons.sentiment_satisfied_rounded, 'color': AppTheme.neonCyan},
    {'score': 3, 'label': 'Balanced', 'icon': Icons.sentiment_neutral_rounded, 'color': AppTheme.neonAmber},
    {'score': 2, 'label': 'Drained', 'icon': Icons.sentiment_dissatisfied_rounded, 'color': Color(0xFFF97316)},
    {'score': 1, 'label': 'Stressed', 'icon': Icons.sentiment_very_dissatisfied_rounded, 'color': AppTheme.neonCrimson},
  ];

  final List<String> _stressorChips = [
    'Work Stress',
    'Poor Sleep',
    'Workout Fatigue',
    'Diet / Fasting',
    'Low Libido',
    'Cognitive Fog',
    'Relationship',
    'Financial',
    'Lack of Time',
  ];

  @override
  void initState() {
    super.initState();
    final uid = _effectiveUserId;
    if (uid.isNotEmpty) {
      context.read<MoodBloc>().add(LoadMoodHistoryEvent(userId: uid, days: 7));
    }
  }

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isBreathingActive = true;
      _breathingPhase = 0;
      _breathingSecondsLeft = 4;
      _completedBreathingCycles = 0;
    });

    _breathingTimer?.cancel();
    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_breathingSecondsLeft > 1) {
          _breathingSecondsLeft--;
        } else {
          _breathingSecondsLeft = 4;
          _breathingPhase = (_breathingPhase + 1) % 4;
          if (_breathingPhase == 0) {
            _completedBreathingCycles++;
          }
        }
      });
    });
  }

  void _stopBreathing() {
    _breathingTimer?.cancel();
    setState(() {
      _isBreathingActive = false;
      _breathingPhase = 0;
      _breathingSecondsLeft = 4;
    });
  }

  String get _breathingPhaseName {
    switch (_breathingPhase) {
      case 0:
        return 'INHALE (4s)';
      case 1:
        return 'HOLD (4s)';
      case 2:
        return 'EXHALE (4s)';
      case 3:
        return 'HOLD (4s)';
      default:
        return '';
    }
  }

  Color get _breathingPhaseColor {
    switch (_breathingPhase) {
      case 0:
        return AppTheme.neonCyan;
      case 1:
        return AppTheme.neonPurple;
      case 2:
        return AppTheme.neonEmerald;
      case 3:
        return AppTheme.neonAmber;
      default:
        return AppTheme.neonCyan;
    }
  }

  Future<void> _submitMood() async {
    final uid = _effectiveUserId;
    if (uid.isEmpty) return;
    setState(() => _isSubmittingMood = true);

    context.read<MoodBloc>().add(
      SubmitMoodEntryEvent(
        userId: uid,
        moodRating: _selectedMoodScore,
        notes: _notesController.text.trim(),
        triggers: _selectedStressors.toList(),
        context: {'energyLevel': _energyLevel},
      ),
    );

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isSubmittingMood = false;
        _notesController.clear();
        _selectedStressors.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Neuro-affective mood check-in synchronized!'),
          backgroundColor: AppTheme.bioEmerald,
        ),
      );
      context.read<MoodBloc>().add(LoadMoodHistoryEvent(userId: widget.userId, days: 7));
    }
  }

  Future<void> _call988() async {
    final uri = Uri.parse('tel:988');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidianBase,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.psychology_rounded, color: AppTheme.neonPurple, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'MENTAL WELLNESS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppTheme.neonCyan),
            tooltip: 'Mood History',
            onPressed: () {
              if (widget.userId.isNotEmpty) {
                context.push('/mood-history?userId=${widget.userId}');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          // 1. Resilience Sentinel Status Banner
          _buildResilienceBanner(),
          const SizedBox(height: 16),

          // 2. Immediate 988 Crisis Sentinel Card
          _buildCrisisSentinelCard(),
          const SizedBox(height: 16),

          // 3. Daily Neuro Check-In Form
          _buildQuickMoodCard(),
          const SizedBox(height: 16),

          // 4. Parasympathetic Vagus Nerve Box Breathing (4-4-4-4)
          _buildBoxBreathingCard(),
          const SizedBox(height: 16),

          // 5. Clinical PHQ-2 & GAD-2 Assessment Launcher
          _buildClinicalAssessmentCard(),
          const SizedBox(height: 16),

          // 6. Male Mental Health & Hormone Link Knowledge
          _buildClinicalInsightsCard(),
          const SizedBox(height: 16),

          // 7. Recent Mood Log Stream
          _buildRecentMoodStream(),
        ],
      ),
    );
  }

  Widget _buildResilienceBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cyberCardDecoration(
        borderColor: AppTheme.neonPurple.withOpacity(0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.neonPurple.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
            ),
            child: const Icon(Icons.shield_outlined, color: AppTheme.neonPurple, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'NEURO-AFFECTIVE SENTINEL',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '// ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.neonPurple,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  'Monitoring autonomic stress markers, parasympathetic recovery, and mood stability.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisSentinelCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonCrimson.withOpacity(0.6), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neonCrimson.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sos_rounded, color: AppTheme.neonCrimson, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '988 Suicide & Crisis Lifeline (24/7)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Free, confidential support for emotional distress & mental crises.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonCrimson,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _call988,
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call 988', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    context.push('/crisis-resources?userId=${widget.userId}');
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('All Hotlines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMoodCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cyberCardDecoration(borderColor: Colors.white12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY MOOD & ENERGY LOG',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppTheme.neonCyan,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'How is your baseline mindset and focus today?',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 14),

          // Mood Icon Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _moodOptions.map((opt) {
              final isSelected = _selectedMoodScore == opt['score'];
              final color = opt['color'] as Color;
              return InkWell(
                onTap: () => setState(() => _selectedMoodScore = opt['score'] as int),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color : Colors.white12,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(opt['icon'] as IconData, color: isSelected ? color : Colors.white54, size: 26),
                      const SizedBox(height: 4),
                      Text(
                        opt['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Energy Level Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ENERGY & DRIVE LEVEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
              Text('$_energyLevel / 10', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.neonCyan)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.neonCyan,
              inactiveTrackColor: Colors.white10,
              thumbColor: AppTheme.neonCyan,
              overlayColor: AppTheme.neonCyan.withOpacity(0.2),
            ),
            child: Slider(
              value: _energyLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (val) => setState(() => _energyLevel = val.round()),
            ),
          ),
          const SizedBox(height: 10),

          // Primary Male Stressors
          const Text('ACTIVE STRESSORS (OPTIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _stressorChips.map((s) {
              final isSelected = _selectedStressors.contains(s);
              return FilterChip(
                backgroundColor: const Color(0xFF0F172A),
                selectedColor: AppTheme.neonPurple.withOpacity(0.25),
                side: BorderSide(color: isSelected ? AppTheme.neonPurple : Colors.white12),
                label: Text(
                  s,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStressors.add(s);
                    } else {
                      _selectedStressors.remove(s);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Journal Notes
          TextField(
            controller: _notesController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Add private context or cognitive reflections...',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white12),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSubmittingMood ? null : _submitMood,
              icon: _isSubmittingMood
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Commit Mood Telemetry', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxBreathingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cyberCardDecoration(
        borderColor: _isBreathingActive ? _breathingPhaseColor : AppTheme.neonCyan.withOpacity(0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air_rounded, color: AppTheme.neonCyan, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PARASYMPATHETIC BOX BREATHING (4-4-4-4)',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12, letterSpacing: 0.8),
                    ),
                    Text(
                      'Lowers cortisol, boosts HRV RMSSD, and activates the vagus nerve.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (_isBreathingActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _breathingPhaseColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'CYCLE $_completedBreathingCycles',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _breathingPhaseColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          if (_isBreathingActive) ...[
            Center(
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _breathingPhaseColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _breathingPhaseColor.withOpacity(0.35),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_breathingSecondsLeft',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _breathingPhaseColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _breathingPhaseName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _breathingPhaseColor, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                    ),
                    onPressed: _stopBreathing,
                    icon: const Icon(Icons.stop, size: 16),
                    label: const Text('End Exercise'),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonCyan,
                  foregroundColor: const Color(0xFF080C14),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _startBreathing,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start 2-Minute Box Breathing', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClinicalAssessmentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cyberCardDecoration(borderColor: Colors.white12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VALIDATED CLINICAL SCREENINGS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.neonCyan, letterSpacing: 0.8),
          ),
          const SizedBox(height: 4),
          const Text(
            'Evidence-based self-evaluations for early detection of mood disorders and anxiety.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildAssessmentButton(
                  title: 'PHQ-2 Screener',
                  subtitle: 'Depression index',
                  icon: Icons.checklist_rounded,
                  onTap: () {
                    _showPhq2Dialog();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAssessmentButton(
                  title: 'Find Therapist',
                  subtitle: 'Male specialized',
                  icon: Icons.person_search_rounded,
                  onTap: () {
                    context.push('/therapist-finder?userId=${widget.userId}');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.neonCyan, size: 22),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cyberCardDecoration(borderColor: Colors.white12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MALE PSYCHOPHYSIOLOGY & HORMONES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.neonPurple, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            title: 'Masked Male Depression',
            description: 'Societal conditioning causes male depression to present as irritability, risk-taking, emotional detachment, and fatigue rather than classic sadness.',
          ),
          const Divider(color: Colors.white12, height: 20),
          _buildInsightRow(
            title: 'Cortisol vs. Testosterone Axis',
            description: 'Elevated chronic cortisol directly inhibits the hypothalamic-pituitary-gonadal (HPG) axis, blunting morning luteinizing hormone and testosterone synthesis.',
          ),
          const Divider(color: Colors.white12, height: 20),
          _buildInsightRow(
            title: 'Sleep REM Restoration',
            description: 'Over 70% of neuro-chemical neurotransmitters (serotonin, dopamine) reset during deep non-REM and REM cycles. Chronic sleep debt induces acute depressive risk.',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35)),
      ],
    );
  }

  Widget _buildRecentMoodStream() {
    return BlocBuilder<MoodBloc, MoodState>(
      builder: (context, state) {
        if (state is MoodHistoryLoadedState && state.entries.isNotEmpty) {
          final entries = state.entries.take(4).toList();
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.cyberCardDecoration(borderColor: Colors.white12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('RECENT MOOD ENTRIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.neonCyan, letterSpacing: 0.8)),
                    TextButton(
                      onPressed: () => context.push('/mood-history?userId=${widget.userId}'),
                      child: const Text('View All', style: TextStyle(color: AppTheme.neonCyan, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            e.moodRating >= 4 ? Icons.sentiment_satisfied : (e.moodRating == 3 ? Icons.sentiment_neutral : Icons.sentiment_dissatisfied),
                            color: e.moodRating >= 4 ? AppTheme.neonEmerald : (e.moodRating == 3 ? AppTheme.neonAmber : AppTheme.neonCrimson),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mood: ${e.moodRating}/5 • Energy: ${e.context['energyLevel'] ?? 5}/10',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                if (e.triggers.isNotEmpty)
                                  Text(
                                    e.triggers.join(', '),
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, h:mm a').format(e.timestamp),
                            style: const TextStyle(color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showPhq2Dialog() {
    int q1 = 0;
    int q2 = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final total = q1 + q2;
            final isFlagged = total >= 3;

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('PHQ-2 Depression Screener', style: TextStyle(color: Colors.white, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Over the past 2 weeks, how often have you been bothered by:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 12),
                  const Text('1. Little interest or pleasure in doing things?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  DropdownButton<int>(
                    value: q1,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Not at all (0)')),
                      DropdownMenuItem(value: 1, child: Text('Several days (1)')),
                      DropdownMenuItem(value: 2, child: Text('More than half the days (2)')),
                      DropdownMenuItem(value: 3, child: Text('Nearly every day (3)')),
                    ],
                    onChanged: (v) => setDialogState(() => q1 = v ?? 0),
                  ),
                  const SizedBox(height: 12),
                  const Text('2. Feeling down, depressed, or hopeless?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  DropdownButton<int>(
                    value: q2,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Not at all (0)')),
                      DropdownMenuItem(value: 1, child: Text('Several days (1)')),
                      DropdownMenuItem(value: 2, child: Text('More than half the days (2)')),
                      DropdownMenuItem(value: 3, child: Text('Nearly every day (3)')),
                    ],
                    onChanged: (v) => setDialogState(() => q2 = v ?? 0),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isFlagged ? AppTheme.neonCrimson.withOpacity(0.2) : AppTheme.neonEmerald.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isFlagged
                          ? 'Score: $total/6 • Clinical Flag: Score ≥ 3 suggests further diagnostic evaluation with a healthcare professional.'
                          : 'Score: $total/6 • Normal Baseline (Screen negative for acute depression)',
                      style: TextStyle(
                        color: isFlagged ? AppTheme.neonCrimson : AppTheme.neonEmerald,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Close', style: TextStyle(color: Colors.white60)),
                ),
                if (isFlagged)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonCrimson),
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      context.push('/therapist-finder?userId=${widget.userId}');
                    },
                    child: const Text('Find Support'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

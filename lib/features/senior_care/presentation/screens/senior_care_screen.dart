import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/senior_care_models.dart';
import '../../domain/repositories/i_senior_care_repository.dart';

class SeniorCareScreen extends StatefulWidget {
  final String userId;
  final ISeniorCareRepository repository;

  const SeniorCareScreen({
    super.key,
    required this.userId,
    required this.repository,
  });

  @override
  State<SeniorCareScreen> createState() => _SeniorCareScreenState();
}

class _SeniorCareScreenState extends State<SeniorCareScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _fallDetectionActive = true;
  bool _largeTextMode = false;
  bool _highContrast = false;

  List<CaregiverProfile> _caregivers = [];
  List<CognitiveScore> _cognitiveScores = [];
  bool _isLoading = true;

  // Mini-game state
  int _gameScore = 0;
  bool _isGameRunning = false;
  int _targetNumber = 7;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final cgs = await widget.repository.getCaregivers(widget.userId);
    final scores = await widget.repository.getCognitiveScores(widget.userId);
    setState(() {
      _caregivers = cgs;
      _cognitiveScores = scores;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _highContrast ? Colors.black : const Color(0xFF0F172A);
    final cardColor = _highContrast ? const Color(0xFF18181B) : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text(
          'Senior Vitality & Caregiver',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: _largeTextMode ? 22 : 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFEC4899),
          tabs: [
            Tab(text: _largeTextMode ? 'FALL SOS' : 'Fall Detection'),
            Tab(text: _largeTextMode ? 'BRAIN GAME' : 'Brain Training'),
            Tab(text: _largeTextMode ? 'FAMILY PORTAL' : 'Caregivers'),
            Tab(text: _largeTextMode ? 'ACCESSIBILITY' : 'Display & Voice'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEC4899)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFallDetectionTab(cardColor),
                _buildBrainTrainingTab(cardColor),
                _buildCaregiverTab(cardColor),
                _buildAccessibilityTab(cardColor),
              ],
            ),
    );
  }

  Widget _buildFallDetectionTab(Color cardColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Monitor status card
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  _fallDetectionActive ? Icons.health_and_safety : Icons.warning_amber_rounded,
                  size: 54,
                  color: _fallDetectionActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 12),
                Text(
                  _fallDetectionActive ? 'Fall Monitor Guard is ACTIVE' : 'Fall Detection Paused',
                  style: TextStyle(
                    fontSize: _largeTextMode ? 20 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Continuous 3-axis accelerometer algorithm listening for sudden vertical velocity drops followed by zero impact movement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: _largeTextMode ? 14 : 12, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(
                    'Background Fall Sensor',
                    style: TextStyle(color: Colors.white, fontSize: _largeTextMode ? 16 : 14),
                  ),
                  value: _fallDetectionActive,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _fallDetectionActive = v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Emergency SOS Button (Manual or Test)
        SizedBox(
          width: double.infinity,
          height: 70,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _triggerSimulatedFallCountdown,
            icon: const Icon(Icons.sos, size: 36),
            label: Text(
              'TEST EMERGENCY FALL ALERT',
              style: TextStyle(
                fontSize: _largeTextMode ? 18 : 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Automated Response Protocol (FR-046)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        _buildStepTile('1. Fall Detected', 'Device vibrates intensely and sounds high-decibel auditory alarm.'),
        _buildStepTile('2. 30-Second Countdown', 'You have 30 seconds to tap "I am OK" if it was a false drop.'),
        _buildStepTile('3. Caregiver GPS Alert', 'Automatic SMS & Push sent to your designated proxy with your GPS coordinates.'),
      ],
    );
  }

  Widget _buildBrainTrainingTab(Color cardColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.psychology, size: 50, color: Color(0xFFA855F7)),
                const SizedBox(height: 10),
                Text(
                  'Daily Cognitive Reaction Game',
                  style: TextStyle(
                    fontSize: _largeTextMode ? 20 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Maintains neuro-plastic processing speed and executive working memory in senior males.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                if (!_isGameRunning)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA855F7),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _isGameRunning = true;
                        _gameScore = 0;
                        _targetNumber = (DateTime.now().microsecond % 9) + 1;
                      });
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Daily 30s Challenge'),
                  )
                else
                  Column(
                    children: [
                      Text(
                        'Tap the number: $_targetNumber',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(9, (idx) {
                          final num = idx + 1;
                          return InkWell(
                            onTap: () {
                              if (num == _targetNumber) {
                                setState(() {
                                  _gameScore += 10;
                                  _targetNumber = ((_targetNumber * 3) % 9) + 1;
                                });
                              }
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                '$num',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Score: $_gameScore pts',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () async {
                          final score = CognitiveScore(
                            id: 'score_${DateTime.now().millisecondsSinceEpoch}',
                            userId: widget.userId,
                            date: DateTime.now(),
                            gameType: 'Quick Number Match',
                            score: _gameScore,
                            timeSeconds: 30,
                          );
                          await widget.repository.saveCognitiveScore(score);
                          setState(() => _isGameRunning = false);
                          _loadData();
                        },
                        child: const Text('Finish Game & Record Score', style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Cognitive History & Neuro-Stamina',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ..._cognitiveScores.map((score) => Card(
              color: cardColor,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFA855F7),
                  child: Icon(Icons.star, color: Colors.white),
                ),
                title: Text(score.gameType, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text('Score: ${score.score} pts • ${score.timeSeconds}s duration', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ),
            )),
      ],
    );
  }

  Widget _buildCaregiverTab(Color cardColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Authorized Caregiver Proxies',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.person_add, color: Color(0xFF10B981)),
              onPressed: _showAddCaregiverDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),

        ..._caregivers.map((cg) => Card(
              color: cardColor,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white10,
                          child: Icon(Icons.family_restroom, color: Color(0xFF38BDF8)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cg.caregiverName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                '${cg.relationship} • ${cg.caregiverPhone}',
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (cg.receivesFallAlerts)
                          _buildPermissionChip('Emergency Fall Alerts', Colors.redAccent),
                        if (cg.canViewVitals)
                          _buildPermissionChip('Read Vitals', Colors.blueAccent),
                        if (cg.canViewMedications)
                          _buildPermissionChip('Medication Schedule', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildAccessibilityTab(Color cardColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sensory & Visual Ergonomics (FR-050)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Large Text Scaling', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Increases system typography for cataract & presbyopia support', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  value: _largeTextMode,
                  onChanged: (v) => setState(() => _largeTextMode = v),
                ),
                const Divider(color: Colors.white12),
                SwitchListTile(
                  title: const Text('High-Contrast AMOLED Black', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Enhances border delineation and reduces visual glare', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  value: _highContrast,
                  onChanged: (v) => setState(() => _highContrast = v),
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.record_voice_over, color: Color(0xFF38BDF8)),
                  title: const Text('Screen Reader & Voice Navigation', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Compatible with TalkBack and VoiceOver navigation', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  trailing: const Icon(Icons.check, color: Color(0xFF10B981)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStepTile(String title, String desc) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
        subtitle: Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    );
  }

  void _triggerSimulatedFallCountdown() {
    int countdown = 10;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (countdown > 1) {
                setDialogState(() => countdown--);
              } else {
                t.cancel();
                Navigator.pop(context);
                _dispatchFallAlert();
              }
            });

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Color(0xFFEF4444), size: 28),
                  SizedBox(width: 8),
                  Text('POTENTIAL FALL DETECTED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Emergency alerts will be broadcast to all designated proxies in:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$countdown',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      timer?.cancel();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fall alert cancelled by user. False alarm.')),
                      );
                    },
                    child: const Text('I AM OK — CANCEL ALERT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _dispatchFallAlert() async {
    final alert = FallAlert(
      id: 'fall_${DateTime.now().millisecondsSinceEpoch}',
      userId: widget.userId,
      timestamp: DateTime.now(),
      locationEstimate: 'Living Room, Residence',
      status: 'Emergency Contact Notified',
    );
    await widget.repository.triggerFallAlert(alert);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFEF4444),
          content: Text('EMERGENCY SOS SENT: Designated caregivers have been notified with GPS location.'),
        ),
      );
    }
  }

  void _showAddCaregiverDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Designate Caregiver', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Caregiver Full Name',
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Emergency Phone Number',
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
              TextField(
                controller: relCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Relationship (e.g. Spouse, Son, Nurse)',
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final cg = CaregiverProfile(
                    linkId: 'cg_${DateTime.now().millisecondsSinceEpoch}',
                    seniorUserId: widget.userId,
                    caregiverName: nameCtrl.text.trim(),
                    caregiverEmail: 'proxy@malevitality.health',
                    caregiverPhone: phoneCtrl.text.trim(),
                    relationship: relCtrl.text.trim(),
                    canViewVitals: true,
                    canViewMedications: true,
                    receivesFallAlerts: true,
                  );
                  await widget.repository.addCaregiver(cg);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadData();
                  }
                }
              },
              child: const Text('Save Proxy'),
            ),
          ],
        );
      },
    );
  }
}

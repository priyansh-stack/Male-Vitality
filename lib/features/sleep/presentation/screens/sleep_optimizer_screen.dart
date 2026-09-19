import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/sleep_entry.dart';
import '../../domain/repositories/i_sleep_repository.dart';

class SleepOptimizerScreen extends StatefulWidget {
  final String userId;
  final ISleepRepository repository;

  const SleepOptimizerScreen({
    super.key,
    required this.userId,
    required this.repository,
  });

  @override
  State<SleepOptimizerScreen> createState() => _SleepOptimizerScreenState();
}

class _SleepOptimizerScreenState extends State<SleepOptimizerScreen> {
  List<SleepEntry> _history = [];
  bool _isDeprived = false;
  bool _isLoading = true;
  bool _smartAlarmEnabled = true;
  TimeOfDay _targetWakeTime = const TimeOfDay(hour: 6, minute: 45);

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    setState(() => _isLoading = true);
    final list = await widget.repository.getSleepHistory(widget.userId, days: 7);
    final deprived = await widget.repository.hasChronicSleepDeprivation(widget.userId);
    if (mounted) {
      setState(() {
        _history = list;
        _isDeprived = deprived;
        _isLoading = false;
      });
    }
  }

  double get _avgHours {
    if (_history.isEmpty) return 7.5;
    final total = _history.fold<double>(0.0, (sum, e) => sum + e.durationHours);
    return total / _history.length;
  }

  int get _avgScore {
    if (_history.isEmpty) return 80;
    final total = _history.fold<int>(0, (sum, e) => sum + e.qualityScore);
    return (total / _history.length).round();
  }

  int get _avgDeepMinutes {
    if (_history.isEmpty) return 85;
    final total = _history.fold<int>(0, (sum, e) => sum + e.deepSleepMinutes);
    return (total / _history.length).round();
  }

  int get _avgRemMinutes {
    if (_history.isEmpty) return 95;
    final total = _history.fold<int>(0, (sum, e) => sum + e.remSleepMinutes);
    return (total / _history.length).round();
  }

  List<Map<String, dynamic>> _calculateOptimalBedtimes(TimeOfDay wakeTime) {
    final now = DateTime.now();
    final wakeDateTime = DateTime(now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);

    return [
      {
        'cycles': 6,
        'duration': '9.0 hrs',
        'time': wakeDateTime.subtract(const Duration(hours: 9, minutes: 15)),
        'badge': 'Peak GH & Testosterone Synthesis',
        'color': AppTheme.neonCyan,
      },
      {
        'cycles': 5,
        'duration': '7.5 hrs',
        'time': wakeDateTime.subtract(const Duration(hours: 7, minutes: 45)),
        'badge': 'Optimal Cognitive & Metabolic Balance',
        'color': AppTheme.neonEmerald,
      },
      {
        'cycles': 4,
        'duration': '6.0 hrs',
        'time': wakeDateTime.subtract(const Duration(hours: 6, minutes: 15)),
        'badge': 'Minimum Viable Sleep Threshold',
        'color': AppTheme.neonAmber,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final optimalBedtimes = _calculateOptimalBedtimes(_targetWakeTime);

    return Scaffold(
      backgroundColor: AppTheme.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidianCard,
        elevation: 0,
        title: const Text(
          'Sleep Optimizer & Circadian Hub',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.neonCyan),
            onPressed: _showLogSleepDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadSleepData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Chronic Sleep Deprivation Flag (FR-038)
                if (_isDeprived) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.neonCrimson.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.neonCrimson),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppTheme.neonCrimson, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chronic Sleep Deprivation Flagged',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Telemetry detected < 6.0 hours of sleep across consecutive nights. In males, this acutely blunts nocturnal LH and morning total testosterone production by 10–15%. Immediate circadian alignment advised.',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Overview Metrics
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.obsidianCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('7-Day Avg Sleep', style: TextStyle(fontSize: 11, color: Colors.white60)),
                            const SizedBox(height: 4),
                            Text(
                              '${_avgHours.toStringAsFixed(1)} hrs',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            const Text('Target: 7–9 hrs', style: TextStyle(fontSize: 10, color: AppTheme.neonEmerald)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.obsidianCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sleep Quality Score', style: TextStyle(fontSize: 11, color: Colors.white60)),
                            const SizedBox(height: 4),
                            Text(
                              '$_avgScore / 100',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.neonPurple),
                            ),
                            const SizedBox(height: 2),
                            Text('Deep: ${_avgDeepMinutes}m • REM: ${_avgRemMinutes}m', style: const TextStyle(fontSize: 10, color: Colors.white60)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ===== SMART CIRCADIAN ALARM & 90-MIN CYCLE CALCULATOR =====
                Card(
                  color: AppTheme.obsidianCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppTheme.neonCyan.withValues(alpha: 0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.alarm_on, color: AppTheme.neonCyan, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Smart Circadian Alarm Engine',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                            Switch(
                              value: _smartAlarmEnabled,
                              activeColor: AppTheme.neonCyan,
                              onChanged: (v) => setState(() => _smartAlarmEnabled = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Calculates 90-minute ultradian sleep cycles from your target wake time to avoid waking during restorative slow-wave delta sleep.',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 14),

                        // Pick target wake time
                        InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _targetWakeTime,
                            );
                            if (picked != null) {
                              setState(() => _targetWakeTime = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.obsidianBase,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.wb_sunny_outlined, size: 18, color: AppTheme.neonAmber),
                                    SizedBox(width: 8),
                                    Text('Target Wake Time:', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _targetWakeTime.format(context),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.neonCyan, fontSize: 15),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.edit, size: 14, color: Colors.white38),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Optimal Bedtimes (90-min cycles)
                        const Text(
                          'Optimal Bedtimes (90-Min Cycles + 15m Latency)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        ...optimalBedtimes.map((opt) {
                          final time = opt['time'] as DateTime;
                          final formattedTime = DateFormat('hh:mm a').format(time);
                          final color = opt['color'] as Color;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.obsidianBase,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${opt['cycles']} CYCLES',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$formattedTime  (${opt['duration']})',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                      ),
                                      Text(
                                        opt['badge'] as String,
                                        style: TextStyle(fontSize: 10, color: color),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Personalized Sleep Hygiene Recommendations (FR-036)
                const Text(
                  'Evidence-Based Sleep Protocols',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildHygieneTile(
                  icon: Icons.ac_unit,
                  title: 'Thermoregulation (65°F – 68°F)',
                  description: 'Core body temperature must drop 2–3°F to initiate deep stage 3 slow-wave delta sleep.',
                ),
                _buildHygieneTile(
                  icon: Icons.wb_sunny,
                  title: 'Morning Photonic Reset',
                  description: 'Expose eyes to 10–15 minutes of outdoor morning sunlight within 30 minutes of waking to lock circadian melatonin timing.',
                ),
                _buildHygieneTile(
                  icon: Icons.coffee,
                  title: 'Adenosine Protection (2:00 PM Cutoff)',
                  description: 'Caffeine blocks adenosine sleep pressure receptors with an 8–10 hour metabolic half-life in adult males.',
                ),
                const SizedBox(height: 16),

                // Sleep History (Fitbit Hardware Telemetry + Manual)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '7-Day Sleep Telemetry (${_history.length} logged)',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.neonCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'FITBIT SYNCED',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.neonCyan),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.obsidianCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Center(
                      child: Text(
                        'No sleep telemetry recorded yet. Connect your Fitbit device or tap + to log a manual session.',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ..._history.map((entry) {
                    final isAdequate = entry.durationHours >= 7.0;
                    final isFitbit = entry.notes.contains('Fitbit') || entry.id.startsWith('fitbit_');

                    return Card(
                      color: AppTheme.obsidianCard,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isAdequate ? AppTheme.neonEmerald.withValues(alpha: 0.25) : AppTheme.neonAmber.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isAdequate
                                      ? AppTheme.neonEmerald.withValues(alpha: 0.15)
                                      : AppTheme.neonAmber.withValues(alpha: 0.15),
                                  radius: 18,
                                  child: Icon(
                                    Icons.bedtime_rounded,
                                    color: isAdequate ? AppTheme.neonEmerald : AppTheme.neonAmber,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat('EEEE, MMM dd').format(entry.date),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          if (isFitbit)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.neonCyan.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'FITBIT',
                                                style: TextStyle(fontSize: 9, color: AppTheme.neonCyan, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${entry.durationHours.toStringAsFixed(1)} hrs • Score: ${entry.qualityScore}/100',
                                        style: TextStyle(fontSize: 12, color: isAdequate ? AppTheme.neonEmerald : AppTheme.neonAmber, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bed: ${DateFormat('hh:mm a').format(entry.bedtime)} → Wake: ${DateFormat('hh:mm a').format(entry.wakeTime)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                                ),
                                Row(
                                  children: [
                                    _buildStageChip('Deep', '${entry.deepSleepMinutes}m', AppTheme.neonCyan),
                                    const SizedBox(width: 6),
                                    _buildStageChip('REM', '${entry.remSleepMinutes}m', AppTheme.neonPurple),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  Widget _buildStageChip(String stage, String duration, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$stage: $duration',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHygieneTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      color: AppTheme.obsidianCard,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.neonCyan.withValues(alpha: 0.12),
          child: Icon(icon, color: AppTheme.neonCyan, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
        subtitle: Text(description, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ),
    );
  }

  void _showLogSleepDialog() {
    final hoursCtrl = TextEditingController(text: '7.5');
    final scoreCtrl = TextEditingController(text: '82');
    final deepCtrl = TextEditingController(text: '90');
    final remCtrl = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.obsidianCard,
          title: const Text('Log Sleep Session', style: TextStyle(color: Colors.white, fontSize: 17)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: hoursCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Total Sleep Duration (Hours)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                TextField(
                  controller: scoreCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Sleep Quality Score (1-100)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: deepCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Deep Sleep (min)',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: remCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'REM Sleep (min)',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonCyan),
              onPressed: () async {
                final duration = double.tryParse(hoursCtrl.text) ?? 7.5;
                final entry = SleepEntry(
                  id: 'sleep_${DateTime.now().millisecondsSinceEpoch}',
                  userId: widget.userId,
                  date: DateTime.now(),
                  bedtime: DateTime.now().subtract(Duration(minutes: (duration * 60).round())),
                  wakeTime: DateTime.now(),
                  durationHours: duration,
                  qualityScore: int.tryParse(scoreCtrl.text) ?? 80,
                  deepSleepMinutes: int.tryParse(deepCtrl.text) ?? 90,
                  remSleepMinutes: int.tryParse(remCtrl.text) ?? 100,
                  notes: 'Manual User Log',
                );
                await widget.repository.logSleep(entry);
                if (mounted) {
                  Navigator.pop(context);
                  _loadSleepData();
                }
              },
              child: const Text('Save Log', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

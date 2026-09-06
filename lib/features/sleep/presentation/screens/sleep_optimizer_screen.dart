import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    setState(() {
      _history = list;
      _isDeprived = deprived;
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Sleep Optimizer',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF6366F1)),
            onPressed: _showLogSleepDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Chronic Sleep Deprivation Flag (FR-038)
                if (_isDeprived) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDC2626)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 28),
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
                                'You have recorded < 6 hours of sleep for 5 consecutive nights. This severely depresses serum testosterone, elevates fasting cortisol, and raises cardiac event risk. A clinical evaluation is recommended.',
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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('7-Day Avg Sleep', style: TextStyle(fontSize: 12, color: Colors.white60)),
                            const SizedBox(height: 4),
                            Text(
                              '${_avgHours.toStringAsFixed(1)} hrs',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            const Text('Target: 7–9 hrs', style: TextStyle(fontSize: 11, color: Color(0xFF10B981))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sleep Quality Score', style: TextStyle(fontSize: 12, color: Colors.white60)),
                            const SizedBox(height: 4),
                            Text(
                              '$_avgScore / 100',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
                            ),
                            const SizedBox(height: 2),
                            const Text('REM & Deep Synchrony', style: TextStyle(fontSize: 11, color: Colors.white60)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Smart Alarm Card (FR-037)
                Card(
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                                Icon(Icons.alarm_on, color: Color(0xFF6366F1)),
                                SizedBox(width: 8),
                                Text(
                                  'Smart Circadian Alarm',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                            Switch(
                              value: _smartAlarmEnabled,
                              activeColor: const Color(0xFF6366F1),
                              onChanged: (v) => setState(() => _smartAlarmEnabled = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Wakes you gently during a light sleep cycle within a 30-minute window, preventing sleep inertia and grogginess.',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
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
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Target Wake Time:', style: TextStyle(color: Colors.white)),
                                Text(
                                  _targetWakeTime.format(context),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Personalized Sleep Hygiene Recommendations (FR-036)
                const Text(
                  'Evidence-Based Sleep Hygiene',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildHygieneTile(
                  icon: Icons.ac_unit,
                  title: 'Thermoregulation (65°F – 68°F)',
                  description: 'Core body temperature must drop 2–3°F to initiate deep stage 3 slow-wave sleep.',
                ),
                _buildHygieneTile(
                  icon: Icons.wb_sunny,
                  title: 'Morning Photonic Reset',
                  description: 'Expose eyes to 10–15 minutes of outdoor morning sunlight within 30 minutes of waking to anchor cortisol and melatonin clocks.',
                ),
                _buildHygieneTile(
                  icon: Icons.coffee,
                  title: 'Caffeine Half-Life Cutoff (2:00 PM)',
                  description: 'Caffeine blocks adenosine sleep pressure receptors for up to 8–10 hours after consumption.',
                ),
                const SizedBox(height: 16),

                // Sleep History
                const Text(
                  'Recent Sleep Sessions',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ..._history.map((entry) => Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: entry.durationHours >= 7.0
                              ? const Color(0xFF10B981).withValues(alpha: 0.2)
                              : const Color(0xFFEF4444).withValues(alpha: 0.2),
                          child: Icon(
                            Icons.bedtime,
                            color: entry.durationHours >= 7.0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                        title: Text(
                          '${DateFormat('EEEE, MMM dd').format(entry.date)}: ${entry.durationHours.toStringAsFixed(1)} hrs',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Bed: ${DateFormat('hh:mm a').format(entry.bedtime)} • Wake: ${DateFormat('hh:mm a').format(entry.wakeTime)}\nQuality Score: ${entry.qualityScore}/100',
                          style: const TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                      ),
                    )),
              ],
            ),
    );
  }

  Widget _buildHygieneTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ),
    );
  }

  void _showLogSleepDialog() {
    final hoursCtrl = TextEditingController(text: '7.5');
    final scoreCtrl = TextEditingController(text: '85');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Log Sleep Session', style: TextStyle(color: Colors.white)),
          content: Column(
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              onPressed: () async {
                final entry = SleepEntry(
                  id: 'sleep_${DateTime.now().millisecondsSinceEpoch}',
                  userId: widget.userId,
                  date: DateTime.now(),
                  bedtime: DateTime.now().subtract(const Duration(hours: 8)),
                  wakeTime: DateTime.now(),
                  durationHours: double.tryParse(hoursCtrl.text) ?? 7.5,
                  qualityScore: int.tryParse(scoreCtrl.text) ?? 80,
                );
                await widget.repository.logSleep(entry);
                if (mounted) {
                  Navigator.pop(context);
                  _loadSleepData();
                }
              },
              child: const Text('Save Log'),
            ),
          ],
        );
      },
    );
  }
}

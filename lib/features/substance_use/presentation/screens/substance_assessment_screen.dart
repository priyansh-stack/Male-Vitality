import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/audit_c_assessment.dart';
import '../../domain/repositories/i_substance_repository.dart';

class SubstanceAssessmentScreen extends StatefulWidget {
  final String userId;
  final ISubstanceRepository repository;

  const SubstanceAssessmentScreen({
    super.key,
    required this.userId,
    required this.repository,
  });

  @override
  State<SubstanceAssessmentScreen> createState() =>
      _SubstanceAssessmentScreenState();
}

class _SubstanceAssessmentScreenState extends State<SubstanceAssessmentScreen> {
  AuditCAssessment? _assessment;
  List<String> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final a = await widget.repository.getLatestAssessment(widget.userId);
    final g = await widget.repository.getReductionGoals(widget.userId);
    setState(() {
      _assessment = a;
      _goals = g;
      _isLoading = false;
    });
  }

  Future<void> _callSamhsa() async {
    final uri = Uri.parse('tel:18006624357');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Substance & Alcohol Health',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEC4899)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // AUDIT-C Score Card
                if (_assessment != null) _buildAuditCard(_assessment!),
                const SizedBox(height: 16),

                // SAMHSA 24/7 Helpline Card (FR-041)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.phone_in_talk, color: Color(0xFF10B981)),
                          SizedBox(width: 8),
                          Text(
                            'SAMHSA National Helpline (24/7)',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Free, confidential, 24/7 365-day treatment referral and information service for individuals facing mental and/or substance use disorders.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                          onPressed: _callSamhsa,
                          icon: const Icon(Icons.call),
                          label: const Text('Call 1-800-662-HELP (4357)'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Harm Reduction Goals (FR-042)
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
                            const Text(
                              'Personal Harm Reduction Goals',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Color(0xFFEC4899)),
                              onPressed: _showAddGoalDialog,
                            ),
                          ],
                        ),
                        ..._goals.map((goal) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(goal, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Educational Content (FR-040)
                const Text(
                  'Clinical Substance Guidance',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildEduTile(
                  title: 'Binge Drinking & Cardiovascular Strain',
                  content:
                      'In men 18–39, binge drinking (5+ drinks in 2 hours) triggers acute atrial fibrillation ("Holiday Heart Syndrome"), surges blood pressure, and halts nocturnal growth hormone release by over 70%.',
                ),
                _buildEduTile(
                  title: 'Nicotine Vaping & Microvascular Flow',
                  content:
                      'Aerosolized nicotine induces immediate vasoconstriction of penile and coronary capillaries, accelerating early-onset erectile dysfunction and arterial stiffening.',
                ),
              ],
            ),
    );
  }

  Widget _buildAuditCard(AuditCAssessment a) {
    final isHazardous = a.isHazardousDrinking;

    return Card(
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
                    Icon(Icons.local_bar, color: Color(0xFFEC4899)),
                    SizedBox(width: 8),
                    Text(
                      'AUDIT-C Alcohol Evaluation',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHazardous
                        ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                        : const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Score: ${a.totalScore}/12',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isHazardous ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Category: ${a.riskCategory}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isHazardous ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 6),
            Text(a.clinicalGuidance, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFEC4899)),
                onPressed: _showRetakeAuditDialog,
                child: const Text('Retake AUDIT-C Questionnaire'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEduTile({required String title, required String content}) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
            const SizedBox(height: 4),
            Text(content, style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4)),
          ],
        ),
      ),
    );
  }

  void _showRetakeAuditDialog() {
    int q1 = 1;
    int q2 = 1;
    int q3 = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text('AUDIT-C Assessment', style: TextStyle(color: Colors.white, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. How often do you have a drink containing alcohol?', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      value: q1,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Never')),
                        DropdownMenuItem(value: 1, child: Text('Monthly or less')),
                        DropdownMenuItem(value: 2, child: Text('2 to 4 times a month')),
                        DropdownMenuItem(value: 3, child: Text('2 to 3 times a week')),
                        DropdownMenuItem(value: 4, child: Text('4 or more times a week')),
                      ],
                      onChanged: (v) => setDialogState(() => q1 = v ?? 0),
                    ),
                    const SizedBox(height: 12),
                    const Text('2. How many drinks containing alcohol on a typical day?', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      value: q2,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('1 or 2')),
                        DropdownMenuItem(value: 1, child: Text('3 or 4')),
                        DropdownMenuItem(value: 2, child: Text('5 or 6')),
                        DropdownMenuItem(value: 3, child: Text('7, 8, or 9')),
                        DropdownMenuItem(value: 4, child: Text('10 or more')),
                      ],
                      onChanged: (v) => setDialogState(() => q2 = v ?? 0),
                    ),
                    const SizedBox(height: 12),
                    const Text('3. How often do you have 6 or more drinks on one occasion?', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      value: q3,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Never')),
                        DropdownMenuItem(value: 1, child: Text('Less than monthly')),
                        DropdownMenuItem(value: 2, child: Text('Monthly')),
                        DropdownMenuItem(value: 3, child: Text('Weekly')),
                        DropdownMenuItem(value: 4, child: Text('Daily or almost daily')),
                      ],
                      onChanged: (v) => setDialogState(() => q3 = v ?? 0),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
                  onPressed: () async {
                    final assessment = AuditCAssessment(
                      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
                      userId: widget.userId,
                      timestamp: DateTime.now(),
                      q1FrequencyScore: q1,
                      q2QuantityScore: q2,
                      q3BingeScore: q3,
                    );
                    await widget.repository.saveAssessment(assessment);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadData();
                    }
                  },
                  child: const Text('Calculate & Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddGoalDialog() {
    final goalCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('New Reduction Goal', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: goalCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'e.g. Alcohol-free weekdays...',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
              onPressed: () async {
                if (goalCtrl.text.trim().isNotEmpty) {
                  await widget.repository.addReductionGoal(widget.userId, goalCtrl.text.trim());
                  if (mounted) {
                    Navigator.pop(context);
                    _loadData();
                  }
                }
              },
              child: const Text('Add Goal'),
            ),
          ],
        );
      },
    );
  }
}

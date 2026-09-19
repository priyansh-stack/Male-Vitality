import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
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
    if (mounted) {
      setState(() {
        _assessment = a;
        _goals = g;
        _isLoading = false;
      });
    }
  }

  Future<void> _callSamhsa() async {
    final uri = Uri.parse('tel:18006624357');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWebUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open portal: $url'),
            backgroundColor: AppTheme.neonCrimson,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidianCard,
        elevation: 0,
        title: const Text(
          'Substance & Alcohol Assessment',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan))
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
                    color: AppTheme.obsidianCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.phone_in_talk, color: AppTheme.neonEmerald),
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
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonEmerald,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _callSamhsa,
                              icon: const Icon(Icons.call, size: 18),
                              label: const Text('Call 1-800-662-4357', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.neonEmerald),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _launchWebUrl('https://findtreatment.gov'),
                            icon: const Icon(Icons.open_in_browser, size: 16, color: AppTheme.neonEmerald),
                            label: const Text('Find Clinic', style: TextStyle(color: AppTheme.neonEmerald, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Harm Reduction Goals (FR-042)
                Card(
                  color: AppTheme.obsidianCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Colors.white12),
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
                                Icon(Icons.check_circle_outline, color: AppTheme.neonCyan, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Personal Harm Reduction Goals',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: AppTheme.neonCyan),
                              onPressed: _showAddGoalDialog,
                            ),
                          ],
                        ),
                        if (_goals.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No reduction goals logged yet. Tap + to set a personal target (e.g. Alcohol-free weekdays, Nicotine taper).',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          )
                        else
                          ..._goals.map((goal) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppTheme.neonEmerald, size: 16),
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

                // Verified Clinical Portals & Guidance (Clickable Links)
                const Row(
                  children: [
                    Icon(Icons.link, color: AppTheme.neonCyan, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Verified Clinical Portals & Resources',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                _buildResourceTile(
                  title: 'NIAAA Rethinking Drinking',
                  subtitle: 'Evidence-based guidance on alcohol limits, low-risk drinking guidelines for men, and personal drink trackers.',
                  url: 'https://www.rethinkingdrinking.niaaa.nih.gov',
                  badge: 'NIH / NIAAA Official',
                ),
                _buildResourceTile(
                  title: 'CDC Men\'s Health: Excessive Alcohol Use',
                  subtitle: 'Clinical facts on binge drinking, male reproductive health, liver metabolism, and testosterone impairment.',
                  url: 'https://www.cdc.gov/alcohol/fact-sheets/mens-health.htm',
                  badge: 'CDC Official Guide',
                ),
                _buildResourceTile(
                  title: 'Smokefree.gov Men\'s Cessation Protocol',
                  subtitle: 'Evidence-based strategies to quit combustible cigarettes, nicotine vaping, and protect penile microvascular flow.',
                  url: 'https://smokefree.gov',
                  badge: 'NCI / HHS Portal',
                ),
                _buildResourceTile(
                  title: 'AUDIT-C Clinical Scoring Manual',
                  subtitle: 'Official Veterans Affairs & World Health Organization 3-question alcohol screening validation methodology.',
                  url: 'https://www.hepatitis.va.gov/provider/tools/audit-c.asp',
                  badge: 'VA / WHO Standard',
                ),
                _buildResourceTile(
                  title: 'NIDA Substance Treatment Locator',
                  subtitle: 'National Institute on Drug Abuse guidelines and accredited outpatient treatment services locator.',
                  url: 'https://nida.nih.gov',
                  badge: 'NIH Portal',
                ),
              ],
            ),
    );
  }

  Widget _buildAuditCard(AuditCAssessment a) {
    final isHazardous = a.isHazardousDrinking;

    return Card(
      color: AppTheme.obsidianCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isHazardous ? AppTheme.neonCrimson.withValues(alpha: 0.5) : AppTheme.neonEmerald.withValues(alpha: 0.5),
        ),
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
                    Icon(Icons.local_bar, color: AppTheme.neonCyan),
                    SizedBox(width: 8),
                    Text(
                      'AUDIT-C Evaluation',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHazardous
                        ? AppTheme.neonCrimson.withValues(alpha: 0.2)
                        : AppTheme.neonEmerald.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Score: ${a.totalScore}/12',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isHazardous ? AppTheme.neonCrimson : AppTheme.neonEmerald,
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
                color: isHazardous ? AppTheme.neonAmber : AppTheme.neonEmerald,
              ),
            ),
            const SizedBox(height: 6),
            Text(a.clinicalGuidance, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.neonCyan,
                      side: const BorderSide(color: AppTheme.neonCyan),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _showRetakeAuditDialog,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retake Questionnaire', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonCyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _launchWebUrl('https://www.rethinkingdrinking.niaaa.nih.gov'),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('NIAAA Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceTile({
    required String title,
    required String subtitle,
    required String url,
    required String badge,
  }) {
    return Card(
      color: AppTheme.obsidianCard,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _launchWebUrl(url),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.neonCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(fontSize: 10, color: AppTheme.neonCyan, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.open_in_new, size: 13, color: AppTheme.neonCyan),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      url,
                      style: const TextStyle(fontSize: 11, color: AppTheme.neonCyan, decoration: TextDecoration.underline),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
              backgroundColor: AppTheme.obsidianCard,
              title: const Text('AUDIT-C Assessment', style: TextStyle(color: Colors.white, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. How often do you have a drink containing alcohol?', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      value: q1,
                      isExpanded: true,
                      dropdownColor: AppTheme.obsidianCard,
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
                      dropdownColor: AppTheme.obsidianCard,
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
                      dropdownColor: AppTheme.obsidianCard,
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonCyan),
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
                  child: const Text('Calculate & Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          backgroundColor: AppTheme.obsidianCard,
          title: const Text('New Reduction Goal', style: TextStyle(color: Colors.white, fontSize: 16)),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonCyan),
              onPressed: () async {
                if (goalCtrl.text.trim().isNotEmpty) {
                  await widget.repository.addReductionGoal(widget.userId, goalCtrl.text.trim());
                  if (mounted) {
                    Navigator.pop(context);
                    _loadData();
                  }
                }
              },
              child: const Text('Add Goal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

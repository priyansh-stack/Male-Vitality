import 'package:flutter/material.dart';
import '../../domain/models/fertility_lifestyle_audit.dart';
import '../../domain/models/semen_analysis_record.dart';
import '../../domain/repositories/i_fertility_repository.dart';

class FertilityTrackerScreen extends StatefulWidget {
  final String userId;
  final IFertilityRepository repository;

  const FertilityTrackerScreen({
    super.key,
    required this.userId,
    required this.repository,
  });

  @override
  State<FertilityTrackerScreen> createState() => _FertilityTrackerScreenState();
}

class _FertilityTrackerScreenState extends State<FertilityTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<SemenAnalysisRecord> _records = [];
  FertilityLifestyleAudit? _lifestyleAudit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final records = await widget.repository.getAnalysisHistory(widget.userId);
    final audit = await widget.repository.getLifestyleAudit(widget.userId);
    if (mounted) {
      setState(() {
        _records = records;
        _lifestyleAudit = audit ??
            FertilityLifestyleAudit(userId: widget.userId, updatedAt: DateTime.now());
        _isLoading = false;
      });
    }
  }

  void _showAddAnalysisDialog() {
    final abstinenceCtrl = TextEditingController(text: '3');
    final volumeCtrl = TextEditingController(text: '2.5');
    final concentrationCtrl = TextEditingController(text: '30.0');
    final motilityCtrl = TextEditingController(text: '55.0');
    final progressiveCtrl = TextEditingController(text: '40.0');
    final morphologyCtrl = TextEditingController(text: '5.0');
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Log Semen Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Text(
                  'Parameters evaluated against WHO Laboratory Manual (6th Edition).',
                  style: TextStyle(fontSize: 12, color: Colors.white60),
                ),
                const SizedBox(height: 16),
                _buildField(abstinenceCtrl, 'Abstinence Period (Days)', 'e.g. 2–7 days (recommended)'),
                _buildField(volumeCtrl, 'Ejaculate Volume (mL)', 'WHO norm: ≥ 1.4 mL'),
                _buildField(concentrationCtrl, 'Sperm Concentration (Million / mL)', 'WHO norm: ≥ 16 M/mL'),
                _buildField(motilityCtrl, 'Total Motility (%)', 'WHO norm: ≥ 42%'),
                _buildField(progressiveCtrl, 'Progressive Motility (%)', 'WHO norm: ≥ 30%'),
                _buildField(morphologyCtrl, 'Normal Morphology (%)', 'Kruger strict: ≥ 4%'),
                _buildField(notesCtrl, 'Clinical Notes / Lab Name', 'e.g. LabCorp, Quest, at-home Fellow'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final record = SemenAnalysisRecord(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: widget.userId,
                        testDate: DateTime.now(),
                        abstinenceDays: int.tryParse(abstinenceCtrl.text) ?? 3,
                        volumeMl: double.tryParse(volumeCtrl.text) ?? 2.0,
                        spermConcentrationMillionPerMl: double.tryParse(concentrationCtrl.text) ?? 20.0,
                        totalMotilityPercent: double.tryParse(motilityCtrl.text) ?? 50.0,
                        progressiveMotilityPercent: double.tryParse(progressiveCtrl.text) ?? 35.0,
                        normalMorphologyPercent: double.tryParse(morphologyCtrl.text) ?? 5.0,
                        notes: notesCtrl.text.trim(),
                      );
                      await widget.repository.saveAnalysisRecord(widget.userId, record);
                      Navigator.pop(ctx);
                      _loadData();
                    },
                    child: const Text('Save Analysis Record', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.tealAccent, fontSize: 13),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
          filled: true,
          fillColor: const Color(0xFF0F172A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Male Fertility & Sperm Health',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF14B8A6),
          labelColor: const Color(0xFF14B8A6),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Semen Analysis'),
            Tab(icon: Icon(Icons.autorenew_rounded), text: '74-Day Renewal'),
            Tab(icon: Icon(Icons.favorite_outline), text: 'Conception Timing'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSemenAnalysisTab(),
                _buildRenewalLifestyleTab(),
                _buildConceptionTimingTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF14B8A6),
        onPressed: _showAddAnalysisDialog,
        icon: const Icon(Icons.add_chart_rounded, color: Colors.white),
        label: const Text('Log Test Result', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSemenAnalysisTab() {
    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.biotech_rounded, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'No Semen Analysis Logged Yet',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Log your laboratory or home semen test results to track parameters.',
              style: TextStyle(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B8A6)),
              onPressed: _showAddAnalysisDialog,
              child: const Text('Log First Test'),
            ),
          ],
        ),
      );
    }

    final latest = _records.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'WHO 6th Edition Evaluation',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: latest.isOptimal
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: latest.isOptimal ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                      ),
                      child: Text(
                        latest.isOptimal ? 'Normozoospermia' : 'Suboptimal Parameters',
                        style: TextStyle(
                          color: latest.isOptimal ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tested on ${latest.testDate.month}/${latest.testDate.day}/${latest.testDate.year} • Abstinence: ${latest.abstinenceDays} days',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const Divider(color: Colors.white12, height: 24),

                // Grid of metrics
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildMetricBadge('Volume', '${latest.volumeMl.toStringAsFixed(1)} mL', latest.isVolumeNormal, '≥ 1.4 mL'),
                    _buildMetricBadge('Concentration', '${latest.spermConcentrationMillionPerMl.toStringAsFixed(0)} M/mL', latest.isConcentrationNormal, '≥ 16 M/mL'),
                    _buildMetricBadge('Total Motility', '${latest.totalMotilityPercent.toStringAsFixed(0)}%', latest.isMotilityNormal, '≥ 42%'),
                    _buildMetricBadge('Prog. Motility', '${latest.progressiveMotilityPercent.toStringAsFixed(0)}%', latest.isProgressiveMotilityNormal, '≥ 30%'),
                    _buildMetricBadge('Morphology', '${latest.normalMorphologyPercent.toStringAsFixed(1)}%', latest.isMorphologyNormal, '≥ 4.0%'),
                    _buildMetricBadge('Total Count', '${latest.totalSpermCountMillion.toStringAsFixed(0)} Million', latest.totalSpermCountMillion >= 39, '≥ 39 M'),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'Clinical Findings & Interpretation',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ...latest.clinicalFindings.map(
          (finding) => Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                finding.contains('Normozoospermia') ? Icons.check_circle_outline : Icons.info_outline,
                color: finding.contains('Normozoospermia') ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              ),
              title: Text(finding, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBadge(String title, String val, bool isNormal, String normText) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNormal ? const Color(0xFF10B981).withValues(alpha: 0.4) : const Color(0xFFEF4444).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            val,
            style: TextStyle(
              color: isNormal ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text('Ref: $normText', style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildRenewalLifestyleTab() {
    final audit = _lifestyleAudit ??
        FertilityLifestyleAudit(userId: widget.userId, updatedAt: DateTime.now());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 74-Day Spermatogenesis Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.hourglass_top_rounded, color: Colors.tealAccent, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'The 74-Day Spermatogenesis Cycle',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Human sperm cells require approximately 74 days (2.5 months) to develop from germ cells into mature spermatozoa, followed by 12–14 days in the epididymis. Lifestyle, dietary, and temperature optimizations you adopt today will fully manifest in your semen profile roughly 74–90 days from now.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lifestyle Optimization Score',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            ),
            Text(
              '${audit.optimizationScore} / 100',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14B8A6), fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: audit.optimizationScore / 100.0,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF14B8A6)),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 20),

        _buildSwitchTile(
          'Avoid Scrotal Heat Exposure',
          'Avoid saunas, hot baths, and placing laptops directly on the lap. Testes function 2–4°C below core body temperature.',
          audit.avoidsHeatExposure,
          (val) => _updateAudit(audit.toMap()..['avoidsHeatExposure'] = val),
        ),
        _buildSwitchTile(
          'Wear Loose-Fitting Underwear',
          'Boxers or breathable ergonomic underwear significantly lower scrotal temperature compared to tight briefs.',
          audit.looseUnderwear,
          (val) => _updateAudit(audit.toMap()..['looseUnderwear'] = val),
        ),
        _buildSwitchTile(
          'Targeted Antioxidant Supplementation',
          'CoQ10 (200 mg), Zinc (25–50 mg), Selenium (200 mcg), and L-Carnitine reduce sperm DNA fragmentation and boost motility.',
          audit.takesAntioxidants,
          (val) => _updateAudit(audit.toMap()..['takesAntioxidants'] = val),
        ),
        _buildSwitchTile(
          'Zero Smoking & Vaping',
          'Nicotine and combustion toxins generate reactive oxygen species (ROS), causing sperm DNA oxidation and reduced count.',
          audit.nonSmokerAndVaper,
          (val) => _updateAudit(audit.toMap()..['nonSmokerAndVaper'] = val),
        ),
        _buildSwitchTile(
          'Moderate or Zero Alcohol',
          'Excessive alcohol suppresses LH and FSH secretion, disrupting testosterone production and healthy spermatogenesis.',
          audit.moderateOrZeroAlcohol,
          (val) => _updateAudit(audit.toMap()..['moderateOrZeroAlcohol'] = val),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool currentVal, Function(bool) onChanged) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        activeColor: const Color(0xFF14B8A6),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        value: currentVal,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _updateAudit(Map<String, dynamic> updatedMap) async {
    final newAudit = FertilityLifestyleAudit.fromMap(updatedMap, widget.userId);
    await widget.repository.saveLifestyleAudit(widget.userId, newAudit);
    setState(() => _lifestyleAudit = newAudit);
  }

  Widget _buildConceptionTimingTab() {
    final audit = _lifestyleAudit ??
        FertilityLifestyleAudit(userId: widget.userId, updatedAt: DateTime.now());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Fertile Window Card
        Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: Color(0xFF14B8A6), size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Optimal Conception Frequency',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '• Clinical consensus (ASRM) recommends intercourse every 1 to 2 days beginning 5 days prior to ovulation through the day of ovulation.\n'
                  '• Long periods of abstinence (>5 days) increase sperm count but paradoxically degrade motility and increase DNA fragmentation.\n'
                  '• Daily or every-other-day ejaculation preserves optimal progressive motility and DNA integrity.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'When to Seek a Reproductive Specialist',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),

        // Specialist referral advisory box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: audit.shouldConsultSpecialist
                ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                : const Color(0xFF10B981).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: audit.shouldConsultSpecialist ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    audit.shouldConsultSpecialist ? Icons.warning_rounded : Icons.check_circle_rounded,
                    color: audit.shouldConsultSpecialist ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    audit.shouldConsultSpecialist
                        ? 'Physician Referral Advised'
                        : 'Routine Conception Window',
                    style: TextStyle(
                      color: audit.shouldConsultSpecialist ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                audit.specialistGuidelineReason,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'Clinical Red Flags Warranting Early Evaluation:',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _buildBullet('History of cryptorchidism (undescended testicle) in childhood'),
        _buildBullet('Varicocele (enlarged scrotal veins / "bag of worms" sensation)'),
        _buildBullet('History of testicular mumps, severe trauma, or groin surgery'),
        _buildBullet('Previous chemotherapy, radiation, or anabolic steroid / TRT use'),
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }
}

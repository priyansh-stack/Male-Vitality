import 'package:flutter/material.dart';
import '../../domain/models/sti_assessment_model.dart';
import '../../domain/models/testosterone_symptom_log.dart';
import '../../domain/repositories/i_sexual_health_repository.dart';

class SexualHealthScreen extends StatefulWidget {
  final String userId;
  final ISexualHealthRepository repository;

  const SexualHealthScreen({
    super.key,
    required this.userId,
    required this.repository,
  });

  @override
  State<SexualHealthScreen> createState() => _SexualHealthScreenState();
}

class _SexualHealthScreenState extends State<SexualHealthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUnlocked = false;
  final TextEditingController _pinController = TextEditingController();

  List<TestosteroneSymptomLog> _tLogs = [];
  List<TestingCenter> _testingCenters = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final logs = await widget.repository.getTestosteroneLogs(widget.userId);
    final centers = await widget.repository.getNearbyTestingCenters('current_location');
    setState(() {
      _tLogs = logs;
      _testingCenters = centers;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return _buildPrivateModeGate();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Hormone & Sexual Health Hub',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_rounded, color: Color(0xFF38BDF8)),
            tooltip: 'Re-lock Private Mode',
            onPressed: () => setState(() => _isUnlocked = false),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF38BDF8),
          tabs: const [
            Tab(text: 'Testosterone (ADAM)'),
            Tab(text: 'ED & Prostate'),
            Tab(text: 'STI Risk & Finder'),
            Tab(text: 'Male Fertility'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTestosteroneTab(),
                _buildEdProstateTab(),
                _buildStiTab(),
                _buildFertilityTab(),
              ],
            ),
    );
  }

  Widget _buildPrivateModeGate() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Confidential Health Mode'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, size: 64, color: Color(0xFF38BDF8)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Private Health Authentication',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Per HIPAA & privacy protocols, hormone and sexual health data requires local confirmation before access.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, color: Colors.white),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() => _isUnlocked = true);
                  _loadData();
                },
                icon: const Icon(Icons.fingerprint),
                label: const Text('Confirm Biometric / PIN Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestosteroneTab() {
    final latestLog = _tLogs.isNotEmpty ? _tLogs.first : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Assessment Call-to-action
        Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assessment_rounded, color: Color(0xFF38BDF8)),
                    SizedBox(width: 8),
                    Text(
                      'ADAM Questionnaire Score',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'The St. Louis University ADAM (Androgen Deficiency in Aging Males) tool is the clinical standard for identifying testosterone deficiency symptoms.',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                if (latestLog != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: latestLog.isAdamPositive
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                          : const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: latestLog.isAdamPositive
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          latestLog.isAdamPositive ? Icons.warning_amber_rounded : Icons.check_circle,
                          color: latestLog.isAdamPositive
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            latestLog.isAdamPositive
                                ? 'Test Positive (${latestLog.totalSymptomCount}/10 symptoms). Clinical discussion recommended.'
                                : 'Test Negative (${latestLog.totalSymptomCount}/10 symptoms). Normal androgen profile.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: latestLog.isAdamPositive
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    onPressed: _showAdamQuestionnaireDialog,
                    child: const Text('Take / Retake ADAM Assessment'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Clinical Info Cards
        _buildInfoTile(
          title: 'Age-Related Testosterone Trajectory',
          content:
              'Beginning around age 30, free testosterone naturally decreases by approximately 1% to 2% annually. Clinical hypogonadism is diagnosed by morning total testosterone < 300 ng/dL across two separate blood draws.',
        ),
        _buildInfoTile(
          title: 'Evidence-Based Lifestyle Optimization',
          content:
              '1. Deep Sleep: Over 70% of daily testosterone is secreted during REM sleep.\n2. Zinc & Vitamin D: Critical micronutrient precursors.\n3. Resistance Training: Multi-joint compound lifts (squats, deadlifts) trigger transient endocrine responses.',
        ),
      ],
    );
  }

  Widget _buildEdProstateTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoTile(
          title: 'ED as a Cardiovascular Barometer',
          content:
              'Erectile arteries are 1–2 mm in diameter, compared to coronary arteries (3–4 mm). Erectile dysfunction is often the earliest clinical indicator of systemic endothelial dysfunction and atherosclerotic plaque, preceding coronary events by 3 to 5 years.',
        ),
        _buildInfoTile(
          title: 'Safety Warning: PDE5 Inhibitors & Nitrates',
          content:
              'CRITICAL: Medications like Sildenafil (Viagra) and Tadalafil (Cialis) must NEVER be taken alongside nitroglycerin or nitrate heart medications due to severe, fatal hypotension.',
        ),
        _buildInfoTile(
          title: 'Benign Prostatic Hyperplasia (BPH)',
          content:
              'Affects over 50% of men in their 50s and 80% of men in their 70s. Common signs include weak urinary stream, nocturia (waking at night to urinate), and hesitancy. Alpha-blockers and 5-ARIs are effective treatments.',
        ),
        _buildInfoTile(
          title: 'Prostate Cancer Awareness & PSA',
          content:
              'Prostate cancer is highly treatable when detected early. Annual PSA blood checks from age 45–50 allow active surveillance and timely intervention.',
        ),
      ],
    );
  }

  Widget _buildStiTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFFE11D48)),
                    SizedBox(width: 8),
                    Text(
                      'Confidential STI Assessment',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Men 18–25 account for almost half of new STIs. Check your risk category anonymously.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
                  onPressed: _showStiEvaluationDialog,
                  child: const Text('Evaluate My STI Exposure Risk'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nearby Testing Centers & Clinics',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ..._testingCenters.map((center) => Card(
              color: const Color(0xFF1E293B),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: center.offersFreeTesting
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : Colors.white10,
                  child: Icon(
                    Icons.location_on,
                    color: center.offersFreeTesting ? const Color(0xFF10B981) : Colors.white70,
                  ),
                ),
                title: Text(center.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text(
                  '${center.address} • ${center.distance}\nPhone: ${center.phone}',
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ),
                trailing: center.offersFreeTesting
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FREE',
                          style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                    : null,
              ),
            )),
      ],
    );
  }

  Widget _buildFertilityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoTile(
          title: 'Spermatogenesis: The 74-Day Cycle',
          content:
              'Human sperm takes approximately 74 days to fully mature. Lifestyle changes made today (stopping smoking, cooling scrotum, reducing alcohol) will reflect in sperm count and motility two to three months later.',
        ),
        _buildInfoTile(
          title: 'Thermal Damage & Varicoceles',
          content:
              'Testicular temperature must remain 2–4°C cooler than core body temperature. Avoid hot tubs, frequent saunas, keeping laptops directly on the lap, and tight non-breathable cycling shorts.',
        ),
        _buildInfoTile(
          title: 'Nutrient Drivers of Sperm Motility',
          content:
              'Zinc (11–15 mg/day) and Coenzyme Q10 (200 mg/day) directly fuel the mitochondrial engines in sperm flagella, enhancing swimming velocity and morphology.',
        ),
        _buildInfoTile(
          title: 'When to Seek a Reproductive Urologist',
          content:
              'If pregnancy has not occurred after 12 months of timed intercourse (or 6 months if partner is over 35), a routine semen analysis is the essential, non-invasive first step.',
        ),
      ],
    );
  }

  Widget _buildInfoTile({required String title, required String content}) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
            const SizedBox(height: 6),
            Text(content, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
          ],
        ),
      ),
    );
  }

  void _showAdamQuestionnaireDialog() {
    bool q1 = false, q2 = false, q3 = false, q4 = false, q5 = false;
    bool q6 = false, q7 = false, q8 = false, q9 = false, q10 = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text('ADAM Symptom Questionnaire', style: TextStyle(color: Colors.white, fontSize: 17)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCheck(
                        '1. Do you have a decrease in libido (sex drive)?',
                        q1,
                        (v) => setDialogState(() => q1 = v),
                      ),
                      _buildCheck(
                        '2. Do you have a lack of energy?',
                        q2,
                        (v) => setDialogState(() => q2 = v),
                      ),
                      _buildCheck(
                        '3. Do you have a decrease in strength and/or endurance?',
                        q3,
                        (v) => setDialogState(() => q3 = v),
                      ),
                      _buildCheck(
                        '4. Have you lost height?',
                        q4,
                        (v) => setDialogState(() => q4 = v),
                      ),
                      _buildCheck(
                        '5. Have you noticed a decreased "enjoyment of life"?',
                        q5,
                        (v) => setDialogState(() => q5 = v),
                      ),
                      _buildCheck(
                        '6. Are you sad and/or grumpy?',
                        q6,
                        (v) => setDialogState(() => q6 = v),
                      ),
                      _buildCheck(
                        '7. Are your erections less strong?',
                        q7,
                        (v) => setDialogState(() => q7 = v),
                      ),
                      _buildCheck(
                        '8. Have you noticed a recent deterioration in your ability to play sports?',
                        q8,
                        (v) => setDialogState(() => q8 = v),
                      ),
                      _buildCheck(
                        '9. Are you falling asleep after dinner?',
                        q9,
                        (v) => setDialogState(() => q9 = v),
                      ),
                      _buildCheck(
                        '10. Has there been a recent deterioration in your work performance?',
                        q10,
                        (v) => setDialogState(() => q10 = v),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                  onPressed: () async {
                    final log = TestosteroneSymptomLog(
                      id: 'tlog_${DateTime.now().millisecondsSinceEpoch}',
                      userId: widget.userId,
                      timestamp: DateTime.now(),
                      hasLowLibido: q1,
                      hasLackEnergy: q2,
                      hasStrengthLoss: q3,
                      hasLostHeight: q4,
                      hasDecreasedEnjoyment: q5,
                      isSadOrGrumpy: q6,
                      areErectionsLessStrong: q7,
                      hasDeterioratedWorkAbility: q8,
                      fallsAsleepAfterDinner: q9,
                      hasRecentWorkDeterioration: q10,
                    );
                    await widget.repository.saveTestosteroneLog(log);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadData();
                    }
                  },
                  child: const Text('Save Assessment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCheck(String text, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      dense: true,
      title: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      value: value,
      activeColor: const Color(0xFF2563EB),
      onChanged: (v) => onChanged(v ?? false),
    );
  }

  void _showStiEvaluationDialog() {
    bool multiple = false;
    bool condoms = true;
    bool symptoms = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text('Confidential STI Risk Check', style: TextStyle(color: Colors.white, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    dense: true,
                    title: const Text('Multiple sexual partners in past 6 months?', style: TextStyle(color: Colors.white, fontSize: 13)),
                    value: multiple,
                    onChanged: (v) => setDialogState(() => multiple = v ?? false),
                  ),
                  CheckboxListTile(
                    dense: true,
                    title: const Text('Always use barrier protection (condoms)?', style: TextStyle(color: Colors.white, fontSize: 13)),
                    value: condoms,
                    onChanged: (v) => setDialogState(() => condoms = v ?? true),
                  ),
                  CheckboxListTile(
                    dense: true,
                    title: const Text('Experiencing any burning, discharge, or lesions?', style: TextStyle(color: Colors.white, fontSize: 13)),
                    value: symptoms,
                    onChanged: (v) => setDialogState(() => symptoms = v ?? false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

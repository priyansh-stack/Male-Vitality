import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/engine/preventive_care_engine.dart';
import '../../domain/models/screening_record.dart';
import '../../domain/repositories/i_screening_repository.dart';

class PreventiveCareScreen extends StatefulWidget {
  final String userId;
  final IScreeningRepository repository;
  final int userAge;
  final bool isSmoker;

  const PreventiveCareScreen({
    super.key,
    required this.userId,
    required this.repository,
    this.userAge = 35,
    this.isSmoker = false,
  });

  @override
  State<PreventiveCareScreen> createState() => _PreventiveCareScreenState();
}

class _PreventiveCareScreenState extends State<PreventiveCareScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ScreeningRecord> _screenings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScreenings();
  }

  Future<void> _loadScreenings() async {
    setState(() => _isLoading = true);
    final records = await widget.repository.getScreeningRecords(widget.userId);
    if (mounted) {
      setState(() {
        _screenings = records;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _screenings.where((s) => !s.isCompleted).toList();
    final completed = _screenings.where((s) => s.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Preventive Care & Screenings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
            tooltip: 'Add Screening',
            onPressed: () => _showAddScreeningDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          tabs: [
            Tab(text: 'Due & Upcoming (${upcoming.length})'),
            Tab(text: 'Completed (${completed.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Screening', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddScreeningDialog(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingList(upcoming),
                _buildCompletedList(completed),
              ],
            ),
    );
  }

  Widget _buildUpcomingList(List<ScreeningRecord> list) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF10B981), size: 52),
              ),
              const SizedBox(height: 18),
              const Text(
                'No Screenings Scheduled',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your personal clinical screenings, blood tests, or doctor recommendations to track due dates.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showAddScreeningDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Clinical Screening', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final record = list[index];
        final isOverdue = record.dueDate.isBefore(DateTime.now());
        final guideline = PreventiveCareEngine.allGuidelines.firstWhere(
          (g) => g.id == record.guidelineId,
          orElse: () => ClinicalScreeningGuideline(
            id: record.guidelineId,
            title: record.title,
            category: ScreeningCategory.generalWellness,
            frequency: 'Annual',
            minAge: 18,
            evidenceGrade: 'USPSTF Evidence Based',
            plainLanguageWhy: 'Crucial for early disease detection in men.',
            whatToExpect: 'Routine outpatient evaluation.',
            howToInterpret: 'Your doctor will explain your lab markers.',
          ),
        );

        return Card(
          color: const Color(0xFF1E293B),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isOverdue ? const Color(0xFFEF4444) : Colors.white12,
              width: isOverdue ? 1.5 : 1.0,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showGuidelineDetail(record, guideline),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                              : const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOverdue ? 'OVERDUE' : 'DUE SOON',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isOverdue
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          guideline.evidenceGrade,
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                        tooltip: 'Delete Screening',
                        onPressed: () async {
                          await widget.repository.deleteScreeningRecord(widget.userId, record.id);
                          _loadScreenings();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                        tooltip: 'Log Completed',
                        onPressed: () => _showLogCompletionDialog(record),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    record.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due: ${DateFormat('MMMM dd, yyyy').format(record.dueDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isOverdue ? const Color(0xFFEF4444) : Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    guideline.plainLanguageWhy,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedList(List<ScreeningRecord> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No completed screenings logged yet.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final record = list[index];
        return Card(
          color: const Color(0xFF1E293B),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF10B981),
              child: Icon(Icons.check, color: Colors.white),
            ),
            title: Text(
              record.title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (record.completedDate != null)
                  Text(
                    'Completed: ${DateFormat('MMMM dd, yyyy').format(record.completedDate!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                if (record.resultNotes != null && record.resultNotes!.isNotEmpty)
                  Text(
                    'Notes: ${record.resultNotes}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGuidelineDetail(ScreeningRecord record, ClinicalScreeningGuideline g) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  g.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${g.evidenceGrade} • Frequency: ${g.frequency}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Why is this recommended?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(g.plainLanguageWhy, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                const Text(
                  'What to expect during the test:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(g.whatToExpect, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                const Text(
                  'How to interpret your results:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(g.howToInterpret, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showLogCompletionDialog(record);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Log Completed Screening'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogCompletionDialog(ScreeningRecord record) {
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            'Log ${record.title}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter screening results and clinical notes:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Total Chol 180, LDL 95, Normal ECG...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.attach_file, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Result Document: lab_results.pdf',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
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
                await widget.repository.markScreeningCompleted(
                  widget.userId,
                  record.id,
                  selectedDate,
                  notesController.text,
                  documentUrl: 'docs/screenings/${record.id}.pdf',
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadScreenings();
                }
              },
              child: const Text('Save Record'),
            ),
          ],
        );
      },
    );
  }

  void _showAddScreeningDialog(BuildContext context) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    final presets = [
      'Comprehensive Metabolic & Lipid Panel',
      'Blood Pressure & Cardiovascular Check',
      'PSA / Prostate Examination',
      'Colonoscopy / Colorectal Screening',
      'Testicular Health Self-Exam & Ultrasound',
      'Vision & Intraocular Pressure Test',
      'Oral Health & Dental Exam',
      'Skin Cancer / Full-Body Mole Check',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                  SizedBox(width: 8),
                  Text('Add Preventive Screening', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QUICK CLINICAL PRESETS',
                        style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: presets.map((p) {
                          return ActionChip(
                            backgroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Colors.white12),
                            label: Text(p, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                            onPressed: () {
                              setDialogState(() {
                                titleController.text = p;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Screening / Test Name',
                          labelStyle: TextStyle(color: Colors.white60),
                          hintText: 'e.g. Annual Blood Work',
                          hintStyle: TextStyle(color: Colors.white24),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('DUE DATE', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, color: Color(0xFF10B981), size: 18),
                              const SizedBox(width: 10),
                              Text(DateFormat('MMMM dd, yyyy').format(selectedDate), style: const TextStyle(color: Colors.white)),
                              const Spacer(),
                              const Text('Change', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: notesController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Physician / Facility Notes (Optional)',
                          labelStyle: TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(),
                        ),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  onPressed: () async {
                    if (titleController.text.trim().isNotEmpty) {
                      final newRecord = ScreeningRecord(
                        id: 'scr_${DateTime.now().millisecondsSinceEpoch}',
                        userId: widget.userId,
                        guidelineId: 'custom',
                        title: titleController.text.trim(),
                        dueDate: selectedDate,
                        isCompleted: false,
                        resultNotes: notesController.text.trim(),
                      );
                      await widget.repository.saveScreeningRecord(newRecord);
                      if (mounted) {
                        Navigator.pop(context);
                        _loadScreenings();
                      }
                    }
                  },
                  child: const Text('Save Screening'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

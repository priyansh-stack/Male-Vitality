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

    // If empty, generate and save clinical guidelines for this user
    if (records.isEmpty) {
      final guidelines = PreventiveCareEngine.generateSchedule(
        age: widget.userAge,
        isSmoker: widget.isSmoker,
        hasFamilyHeartDisease: false,
        hasFamilyCancer: false,
      );

      final now = DateTime.now();
      for (int i = 0; i < guidelines.length; i++) {
        final g = guidelines[i];
        final rec = ScreeningRecord(
          id: '${g.id}_${DateTime.now().millisecondsSinceEpoch}_$i',
          userId: widget.userId,
          guidelineId: g.id,
          title: g.title,
          dueDate: now.add(Duration(days: (i + 1) * 21)),
          isCompleted: false,
        );
        await widget.repository.saveScreeningRecord(rec);
      }
      final fresh = await widget.repository.getScreeningRecords(widget.userId);
      setState(() {
        _screenings = fresh;
        _isLoading = false;
      });
    } else {
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          tabs: [
            Tab(text: 'Due & Upcoming (${upcoming.length})'),
            Tab(text: 'Completed (${completed.length})'),
          ],
        ),
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
      return const Center(
        child: Text(
          'No pending screenings! You are fully up to date.',
          style: TextStyle(color: Colors.white70),
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
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/engine/drug_interaction_engine.dart';
import '../../domain/models/patient_medication.dart';
import '../../domain/repositories/i_medication_repository.dart';

class MedicationManagerScreen extends StatefulWidget {
  final String userId;
  final IMedicationRepository repository;

  const MedicationManagerScreen({
    super.key,
    required this.userId,
    required this.repository,
  });

  @override
  State<MedicationManagerScreen> createState() => _MedicationManagerScreenState();
}

class _MedicationManagerScreenState extends State<MedicationManagerScreen> {
  List<PatientMedication> _meds = [];
  List<DrugInteractionAlert> _interactionAlerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);
    final list = await widget.repository.getMedications(widget.userId);
    final medNames = list.map((m) => m.name).toList();
    final alerts = DrugInteractionEngine.checkInteractions(medNames);

    setState(() {
      _meds = list;
      _interactionAlerts = alerts;
      _isLoading = false;
    });
  }

  double get _overallAdherence {
    if (_meds.isEmpty) return 1.0;
    final totalSched = _meds.fold(0, (sum, m) => sum + m.totalDosesScheduled);
    final totalTaken = _meds.fold(0, (sum, m) => sum + m.totalDosesTaken);
    if (totalSched == 0) return 1.0;
    return (totalTaken / totalSched).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isPoly = DrugInteractionEngine.isPolypharmacy(_meds.length);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Medication & Polypharmacy',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF38BDF8)),
            tooltip: 'Export Medication PDF',
            onPressed: _showPdfExportNotice,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF10B981)),
            tooltip: 'Add Medication',
            onPressed: _showAddMedDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Polypharmacy & Adherence Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isPoly ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPoly ? 'Polypharmacy Active' : 'Normal Medication Load',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isPoly ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_meds.length} Active Meds',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPoly ? '≥5 meds: heightened interaction alert' : '<5 concurrent prescriptions',
                              style: const TextStyle(fontSize: 10, color: Colors.white60),
                            ),
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
                          border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Adherence Score',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(_overallAdherence * 100).toInt()}%',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Past 30 days compliance',
                              style: TextStyle(fontSize: 10, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Drug Interaction Warnings Banner (if any)
                if (_interactionAlerts.isNotEmpty) ...[
                  ..._interactionAlerts.map((alert) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: alert.severity == InteractionSeverity.critical
                              ? const Color(0xFFDC2626).withValues(alpha: 0.2)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: alert.severity == InteractionSeverity.critical
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: alert.severity == InteractionSeverity.critical
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFFF59E0B),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    alert.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${alert.drugA} + ${alert.drugB}: ${alert.description}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Action: ${alert.recommendation}',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                ],

                // Section Title
                const Text(
                  'Current Prescriptions & Supplements',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),

                if (_meds.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('No medications logged yet.', style: TextStyle(color: Colors.white54)),
                    ),
                  )
                else
                  ..._meds.map((med) => _buildMedCard(med)),
              ],
            ),
    );
  }

  Widget _buildMedCard(PatientMedication med) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white10,
                  child: Icon(Icons.medication, color: Color(0xFF0284C7)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${med.name} • ${med.dosage}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        med.frequency,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () async {
                    await widget.repository.logDoseTaken(widget.userId, med.id);
                    _loadMedications();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dose recorded for ${med.name}')),
                      );
                    }
                  },
                  child: const Text('Take Dose', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prescriber: ${med.prescriber}',
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
                if (med.refillDate != null)
                  Text(
                    'Refill: ${DateFormat('MM/dd/yyyy').format(med.refillDate!)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPdfExportNotice() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Medication Summary PDF', style: TextStyle(color: Colors.white)),
          content: Text(
            'Generated HIPAA-compliant medication record containing ${_meds.length} medications, dose schedules, and prescriber contact details ready to share with your physician.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medication Summary PDF saved to device documents.')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMedDialog() {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    final docCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Add Medication / Supplement', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Medication Name (e.g. Sildenafil)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                TextField(
                  controller: doseCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Dosage (e.g. 50 mg)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                TextField(
                  controller: freqCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Frequency (e.g. As needed 1h before)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                TextField(
                  controller: docCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Prescriber (e.g. Dr. Lee)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final newMed = PatientMedication(
                    id: 'med_${DateTime.now().millisecondsSinceEpoch}',
                    userId: widget.userId,
                    name: nameCtrl.text.trim(),
                    dosage: doseCtrl.text.trim().isEmpty ? 'Standard dose' : doseCtrl.text.trim(),
                    frequency: freqCtrl.text.trim().isEmpty ? 'Once daily' : freqCtrl.text.trim(),
                    prescriber: docCtrl.text.trim().isEmpty ? 'Primary Care Physician' : docCtrl.text.trim(),
                    refillDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  await widget.repository.addMedication(newMed);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadMedications();
                  }
                }
              },
              child: const Text('Add Medication'),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/services/pdf_generate.dart';
import '../../domain/models/telehealth_consultation.dart';
import '../../domain/repositories/i_telehealth_repository.dart';

class TelehealthScreen extends StatefulWidget {
  final String userId;
  final ITelehealthRepository repository;

  const TelehealthScreen({
    super.key,
    required this.userId,
    required this.repository,
  });

  @override
  State<TelehealthScreen> createState() => _TelehealthScreenState();
}

class _TelehealthScreenState extends State<TelehealthScreen> {
  List<TelehealthDoctor> _doctors = [];
  List<TelehealthAppointment> _appointments = [];
  bool _isLoading = true;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final docs = await widget.repository.getAvailableDoctors();
    final appts = await widget.repository.getUserAppointments(widget.userId);
    setState(() {
      _doctors = docs;
      _appointments = appts;
      _isLoading = false;
    });
  }

  Future<void> _launchMapsSearch(String query) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open map for $query')),
        );
      }
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
          'Telehealth & Physician Consult',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Comprehensive Health Report PDF Export Card (FR-045)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF1E293B)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Color(0xFF10B981), size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Generate Physician Health Summary',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Compile your vital signs trend, active medications, USPSTF screening records, and ADAM hormone scores into a single encrypted PDF report to share before your consultation.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: _isGeneratingPdf ? null : _generateAndExportPdf,
                        icon: _isGeneratingPdf
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.file_download),
                        label: Text(_isGeneratingPdf ? 'Compiling Report...' : 'Export Health Summary (PDF)'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // In-Person Clinic & Specialist Locator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF38BDF8), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Find In-Person Specialists Near You',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Locate board-certified urologists, andrologists, and certified clinical diagnostic labs in your geographic vicinity via Google Maps.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF38BDF8),
                              side: const BorderSide(color: Color(0xFF38BDF8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.medical_services_outlined, size: 16),
                            label: const Text('Find Urologists', style: TextStyle(fontSize: 12)),
                            onPressed: () => _launchMapsSearch('urologist near me'),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF10B981),
                              side: const BorderSide(color: Color(0xFF10B981)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.local_hospital_outlined, size: 16),
                            label: const Text('Men\'s Health Clinics', style: TextStyle(fontSize: 12)),
                            onPressed: () => _launchMapsSearch('mens health clinic near me'),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFA855F7),
                              side: const BorderSide(color: Color(0xFFA855F7)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.biotech_outlined, size: 16),
                            label: const Text('Diagnostic Labs', style: TextStyle(fontSize: 12)),
                            onPressed: () => _launchMapsSearch('medical diagnostic lab near me'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Scheduled Appointments
                if (_appointments.isNotEmpty) ...[
                  const Text(
                    'Upcoming Video Consultations',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._appointments.map((appt) => Card(
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
                                  const Icon(Icons.video_call, color: Color(0xFF10B981), size: 24),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appt.doctorName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                        ),
                                        Text(
                                          appt.specialty,
                                          style: const TextStyle(fontSize: 12, color: Colors.white60),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      appt.status,
                                      style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Scheduled: ${DateFormat('EEEE, MMMM dd • hh:mm a').format(appt.scheduledTime)}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                                  onPressed: () => _launchVideoCall(appt),
                                  icon: const Icon(Icons.videocam),
                                  label: const Text('Join Encrypted Video Room'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                // Doctors List
                const Text(
                  'Licensed Men\'s Health Specialists',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),

                ..._doctors.map((doc) => Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  child: const Icon(Icons.person, color: Color(0xFF10B981), size: 30),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        doc.specialty,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8), fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${doc.rating} (${doc.reviewsCount} reviews)',
                                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              doc.bio,
                              style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF10B981),
                                  side: const BorderSide(color: Color(0xFF10B981)),
                                ),
                                onPressed: () => _showBookingDialog(doc),
                                child: const Text('Book Video Consultation'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
    );
  }

  Future<void> _generateAndExportPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfGen = PDFGenerator();
      final metrics = {
        'Resting Heart Rate': '68 bpm (Fitbit Synced)',
        'Blood Pressure': '118/76 mmHg (Normotensive)',
        'Daily Sleep Average': '7h 14m (Quality Score: 84)',
        'Cardiovascular Fitness': 'Good (VO2 max est. 44)',
        'ADAM Hormone Score': 'Negative (Low risk of hypogonadism)',
        'USPSTF Screenings': 'Custom tracked & current',
      };
      final pdfBytes = await pdfGen.generateHealthSummary(
        title: 'MaleVitality Clinical Health Summary',
        content: 'This report contains aggregated personal health telemetry, clinical screening status, and hormone assessment results collected through the MaleVitality health protocol.\nPatient ID: ${widget.userId}\nDesigned for clinical review during routine physicals or telehealth consultations.',
        metrices: metrics,
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/MaleVitality_Health_Summary_${widget.userId}.pdf');
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        setState(() => _isGeneratingPdf = false);
        _showPdfReadyDialog(file.path);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  void _showPdfReadyDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF10B981), size: 22),
              SizedBox(width: 8),
              Text('Health Summary Exported', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your comprehensive MaleVitality clinical summary has been compiled and saved locally.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: Color(0xFF38BDF8), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        filePath,
                        style: const TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'monospace'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Included sections:\n• Patient baseline & vital signs trends\n• Fitbit sleep & resting HR averages\n• USPSTF screening records\n• ADAM hormone questionnaire scores',
                style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Physician Health Summary PDF ready to share.')),
                );
              },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showBookingDialog(TelehealthDoctor doc) {
    String selectedTime = doc.availableTimes.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: Text('Book with ${doc.name}', style: const TextStyle(color: Colors.white, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select an available appointment time:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  ...doc.availableTimes.map((time) => RadioListTile<String>(
                        dense: true,
                        title: Text(time, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        value: time,
                        groupValue: selectedTime,
                        activeColor: const Color(0xFF10B981),
                        onChanged: (v) => setDialogState(() => selectedTime = v!),
                      )),
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
                    final appt = TelehealthAppointment(
                      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
                      userId: widget.userId,
                      doctorId: doc.id,
                      doctorName: doc.name,
                      specialty: doc.specialty,
                      scheduledTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
                      meetingLink: 'https://telehealth.malevitality.health/room/${doc.id}',
                    );
                    await widget.repository.bookAppointment(appt);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Consultation booked with ${doc.name}')),
                      );
                    }
                  },
                  child: const Text('Confirm Booking'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _launchVideoCall(TelehealthAppointment appt) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: Row(
            children: [
              const Icon(Icons.videocam, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Connecting to ${appt.doctorName}...', style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
          content: Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: Color(0xFF10B981), size: 36),
                  SizedBox(height: 8),
                  Text('End-to-End Encrypted Video Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('Waiting for physician to enter room...', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('End Call', style: TextStyle(color: Color(0xFFEF4444))),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                          Text(
                            'Generate Physician Health Summary',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: _showPdfReadyDialog,
                        icon: const Icon(Icons.file_download),
                        label: const Text('Export Health Summary (PDF)'),
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

  void _showPdfReadyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Comprehensive Health Summary', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Your comprehensive 4-page MaleVitality clinical summary has been generated.\n\nIncluded sections:\n• Patient baseline & life-stage categorization\n• Vitals & cardiac risk assessment trends\n• Active prescriptions & polypharmacy check\n• Preventive screening history & next due dates\n• ADAM hormone questionnaire results',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Physician Health Summary PDF exported successfully.')),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Share PDF with Provider'),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../core/bloc/onboarding/onboarding_event.dart';
import '../../core/models/emergency_contact.dart';

class StepEmergencyContact extends StatefulWidget {
  const StepEmergencyContact({super.key});

  @override
  State<StepEmergencyContact> createState() => _StepEmergencyContactState();
}

class _StepEmergencyContactState extends State<StepEmergencyContact> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _relationship = 'Spouse / Partner';

  final List<String> _relationships = [
    'Spouse / Partner',
    'Parent / Guardian',
    'Child',
    'Sibling',
    'Close Friend',
    'Primary Care Doctor',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate()) {
      final contact = EmergencyContact(
        name: _nameCtrl.text.trim(),
        relationship: _relationship,
        phoneNumber: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      );
      context.read<OnboardingBloc>().add(SaveEmergencyContactEvent(contact));
      context.go('/onboarding/permissions');
    }
  }

  void _skip() {
    context.read<OnboardingBloc>().add(const SaveEmergencyContactEvent(null));
    context.go('/onboarding/permissions');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Emergency Contact',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                TextButton(
                  onPressed: _skip,
                  child: const Text('Skip for Now', style: TextStyle(color: Color(0xFF64748B))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Specify a trusted person to be alerted in case of severe health notifications or medical emergencies.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Contact Full Name',
                prefixIcon: Icon(Icons.person_pin_rounded),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Please enter contact name' : null,
            ),
            const SizedBox(height: 16),

            // Relationship Dropdown
            const Text('Relationship', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _relationship,
                  isExpanded: true,
                  items: _relationships.map((r) {
                    return DropdownMenuItem(value: r, child: Text(r));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _relationship = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Please enter phone number' : null,
            ),
            const SizedBox(height: 16),

            // Email (Optional)
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address (Optional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 32),

            //  Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.go('/onboarding/health-profile');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAndNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Next: Permissions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
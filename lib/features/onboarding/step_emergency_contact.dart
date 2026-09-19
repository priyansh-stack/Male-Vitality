import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../core/bloc/onboarding/onboarding_event.dart';
import '../../core/models/emergency_contact.dart';
import '../../core/theme/app_theme.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.darkCanvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Skip Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cyberCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.cyberCyan.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'STAGE 03 // CRISIS SENTINEL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.cyberCyan,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'SKIP FOR NOW',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text(
                'Emergency Sentinel Contact',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Designate a trusted individual for critical health alerts and emergency automated triage.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),

              // 988 Crisis Reassurance Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.neonRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.neonRed.withValues(alpha: 0.35)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppTheme.neonRed, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Direct integration with the 988 Suicide & Crisis Lifeline is always accessible 24/7 via the HUD navigation dock.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contact Name
              const Text(
                'CONTACT FULL NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'e.g., Sarah Connor',
                  prefixIcon: Icon(Icons.person_pin_rounded, color: AppTheme.cyberCyan),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter contact name' : null,
              ),
              const SizedBox(height: 20),

              // Relationship Dropdown
              const Text(
                'RELATIONSHIP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _relationship,
                    isExpanded: true,
                    dropdownColor: AppTheme.darkSurface,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textTertiary),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    items: _relationships.map((r) {
                      return DropdownMenuItem(value: r, child: Text(r));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _relationship = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number
              const Text(
                'DIRECT PHONE NUMBER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: '+1 (555) 000-0000',
                  prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.cyberCyan),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a valid phone number' : null,
              ),
              const SizedBox(height: 20),

              // Email
              const Text(
                'EMAIL ADDRESS (OPTIONAL)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'contact@example.com',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.cyberCyan),
                ),
              ),
              const SizedBox(height: 36),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/onboarding/health-profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.darkBorder),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('PREVIOUS', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveAndNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyberCyan,
                        foregroundColor: const Color(0xFF080C14),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NEXT: AUTHORIZATION',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
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
}
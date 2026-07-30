import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../core/bloc/onboarding/onboarding_event.dart';

class StepPersonalInfo extends StatefulWidget {
  const StepPersonalInfo({super.key});

  @override
  State<StepPersonalInfo> createState() => _StepPersonalInfoState();
}

class _StepPersonalInfoState extends State<StepPersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  final List<String> _genders = ['Male', 'Non-Binary', 'Prefer Not to Say'];

  @override
  void initState() {
    super.initState();
    final state = context.read<OnboardingBloc>().state;
    _nameController = TextEditingController(text: state.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final state = context.read<OnboardingBloc>().state;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.dateOfBirth,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4F46E5)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      context.read<OnboardingBloc>().add(
        UpdatePersonalInfoEvent(
          name: _nameController.text,
          dob: picked,
          gender: state.gender,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingBloc>().state;
    final lifeStage = state.detectedLifeStage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'We use your date of birth to automatically calculate your life-stage health requirements.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              onChanged: (val) {
                context.read<OnboardingBloc>().add(
                  UpdatePersonalInfoEvent(
                    name: val,
                    dob: state.dateOfBirth,
                    gender: state.gender,
                  ),
                );
              },
              validator: (v) => v == null || v.isEmpty ? 'Please enter a display name' : null,
            ),
            const SizedBox(height: 20),

            // Date of Birth
            const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 14),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(state.dateOfBirth),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_calendar_rounded, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Life Stage Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: lifeStage.badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: lifeStage.badgeColor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lifeStage.badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(lifeStage.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Detected Stage: ',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              '${lifeStage.name} (${lifeStage.ageRange})',
                              style: TextStyle(
                                color: lifeStage.badgeColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lifeStage.description,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Gender Options
            const Text('Gender Identity', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _genders.map((g) {
                final isSelected = state.gender == g;
                return ChoiceChip(
                  label: Text(g),
                  selected: isSelected,
                  selectedColor: const Color(0xFF4F46E5),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      context.read<OnboardingBloc>().add(
                        UpdatePersonalInfoEvent(
                          name: _nameController.text,
                          dob: state.dateOfBirth,
                          gender: g,
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Next Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.go('/onboarding/health-profile');
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Next: Health Profile'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
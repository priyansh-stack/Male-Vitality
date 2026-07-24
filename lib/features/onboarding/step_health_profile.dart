import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../core/bloc/onboarding/onboarding_event.dart';
import '../../core/bloc/onboarding/onboarding_state.dart';
import '../../core/models/lifestyle_factors.dart';
import '../../core/models/medication.dart';

class StepHealthProfile extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StepHealthProfile({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StepHealthProfile> createState() => _StepHealthProfileState();
}

class _StepHealthProfileState extends State<StepHealthProfile> {
  final List<String> _availableConditions = [
    'None',
    'Hypertension',
    'Asthma',
    'Diabetes Type 2',
    'High Cholesterol',
    'Thyroid Disorder',
    'Migraine',
    'Arthritis',
  ];

  void _showAddMedicationDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final freqCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Current Medication'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Medication Name (e.g., Lisinopril)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageCtrl,
                decoration: const InputDecoration(labelText: 'Dosage (e.g., 10mg)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: freqCtrl,
                decoration: const InputDecoration(labelText: 'Frequency (e.g., Once daily)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  context.read<OnboardingBloc>().add(
                        AddMedicationEvent(
                          Medication(
                            name: nameCtrl.text.trim(),
                            dosage: dosageCtrl.text.trim(),
                            frequency: freqCtrl.text.trim(),
                          ),
                        ),
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final lifestyle = state.lifestyle;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Health & Lifestyle Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share any existing conditions, active medications, and general lifestyle habits.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),

              // Health Conditions
              const Text('Pre-existing Health Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableConditions.map((cond) {
                  final isSelected = state.selectedConditions.contains(cond);
                  return FilterChip(
                    label: Text(cond),
                    selected: isSelected,
                    selectedColor: const Color(0xFF4F46E5).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF4F46E5),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF334155),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    onSelected: (_) {
                      context.read<OnboardingBloc>().add(ToggleHealthConditionEvent(cond));
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Active Medications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Medications', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => _showAddMedicationDialog(context),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: const Text('Add Medication'),
                  ),
                ],
              ),
              if (state.medications.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF64748B), size: 20),
                      SizedBox(width: 12),
                      Text('No medications added yet.', style: TextStyle(color: Color(0xFF64748B))),
                    ],
                  ),
                )
              else
                Column(
                  children: state.medications.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final med = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEEF2FF),
                          child: Icon(Icons.medication_rounded, color: Color(0xFF4F46E5)),
                        ),
                        title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${med.dosage} • ${med.frequency}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            context.read<OnboardingBloc>().add(RemoveMedicationEvent(idx));
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 28),

              // Lifestyle Factors
              const Text('Lifestyle Factors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Stress Level Slider
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Perceived Stress Level (1 - 10)', style: TextStyle(fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStressColor(lifestyle.stressLevel).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${lifestyle.stressLevel}/10 (${_getStressLabel(lifestyle.stressLevel)})',
                              style: TextStyle(
                                color: _getStressColor(lifestyle.stressLevel),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: lifestyle.stressLevel.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: const Color(0xFF4F46E5),
                        onChanged: (val) {
                          context.read<OnboardingBloc>().add(
                                UpdateLifestyleFactorsEvent(
                                  LifestyleFactors(
                                    smoking: lifestyle.smoking,
                                    alcohol: lifestyle.alcohol,
                                    exercise: lifestyle.exercise,
                                    sleep: lifestyle.sleep,
                                    diet: lifestyle.diet,
                                    stressLevel: val.round(),
                                  ),
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Exercise Level Dropdown
              _buildDropdownTile<ExerciseLevel>(
                label: 'Exercise Frequency',
                icon: Icons.directions_run_rounded,
                value: lifestyle.exercise,
                items: ExerciseLevel.values,
                itemLabel: (e) => e.label,
                onChanged: (val) {
                  if (val != null) {
                    context.read<OnboardingBloc>().add(
                          UpdateLifestyleFactorsEvent(
                            LifestyleFactors(
                              smoking: lifestyle.smoking,
                              alcohol: lifestyle.alcohol,
                              exercise: val,
                              sleep: lifestyle.sleep,
                              diet: lifestyle.diet,
                              stressLevel: lifestyle.stressLevel,
                            ),
                          ),
                        );
                  }
                },
              ),
              const SizedBox(height: 12),

              // Sleep Quality Dropdown
              _buildDropdownTile<SleepQuality>(
                label: 'Sleep Quality',
                icon: Icons.bedtime_rounded,
                value: lifestyle.sleep,
                items: SleepQuality.values,
                itemLabel: (s) => s.label,
                onChanged: (val) {
                  if (val != null) {
                    context.read<OnboardingBloc>().add(
                          UpdateLifestyleFactorsEvent(
                            LifestyleFactors(
                              smoking: lifestyle.smoking,
                              alcohol: lifestyle.alcohol,
                              exercise: lifestyle.exercise,
                              sleep: val,
                              diet: lifestyle.diet,
                              stressLevel: lifestyle.stressLevel,
                            ),
                          ),
                        );
                  }
                },
              ),
              const SizedBox(height: 32),

              // Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
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
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Next: Emergency'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdownTile<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0D9488)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: items.map((item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Text(itemLabel(item), style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStressColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 7) return Colors.amber.shade700;
    return Colors.redAccent;
  }

  String _getStressLabel(int level) {
    if (level <= 3) return 'Low Stress';
    if (level <= 7) return 'Moderate';
    return 'High Stress';
  }
}

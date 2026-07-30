import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../core/bloc/onboarding/onboarding_event.dart';
import '../../core/bloc/onboarding/onboarding_state.dart';
import '../../core/models/lifestyle_factors.dart';
import '../../core/models/medication.dart';
import '../../core/theme/app_theme.dart';

class StepHealthProfile extends StatefulWidget {
  const StepHealthProfile({super.key});

  @override
  State<StepHealthProfile> createState() => _StepHealthProfileState();
}

class _StepHealthProfileState extends State<StepHealthProfile> {
  final List<String> _availableConditions = [
    'None', 'Hypertension', 'Asthma', 'Diabetes Type 2', 
    'High Cholesterol', 'Thyroid Disorder', 'Migraine', 'Arthritis',
  ];

  // (Keep _showAddMedicationDialog identical logic, just update styling internally if desired)
  void _showAddMedicationDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text('Add Medication', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g., Lisinopril)')),
            const SizedBox(height: 12),
            TextField(controller: dosageCtrl, decoration: const InputDecoration(labelText: 'Dosage (e.g., 10mg)')),
            const SizedBox(height: 12),
            TextField(controller: freqCtrl, decoration: const InputDecoration(labelText: 'Frequency')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                context.read<OnboardingBloc>().add(AddMedicationEvent(Medication(name: nameCtrl.text.trim(), dosage: dosageCtrl.text.trim(), frequency: freqCtrl.text.trim())));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
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
              const Text('Health & Lifestyle', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              const Text('Help us tailor your vitality insights by sharing your current habits and baseline.', style: TextStyle(fontSize: 15, color: AppTheme.textMedium, height: 1.4)),
              const SizedBox(height: 32),

              const Text('Pre-existing Conditions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableConditions.map((cond) {
                  final isSelected = state.selectedConditions.contains(cond);
                  return FilterChip(
                    label: Text(cond),
                    selected: isSelected,
                    showCheckmark: false,
                    backgroundColor: AppTheme.surfaceWhite,
                    selectedColor: AppTheme.primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderLight),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textMedium,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    onSelected: (_) => context.read<OnboardingBloc>().add(ToggleHealthConditionEvent(cond)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Medications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton.icon(
                    onPressed: () => _showAddMedicationDialog(context),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.primaryTeal),
                  ),
                ],
              ),
              if (state.medications.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.textMuted, size: 20),
                      SizedBox(width: 12),
                      Text('No medications tracking active.', style: TextStyle(color: AppTheme.textMedium)),
                    ],
                  ),
                )
              else
                Column(
                  children: state.medications.asMap().entries.map((entry) {
                    final med = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderLight),
                        borderRadius: BorderRadius.circular(16),
                        color: AppTheme.surfaceWhite,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppTheme.accentEmerald.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.medication, color: AppTheme.accentEmerald, size: 20),
                        ),
                        title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        subtitle: Text('${med.dosage} • ${med.frequency}', style: const TextStyle(color: AppTheme.textMedium)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.dangerRed),
                          onPressed: () => context.read<OnboardingBloc>().add(RemoveMedicationEvent(entry.key)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),

              const Text('Lifestyle Factors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Stress Slider Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderLight),
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.surfaceWhite,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Stress Level (1-10)', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                        Text('${lifestyle.stressLevel}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primaryTeal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppTheme.primaryTeal,
                        inactiveTrackColor: AppTheme.surfaceSubtle,
                        thumbColor: AppTheme.primaryTeal,
                        overlayColor: AppTheme.primaryTeal.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: lifestyle.stressLevel.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (val) {
                          context.read<OnboardingBloc>().add(UpdateLifestyleFactorsEvent(
                            LifestyleFactors(smoking: lifestyle.smoking, alcohol: lifestyle.alcohol, exercise: lifestyle.exercise, sleep: lifestyle.sleep, diet: lifestyle.diet, stressLevel: val.round())
                          ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              _buildDropdownContainer<ExerciseLevel>(
                label: 'Exercise Frequency',
                icon: Icons.directions_run_rounded,
                value: lifestyle.exercise,
                items: ExerciseLevel.values,
                itemLabel: (e) => e.label,
                onChanged: (val) {
                  if (val != null) {
                    context.read<OnboardingBloc>().add(UpdateLifestyleFactorsEvent(
                      LifestyleFactors(smoking: lifestyle.smoking, alcohol: lifestyle.alcohol, exercise: val, sleep: lifestyle.sleep, diet: lifestyle.diet, stressLevel: lifestyle.stressLevel)
                    ));
                  }
                },
              ),
              const SizedBox(height: 16),
              
              _buildDropdownContainer<SleepQuality>(
                label: 'Sleep Quality',
                icon: Icons.bedtime_rounded,
                value: lifestyle.sleep,
                items: SleepQuality.values,
                itemLabel: (s) => s.label,
                onChanged: (val) {
                  if (val != null) {
                    context.read<OnboardingBloc>().add(UpdateLifestyleFactorsEvent(
                      LifestyleFactors(smoking: lifestyle.smoking, alcohol: lifestyle.alcohol, exercise: lifestyle.exercise, sleep: val, diet: lifestyle.diet, stressLevel: lifestyle.stressLevel)
                    ));
                  }
                },
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/onboarding/personal-info'),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go('/onboarding/emergency-contact'),
                      child: const Text('Next Step'),
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

  Widget _buildDropdownContainer<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryTeal, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textMuted),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  items: items.map((item) => DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)))).toList(),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
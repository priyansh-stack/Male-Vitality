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

  void _showAddMedicationDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.darkBorder),
        ),
        title: const Text(
          'RECORD MEDICATION PROTOCOL',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: AppTheme.cyberCyan,
            letterSpacing: 0.8,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Name (e.g., Lisinopril, Tadalafil)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dosageCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Dosage (e.g., 10mg, 5mg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: freqCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Frequency (e.g., Once daily, PRN)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                context.read<OnboardingBloc>().add(AddMedicationEvent(
                  Medication(
                    name: nameCtrl.text.trim(),
                    dosage: dosageCtrl.text.trim(),
                    frequency: freqCtrl.text.trim(),
                  ),
                ));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyberCyan,
              foregroundColor: const Color(0xFF080C14),
            ),
            child: const Text('ADD TO REGIMEN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
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

        return Scaffold(
          backgroundColor: AppTheme.darkCanvas,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.cyberCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.cyberCyan.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        'STAGE 02 // CLINICAL BASELINE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.cyberCyan,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Text(
                  'Health & Clinical Profile',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Log pre-existing conditions and lifestyle factors to initialize drug-interaction safeguards and preventive alerts.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 28),

                // Pre-existing conditions
                const Text(
                  'CHRONIC & PRE-EXISTING CONDITIONS',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableConditions.map((cond) {
                    final isSelected = state.selectedConditions.contains(cond);
                    return InkWell(
                      onTap: () => context.read<OnboardingBloc>().add(ToggleHealthConditionEvent(cond)),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.cyberCyan.withValues(alpha: 0.18)
                              : AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppTheme.cyberCyan : AppTheme.darkBorder,
                            width: isSelected ? 1.4 : 1,
                          ),
                        ),
                        child: Text(
                          cond,
                          style: TextStyle(
                            color: isSelected ? AppTheme.cyberCyan : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Active Medications Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ACTIVE MEDICATIONS & SUPPLEMENTS',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddMedicationDialog(context),
                      icon: const Icon(Icons.add_circle_outline, size: 16, color: AppTheme.cyberCyan),
                      label: const Text(
                        'ADD',
                        style: TextStyle(
                          color: AppTheme.cyberCyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (state.medications.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppTheme.bioEmerald, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No active medications reported. Polypharmacy risk: None.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ),
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
                          border: Border.all(color: AppTheme.darkBorder),
                          borderRadius: BorderRadius.circular(16),
                          color: AppTheme.darkCard,
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.bioEmerald.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.medication, color: AppTheme.bioEmerald, size: 20),
                          ),
                          title: Text(
                            med.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${med.dosage} • ${med.frequency}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppTheme.neonRed, size: 20),
                            onPressed: () => context.read<OnboardingBloc>().add(RemoveMedicationEvent(entry.key)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 28),

                // Lifestyle Factors
                const Text(
                  'LIFESTYLE & RECOVERY BIOMETRICS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 14),
                
                // Stress Level Slider Container
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.darkBorder),
                    borderRadius: BorderRadius.circular(16),
                    color: AppTheme.darkCard,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Perceived Stress Baseline (1 - 10)',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 13),
                          ),
                          Text(
                            '${lifestyle.stressLevel} / 10',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppTheme.cyberCyan,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppTheme.cyberCyan,
                          inactiveTrackColor: const Color(0xFF1E2D4A),
                          thumbColor: AppTheme.cyberCyan,
                          overlayColor: AppTheme.cyberCyan.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: lifestyle.stressLevel.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (val) {
                            context.read<OnboardingBloc>().add(UpdateLifestyleFactorsEvent(
                              LifestyleFactors(
                                smoking: lifestyle.smoking,
                                alcohol: lifestyle.alcohol,
                                exercise: lifestyle.exercise,
                                sleep: lifestyle.sleep,
                                diet: lifestyle.diet,
                                stressLevel: val.round(),
                              ),
                            ));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                
                _buildDropdownContainer<ExerciseLevel>(
                  label: 'Exercise Frequency',
                  icon: Icons.directions_run_rounded,
                  value: lifestyle.exercise,
                  items: ExerciseLevel.values,
                  itemLabel: (e) => e.label,
                  onChanged: (val) {
                    if (val != null) {
                      context.read<OnboardingBloc>().add(UpdateLifestyleFactorsEvent(
                        LifestyleFactors(
                          smoking: lifestyle.smoking,
                          alcohol: lifestyle.alcohol,
                          exercise: val,
                          sleep: lifestyle.sleep,
                          diet: lifestyle.diet,
                          stressLevel: lifestyle.stressLevel,
                        ),
                      ));
                    }
                  },
                ),
                const SizedBox(height: 14),
                
                _buildDropdownContainer<SleepQuality>(
                  label: 'Sleep Quality',
                  icon: Icons.bedtime_rounded,
                  value: lifestyle.sleep,
                  items: SleepQuality.values,
                  itemLabel: (s) => s.label,
                  onChanged: (val) {
                    if (val != null) {
                      context.read<OnboardingBloc>().add(UpdateLifestyleFactorsEvent(
                        LifestyleFactors(
                          smoking: lifestyle.smoking,
                          alcohol: lifestyle.alcohol,
                          exercise: lifestyle.exercise,
                          sleep: val,
                          diet: lifestyle.diet,
                          stressLevel: lifestyle.stressLevel,
                        ),
                      ));
                    }
                  },
                ),
                const SizedBox(height: 36),

                // Back / Next Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go('/onboarding/personal-info'),
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
                        onPressed: () => context.go('/onboarding/emergency-contact'),
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
                              'NEXT: SENTINEL CONTACT',
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
        color: AppTheme.darkCard,
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.cyberCyan, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary, fontWeight: FontWeight.w600),
                ),
                DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: AppTheme.darkSurface,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textTertiary),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
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
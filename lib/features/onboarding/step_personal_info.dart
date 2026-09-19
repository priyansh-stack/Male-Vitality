import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/bloc/auth/auth_bloc.dart';
import '../../core/bloc/auth/auth_state.dart';
import '../../core/services/auth_service.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../core/bloc/onboarding/onboarding_event.dart';
import '../../core/engine/life_stage_adaptive_rules.dart';
import '../../core/theme/app_theme.dart';

class StepPersonalInfo extends StatefulWidget {
  const StepPersonalInfo({super.key});

  @override
  State<StepPersonalInfo> createState() => _StepPersonalInfoState();
}

class _StepPersonalInfoState extends State<StepPersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isGoogleDob = false;

  final List<String> _genders = ['Male', 'Non-Binary', 'Prefer Not to Say'];

  @override
  void initState() {
    super.initState();
    final onboardingState = context.read<OnboardingBloc>().state;
    _nameController = TextEditingController(text: onboardingState.displayName);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      String? googleName;
      String? email;
      DateTime? googleDob;
      String? googleGender;
      if (authState is Authenticated) {
        googleName = authState.user.displayName;
        email = authState.user.email;
        googleDob = authState.user.dateOfBirth;
        googleGender = authState.user.gender;
      }

      if (googleDob != null) {
        setState(() {
          _isGoogleDob = true;
        });
      }
      
      final currentText = _nameController.text.trim();
      final resolvedName = (currentText.isNotEmpty && currentText != 'Member' && currentText != 'User')
          ? currentText
          : AuthService.extractCleanName(googleName, email);

      if (_nameController.text != resolvedName) {
        _nameController.text = resolvedName;
      }

      // Prioritize official Google Account DOB if available; otherwise use current onboarding state or default baseline
      final resolvedDob = googleDob ?? (onboardingState.dateOfBirth.year == 1998 ? AuthService.defaultBaselineDob : onboardingState.dateOfBirth);

      // Prioritize official Google Gender if available; otherwise maintain selection or default Male
      final resolvedGender = (onboardingState.gender.isNotEmpty && onboardingState.gender != 'Male')
          ? onboardingState.gender
          : (googleGender ?? 'Male');

      context.read<OnboardingBloc>().add(
        UpdatePersonalInfoEvent(
          name: resolvedName,
          dob: resolvedDob,
          gender: resolvedGender,
        ),
      );
    });
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
      firstDate: DateTime(1925),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.cyberCyan,
              onPrimary: Color(0xFF080C14),
              surface: AppTheme.darkCard,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.darkSurface,
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
    final activeModules = LifeStageAdaptiveRules.getModulesForStage(lifeStage);
    final focusHeadline = LifeStageAdaptiveRules.getLifeStageFocusHeadline(lifeStage);

    return Scaffold(
      backgroundColor: AppTheme.darkCanvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HUD Header Badge
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
                      'STAGE 01 // CALIBRATION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.cyberCyan,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'AGE: ${DateTime.now().year - state.dateOfBirth.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.bioEmerald,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text(
                'Biometric Identity',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your parameters to initialize clinical life-stage protocols and personalized biomarker tracking.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              // Display Name Field
              Row(
                children: [
                  const Text(
                    'FULL NAME / CALLSIGN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textTertiary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.cyberCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.cyberCyan.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, color: AppTheme.cyberCyan, size: 10),
                        SizedBox(width: 4),
                        Text(
                          'PRE-FILLED FROM GOOGLE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.cyberCyan,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Enter your preferred name',
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.cyberCyan),
                  filled: true,
                  fillColor: AppTheme.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.darkBorder),
                  ),
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
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 20),

              // Date of Birth Selector
              Row(
                children: [
                  const Text(
                    'DATE OF BIRTH',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textTertiary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.neonEmerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'AGE: ${state.age} YRS',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.neonEmerald,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppTheme.cyberCyan, size: 20),
                      const SizedBox(width: 14),
                      Text(
                        '${DateFormat('MMMM dd, yyyy').format(state.dateOfBirth)} (${state.age} yrs)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (_isGoogleDob ? AppTheme.neonEmerald : AppTheme.cyberCyan).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: (_isGoogleDob ? AppTheme.neonEmerald : AppTheme.cyberCyan).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          _isGoogleDob ? 'GOOGLE ACCOUNT' : 'TAP TO EDIT DOB',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: _isGoogleDob ? AppTheme.neonEmerald : AppTheme.cyberCyan,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_calendar_rounded, color: AppTheme.textTertiary, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Live Life-Stage Holographic Scanner Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      lifeStage.badgeColor.withValues(alpha: 0.2),
                      AppTheme.darkCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: lifeStage.badgeColor.withValues(alpha: 0.55),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: lifeStage.badgeColor.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: lifeStage.badgeColor.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(color: lifeStage.badgeColor),
                          ),
                          child: Icon(lifeStage.icon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'CALIBRATED: ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white70,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Text(
                                    lifeStage.name.toUpperCase(),
                                    style: TextStyle(
                                      color: lifeStage.badgeColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${lifeStage.ageRange} • $focusHeadline',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFF1E2D4A), height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 14, color: AppTheme.cyberCyan),
                        const SizedBox(width: 6),
                        Text(
                          '${activeModules.length} Active Clinical Modules Initialized',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cyberCyan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Gender Identity
              const Text(
                'GENDER IDENTITY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _genders.map((g) {
                  final isSelected = state.gender == g;
                  return InkWell(
                    onTap: () {
                      context.read<OnboardingBloc>().add(
                        UpdatePersonalInfoEvent(
                          name: _nameController.text,
                          dob: state.dateOfBirth,
                          gender: g,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.cyberCyan.withValues(alpha: 0.2)
                            : AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.cyberCyan : AppTheme.darkBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        g,
                        style: TextStyle(
                          color: isSelected ? AppTheme.cyberCyan : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              // Next CTA Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.go('/onboarding/health-profile');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cyberCyan,
                    foregroundColor: const Color(0xFF080C14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CONTINUE TO CLINICAL PROFILE',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.8),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
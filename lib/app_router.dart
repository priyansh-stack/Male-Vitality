
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_bloc.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_event.dart';
import 'package:life_stage_health_app/core/bloc/auth/auth_state.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_bloc.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_event.dart';
import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_state.dart';
import 'package:life_stage_health_app/features/auth/auth_screen.dart';
import 'package:life_stage_health_app/features/dashboard/main_dashboard.dart';
import 'package:life_stage_health_app/features/onboarding/life_stage_welcome_screen.dart';
import 'package:life_stage_health_app/features/onboarding/step_emergency_contact.dart';
import 'package:life_stage_health_app/features/onboarding/step_health_profile.dart';
import 'package:life_stage_health_app/features/onboarding/step_permissions.dart';
import 'package:life_stage_health_app/features/onboarding/step_personal_info.dart';
import 'package:life_stage_health_app/features/welcome/welcome_screen.dart';

class AppRootRouter extends StatelessWidget {
  const AppRootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthInitial || authState is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
          );
        }

        if (authState is Unauthenticated) {
          return BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, onboardingState) {
              if (onboardingState.step == 0) {
                return WelcomeScreen(
                  onGetStarted: () {
                    context.read<OnboardingBloc>().add(const OnboardingStepChanged(1));
                  },
                );
              }
              return AuthScreen(
                onAuthenticated: () {
                  context.read<AuthBloc>().add(AuthCheckRequested());
                },
              );
            },
          );
        }

        if (authState is Authenticated) {
          return BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, onboardingState) {
              final step = onboardingState.step;

              // Step 0 or 1: Personal Info
              if (step <= 1) {
                return Scaffold(
                  appBar: _buildOnboardingProgressAppBar(context, step: 1, title: 'Step 1 of 4: Personal Info'),
                  body: StepPersonalInfo(
                    onNext: () {
                      context.read<OnboardingBloc>().add(const OnboardingStepChanged(2));
                    },
                  ),
                );
              }

              // Step 2: Health & Lifestyle Profile
              if (step == 2) {
                return Scaffold(
                  appBar: _buildOnboardingProgressAppBar(context, step: 2, title: 'Step 2 of 4: Health Profile'),
                  body: StepHealthProfile(
                    onNext: () {
                      context.read<OnboardingBloc>().add(const OnboardingStepChanged(3));
                    },
                    onBack: () {
                      context.read<OnboardingBloc>().add(const OnboardingStepChanged(1));
                    },
                  ),
                );
              }

              // Step 3: Emergency Contact
              if (step == 3) {
                return Scaffold(
                  appBar: _buildOnboardingProgressAppBar(context, step: 3, title: 'Step 3 of 4: Emergency Contact'),
                  body: StepEmergencyContact(
                    onNext: () {
                      context.read<OnboardingBloc>().add(const OnboardingStepChanged(4));
                    },
                    onBack: () {
                      context.read<OnboardingBloc>().add(const OnboardingStepChanged(2));
                    },
                  ),
                );
              }

              // Step 4: Permissions & Integrations
              if (step == 4) {
                return Scaffold(
                  appBar: _buildOnboardingProgressAppBar(context, step: 4, title: 'Step 4 of 4: Permissions'),
                  body: StepPermissions(
                    onBack: () {
                      context.read<OnboardingBloc>().add(const OnboardingStepChanged(3));
                    },
                  ),
                );
              }

              // Step 5: Life-Stage Welcome Reveal
              if (step == 5) {
                return LifeStageWelcomeScreen(
                  onProceedToDashboard: () {
                    context.read<OnboardingBloc>().add(const OnboardingStepChanged(6));
                  },
                );
              }

              // Main Dashboard
              return const MainDashboard();
            },
          );
        }

        return const Scaffold(
          body: Center(child: Text('Unexpected Authentication State')),
        );
      },
    );
  }

  PreferredSizeWidget _buildOnboardingProgressAppBar(BuildContext context, {required int step, required String title}) {
    final double progress = step / 4.0;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(6),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFFE2E8F0),
          color: const Color(0xFF4F46E5),
          minHeight: 4,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../core/bloc/onboarding/onboarding_state.dart';
import '../../core/theme/app_theme.dart';

class LifeStageWelcomeScreen extends StatelessWidget {
  const LifeStageWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final profile = state.completedProfile;
        final lifeStage = state.detectedLifeStage;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  lifeStage.badgeColor.withOpacity(0.8),
                  AppTheme.primarySlate,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: Icon(lifeStage.icon, size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '${lifeStage.name.toUpperCase()} STAGE (${lifeStage.ageRange})',
                        style: TextStyle(color: lifeStage.badgeColor, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome, ${profile?.displayName ?? state.displayName}!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lifeStage.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 40),
                    
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Profile Created Successfully', style: TextStyle(color: AppTheme.accentEmerald, fontWeight: FontWeight.bold, fontSize: 16)),
                            const Divider(color: Colors.white24, height: 32),
                            _buildSummaryRow(Icons.health_and_safety, 'Conditions', state.selectedConditions.isEmpty ? 'None' : '${state.selectedConditions.length} Tracked'),
                            const SizedBox(height: 16),
                            _buildSummaryRow(Icons.medication, 'Medications', '${state.medications.length} Active'),
                            const SizedBox(height: 16),
                            _buildSummaryRow(Icons.psychology, 'Stress Level', '${state.lifestyle.stressLevel}/10'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => context.go('/dashboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentEmerald,
                          foregroundColor: AppTheme.primarySlate,
                        ),
                        child: const Text('Enter Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../core/bloc/onboarding/onboarding_state.dart';

class LifeStageWelcomeScreen extends StatelessWidget {
  final VoidCallback onProceedToDashboard;

  const LifeStageWelcomeScreen({
    super.key,
    required this.onProceedToDashboard,
  });

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
                  lifeStage.badgeColor.withOpacity(0.9),
                  const Color(0xFF1E1B4B),
                  const Color(0xFF0F172A),
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
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(lifeStage.icon, size: 54, color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // Stage Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${lifeStage.name.toUpperCase()} STAGE (${lifeStage.ageRange})',
                        style: TextStyle(
                          color: lifeStage.badgeColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Welcome, ${profile?.displayName ?? state.displayName}!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lifeStage.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Profile Summary Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personalized Dashboard Overview',
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSummaryRow(
                                icon: Icons.health_and_safety_rounded,
                                title: 'Health Conditions',
                                value: state.selectedConditions.isEmpty || state.selectedConditions.contains('None')
                                    ? 'No pre-existing conditions reported'
                                    : state.selectedConditions.join(', '),
                              ),
                              const Divider(color: Colors.white24, height: 24),
                              _buildSummaryRow(
                                icon: Icons.medication_rounded,
                                title: 'Active Medications',
                                value: '${state.medications.length} medication(s) tracked',
                              ),
                              const Divider(color: Colors.white24, height: 24),
                              _buildSummaryRow(
                                icon: Icons.psychology_rounded,
                                title: 'Stress & Lifestyle',
                                value: 'Stress level ${state.lifestyle.stressLevel}/10 • ${state.lifestyle.exercise.name.toUpperCase()} exercise',
                              ),
                              const Divider(color: Colors.white24, height: 24),
                              _buildSummaryRow(
                                icon: Icons.contact_phone_rounded,
                                title: 'Emergency Contact',
                                value: state.emergencyContact != null
                                    ? '${state.emergencyContact!.name} (${state.emergencyContact!.relationship})'
                                    : 'Optional (Not configured)',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Launch Dashboard Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onProceedToDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent.shade400,
                          foregroundColor: const Color(0xFF0F172A),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Enter Life-Stage Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
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

  Widget _buildSummaryRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

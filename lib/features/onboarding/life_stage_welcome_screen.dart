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
          backgroundColor: AppTheme.obsidianBase,
          body: Stack(
            children: [
              // Subtle ambient glow
              Positioned(
                top: -80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          lifeStage.badgeColor.withOpacity(0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Top system status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.neonEmerald,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonEmerald,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'SYSTEM INITIALIZED // BIOMETRIC LINK ACTIVE',
                            style: TextStyle(
                              color: AppTheme.neonCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Holographic Core Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.obsidianCard,
                          border: Border.all(
                            color: lifeStage.badgeColor.withOpacity(0.6),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: lifeStage.badgeColor.withOpacity(0.35),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            lifeStage.icon,
                            size: 52,
                            color: lifeStage.badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Life Stage Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.obsidianGlass,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: lifeStage.badgeColor.withOpacity(0.5),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: lifeStage.badgeColor.withOpacity(0.15),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Text(
                          '${lifeStage.name.toUpperCase()} ARCHETYPE (${lifeStage.ageRange})',
                          style: TextStyle(
                            color: lifeStage.badgeColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name Greeting
                      Text(
                        'Welcome, ${profile?.displayName ?? state.displayName}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lifeStage.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Telemetry Configuration Manifest
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: AppTheme.cyberCardDecoration(
                            borderColor: AppTheme.neonCyan.withOpacity(0.3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.hub_outlined, color: AppTheme.neonCyan, size: 18),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'TELEMETRY CALIBRATION MANIFEST',
                                      style: TextStyle(
                                        color: AppTheme.neonCyan,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        letterSpacing: 0.6,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonEmerald.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppTheme.neonEmerald.withOpacity(0.4)),
                                    ),
                                    child: const Text(
                                      'READY',
                                      style: TextStyle(
                                        color: AppTheme.neonEmerald,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: AppTheme.obsidianBorder, height: 24),
                              Expanded(
                                child: ListView(
                                  children: [
                                    _buildTelemetryRow(
                                      Icons.favorite_outline,
                                      'Clinical Risk Baseline',
                                      state.selectedConditions.isEmpty
                                          ? 'Standard Surveillance'
                                          : '${state.selectedConditions.length} Factors Monitored',
                                      AppTheme.neonCyan,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildTelemetryRow(
                                      Icons.medication_outlined,
                                      'Pharmacotherapy Protocol',
                                      state.medications.isEmpty
                                          ? 'Zero Active Prescriptions'
                                          : '${state.medications.length} Active Regimens',
                                      AppTheme.neonPurple,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildTelemetryRow(
                                      Icons.speed_outlined,
                                      'Neuro-Stress Index',
                                      '${state.lifestyle.stressLevel}/10 Assessment Score',
                                      state.lifestyle.stressLevel > 6
                                          ? AppTheme.neonCrimson
                                          : AppTheme.neonEmerald,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildTelemetryRow(
                                      Icons.shield_outlined,
                                      'Emergency Safety Sentinel',
                                      state.emergencyContact != null
                                          ? 'Active (988 & Primary Link)'
                                          : '988 Lifeline Sentinel Active',
                                      AppTheme.neonEmerald,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Enter Vitality HUD Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonCyan.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => context.go('/dashboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonCyan,
                            foregroundColor: AppTheme.obsidianBase,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ENTER VITALITY HUD',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_ios_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTelemetryRow(IconData icon, String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.obsidianCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.obsidianBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
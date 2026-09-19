import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/bloc/auth/auth_bloc.dart';
import '../../core/bloc/auth/auth_state.dart';
import '../../core/bloc/health_sync/health_sync_bloc.dart';
import '../../core/bloc/health_sync/health_sync_event.dart';
import '../../core/bloc/health_sync/health_sync_state.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../core/bloc/onboarding/onboarding_event.dart';
import '../../core/bloc/onboarding/onboarding_state.dart';
import '../../core/theme/app_theme.dart';

class StepPermissions extends StatefulWidget {
  const StepPermissions({super.key});

  @override
  State<StepPermissions> createState() => _StepPermissionsState();
}

class _StepPermissionsState extends State<StepPermissions> {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final String uid = authState is Authenticated ? authState.user.uid : '';
    final String email = authState is Authenticated ? authState.user.email : '';

    return BlocBuilder<HealthSyncBloc, HealthSyncState>(
      builder: (context, healthState) {
        return BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, onboardingState) {
            return Scaffold(
              backgroundColor: AppTheme.darkCanvas,
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.cyberCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.cyberCyan.withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            'STAGE 04 // SENSOR AUTHORIZATION',
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
                      'Telemetry & Sensor Sync',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Authorize biometric telemetry from Google Health Connect, Apple Health, or wearable sensors for continuous real-time calibration.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    // Google Health Connect Card
                    _buildIntegrationCard(
                      context: context,
                      title: 'Google Health Connect / Fit',
                      subtitle: 'Continuous steps, resting heart rate, sleep & glucose',
                      icon: Icons.monitor_heart_rounded,
                      color: AppTheme.cyberCyan,
                      isConnected: healthState.isGoogleFitAuthorized,
                      lastSync: healthState.googleFitLastSync,
                      isLoading: healthState.isLoading,
                      onToggle: () {
                        if (uid.isNotEmpty) {
                          context.read<HealthSyncBloc>().add(RequestGoogleFitEvent(uid));
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Apple Health Card
                    _buildIntegrationCard(
                      context: context,
                      title: 'Apple HealthKit',
                      subtitle: 'Activity rings, vitals & biometric sleep stages',
                      icon: Icons.health_and_safety_rounded,
                      color: AppTheme.cyberBlue,
                      isConnected: healthState.isAppleHealthAuthorized,
                      lastSync: healthState.appleHealthLastSync,
                      isLoading: healthState.isLoading,
                      onToggle: () {
                        if (uid.isNotEmpty) {
                          context.read<HealthSyncBloc>().add(RequestAppleHealthEvent(uid));
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Notifications Permission Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.darkBorder),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: healthState.isNotificationsEnabled,
                        activeColor: AppTheme.cyberCyan,
                        title: const Text(
                          'Vitality Alerts & Clinical Reminders',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        subtitle: const Text(
                          'Receive USPSTF screening prompts and medication reminders.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        onChanged: (val) {
                          context.read<HealthSyncBloc>().add(ToggleNotificationsEvent(val));
                        },
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              context.go('/onboarding/emergency-contact');
                            },
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
                            onPressed: onboardingState.isSubmitting || uid.isEmpty
                                ? null
                                : () {
                                    context.read<OnboardingBloc>().add(
                                      CompleteOnboardingEvent(uid: uid, email: email),
                                    );
                                    context.go('/onboarding/welcome');
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.cyberCyan,
                              foregroundColor: const Color(0xFF080C14),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6,
                            ),
                            child: onboardingState.isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Color(0xFF080C14), strokeWidth: 2.2),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'INITIALIZE VITALITY HUD',
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(Icons.rocket_launch_rounded, size: 16),
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
      },
    );
  }

  Widget _buildIntegrationCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isConnected,
    required DateTime? lastSync,
    required bool isLoading,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected ? color.withValues(alpha: 0.4) : AppTheme.darkBorder,
          width: isConnected ? 1.4 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyberCyan),
                )
              else
                Switch(
                  value: isConnected,
                  activeColor: color,
                  onChanged: (_) => onToggle(),
                ),
            ],
          ),
          if (isConnected && lastSync != null) ...[
            const SizedBox(height: 10),
            const Divider(color: Color(0xFF1E2D4A), height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.sync_rounded, color: AppTheme.bioEmerald, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Active Telemetry • Last Sync: ${DateFormat('hh:mm a').format(lastSync)}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.bioEmerald, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
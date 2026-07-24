import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/bloc/auth/auth_bloc.dart';
import '../../core/bloc/auth/auth_state.dart';
import '../../core/bloc/health_sync/health_sync_bloc.dart';
import '../../core/bloc/health_sync/health_sync_event.dart';
import '../../core/bloc/health_sync/health_sync_state.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../core/bloc/onboarding/onboarding_event.dart';
import '../../core/bloc/onboarding/onboarding_state.dart';

class StepPermissions extends StatelessWidget {
  final VoidCallback onBack;

  const StepPermissions({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final String uid = authState is Authenticated ? authState.user.uid : 'demo_uid';
    final String email = authState is Authenticated ? authState.user.email : 'demo@example.com';

    return BlocBuilder<HealthSyncBloc, HealthSyncState>(
      builder: (context, healthState) {
        return BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, onboardingState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Permissions & Integrations',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect Apple Health or Google Fit to automatically synchronize daily activity and vital signs.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),

                  // Apple Health Card
                  _buildIntegrationCard(
                    context: context,
                    title: 'Apple Health',
                    subtitle: 'Sync Steps, Heart Rate, Sleep & Activity',
                    icon: Icons.apple_rounded,
                    color: Colors.black,
                    isConnected: healthState.isAppleHealthAuthorized,
                    lastSync: healthState.appleHealthLastSync,
                    onToggle: () {
                      context.read<HealthSyncBloc>().add(RequestAppleHealthEvent(uid));
                    },
                  ),
                  const SizedBox(height: 16),

                  // Google Fit Card
                  _buildIntegrationCard(
                    context: context,
                    title: 'Google Fit',
                    subtitle: 'Sync Fitness Metrics, Sleep & Vitals',
                    icon: Icons.fitness_center_rounded,
                    color: const Color(0xFF4285F4),
                    isConnected: healthState.isGoogleFitAuthorized,
                    lastSync: healthState.googleFitLastSync,
                    onToggle: () {
                      context.read<HealthSyncBloc>().add(RequestGoogleFitEvent(uid));
                    },
                  ),
                  const SizedBox(height: 24),

                  // Notifications Permission
                  Card(
                    child: SwitchListTile(
                      value: healthState.isNotificationsEnabled,
                      activeColor: const Color(0xFF4F46E5),
                      title: const Text(
                        'Health Alerts & Medication Reminders',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Receive timely reminders tailored to your life stage.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      onChanged: (val) {
                        context.read<HealthSyncBloc>().add(ToggleNotificationsEvent(val));
                      },
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Navigation Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onBack,
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
                          onPressed: onboardingState.isSubmitting
                              ? null
                              : () {
                                  context.read<OnboardingBloc>().add(
                                        CompleteOnboardingEvent(uid: uid, email: email),
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: onboardingState.isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Complete Onboarding'),
                        ),
                      ),
                    ],
                  ),
                ],
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
    required VoidCallback onToggle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Switch(
                  value: isConnected,
                  activeColor: const Color(0xFF0D9488),
                  onChanged: (_) => onToggle(),
                ),
              ],
            ),
            if (isConnected && lastSync != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF0D9488), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Connected • Last Sync: ${DateFormat('hh:mm a').format(lastSync)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

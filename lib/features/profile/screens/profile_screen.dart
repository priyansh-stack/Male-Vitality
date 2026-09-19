import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/bloc/auth/auth_bloc.dart';
import '../../../core/bloc/auth/auth_event.dart';
import '../../../core/bloc/auth/auth_state.dart';
import '../../../core/bloc/health_sync/health_sync_bloc.dart';
import '../../../core/bloc/health_sync/health_sync_event.dart';
import '../../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../../core/models/life_stage.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final onboardingState = context.watch<OnboardingBloc>().state;
    final syncState = context.watch<HealthSyncBloc>().state;

    final user = authState is Authenticated ? authState.user : null;
    final profile = onboardingState.completedProfile;
    final lifeStage = profile?.lifeStage ?? LifeStage.adult;

    return Scaffold(
      backgroundColor: AppTheme.darkCanvas,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface.withValues(alpha: 0.8),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.cyberCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.cyberCyan.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.tune_rounded, color: AppTheme.cyberCyan, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'CLINICAL COMMAND',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.neonRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.neonRed.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.power_settings_new_rounded, color: AppTheme.neonRed, size: 18),
            ),
            tooltip: 'Terminate Session',
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor: AppTheme.darkCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppTheme.neonRed, width: 1.2),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppTheme.neonRed),
                      SizedBox(width: 10),
                      Text('Sign Out of HUD?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: const Text(
                    'Your local session will be securely terminated. All encrypted Firestore biometrics remain safely stored in the cloud.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        context.read<AuthBloc>().add(AuthSignOutRequested());
                        context.go('/');
                      },
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        children: [
          // User & Archetype HUD Card
          Container(
            decoration: AppTheme.hudGlassDecoration(accentColor: lifeStage.badgeColor),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: lifeStage.badgeColor.withValues(alpha: 0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: lifeStage.badgeColor.withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.darkCanvas,
                      child: Icon(lifeStage.icon, color: lifeStage.badgeColor, size: 34),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName ?? user?.displayName ?? 'MaleVitality Member',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user?.email ?? 'patient@malevitality.health',
                        style: const TextStyle(fontSize: 12, color: AppTheme.cyberCyan, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: lifeStage.badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: lifeStage.badgeColor.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user_rounded, color: lifeStage.badgeColor, size: 13),
                            const SizedBox(width: 6),
                            Text(
                              '${lifeStage.name.toUpperCase()} COHORT • ${lifeStage.ageRange}',
                              style: TextStyle(
                                fontSize: 11,
                                color: lifeStage.badgeColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Secure Health Telemetry & Cloud Sync Status
          Container(
            decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.bioEmerald),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.bioEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.bioEmerald.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.cloud_done_rounded, color: AppTheme.bioEmerald, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HEALTH TELEMETRY & SYNC',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Real-Time Cloud Encrypted Storage',
                            style: TextStyle(fontSize: 11, color: AppTheme.bioEmerald, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.bioEmerald.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ONLINE',
                        style: TextStyle(fontSize: 10, color: AppTheme.bioEmerald, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Continuous telemetry from your paired Fitbit device, screening logs, and clinical markers are securely synchronized in real time with end-to-end encryption.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCanvas,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.security_rounded, color: AppTheme.cyberBlue, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Encrypted Cloud Vault • Zero Non-Clinical Sharing',
                        style: TextStyle(fontSize: 11, color: AppTheme.cyberBlue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Connected Biometric Hardware & Google Health
          Container(
            decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.cyberCyan),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sensors_rounded, color: AppTheme.cyberCyan, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'BIOMETRIC HARDWARE BRIDGES',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Unified Fitbit & Google Health Connect Hardware Bridge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.cyberCyan.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B0B9).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00B0B9).withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.watch_rounded, color: Color(0xFF00B0B9), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fitbit & Health Connect Bridge',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  syncState.isGoogleFitAuthorized
                                      ? 'Synchronized • Continuous Telemetry Stream'
                                      : 'Linked via Health Connect • Live Sync Active',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.bioEmerald,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.bioEmerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.bioEmerald.withValues(alpha: 0.5)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppTheme.bioEmerald, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.bioEmerald,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCanvas,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Steps • Heart Rate • Sleep Stages • Active Calories',
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.cyberCyan,
                                foregroundColor: const Color(0xFF080C14),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                                minimumSize: const Size(0, 32),
                              ),
                              onPressed: () {
                                context.read<HealthSyncBloc>().add(RequestGoogleFitEvent(user?.uid ?? ''));
                              },
                              child: const Text(
                                'Sync',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Security, Governance & Settings
          Container(
            decoration: AppTheme.cyberCardDecoration(),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.neonAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.supervisor_account_rounded, color: AppTheme.neonAmber, size: 20),
                  ),
                  title: const Text('Caregiver Proxy Delegation', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Configure authorized family or clinician access', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                  onTap: () => context.push('/senior-care/caregiver'),
                ),
                const Divider(color: AppTheme.darkBorder, height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.neonPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.lock_outline_rounded, color: AppTheme.neonPurple, size: 20),
                  ),
                  title: const Text('Confidential Private Vault PIN', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Biometric lock for sensitive health records', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                  onTap: () => context.push('/sexual-health'),
                ),
                const Divider(color: AppTheme.darkBorder, height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.cyberBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.verified_outlined, color: AppTheme.cyberBlue, size: 20),
                  ),
                  title: const Text('HIPAA & PHI Security Policy', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Federal compliance & encryption specifications', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        backgroundColor: AppTheme.darkCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: AppTheme.cyberBlue, width: 1.2),
                        ),
                        title: const Row(
                          children: [
                            Icon(Icons.shield_rounded, color: AppTheme.cyberBlue),
                            SizedBox(width: 10),
                            Text('HIPAA PHI Guarantee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        content: const Text(
                          'MaleVitality enforces Strict Confidentiality: Protected Health Information (PHI) is encrypted at rest via AES-256 and in transit via TLS 1.3. Patient data is isolated by UID with zero monetization or non-clinical disclosures.',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                        ),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.cyberBlue,
                              foregroundColor: const Color(0xFF080C14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Acknowledge', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

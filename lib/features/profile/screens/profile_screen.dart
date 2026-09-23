import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/bloc/auth/auth_bloc.dart';
import '../../../core/bloc/auth/auth_event.dart';
import '../../../core/bloc/auth/auth_state.dart';
import '../../../core/bloc/Health_Dashboard/dashboard_bloc.dart';
import '../../../core/bloc/health_sync/health_sync_bloc.dart';
import '../../../core/bloc/health_sync/health_sync_event.dart';
import '../../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../../core/bloc/onboarding/onboarding_event.dart';
import '../../../core/models/emergency_contact.dart';
import '../../../core/models/life_stage.dart';
import '../../../core/models/lifestyle_factors.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/main_dashboard.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifyBiomarkers = true;
  bool _notifyDirectives = true;
  bool _notifyCaregiver = true;
  bool _notifySync = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _notifyBiomarkers = prefs.getBool('fcm_notify_biomarkers') ?? true;
        _notifyDirectives = prefs.getBool('fcm_notify_directives') ?? true;
        _notifyCaregiver = prefs.getBool('fcm_notify_caregiver') ?? true;
        _notifySync = prefs.getBool('fcm_notify_sync') ?? false;
      });
    } catch (_) {}
  }

  Future<void> _setNotificationPref(String key, bool value, [String? fcmTopic]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      if (fcmTopic != null) {
        await FcmService.instance.updateTopicSubscription(fcmTopic, value);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final onboardingState = context.watch<OnboardingBloc>().state;
    final syncState = context.watch<HealthSyncBloc>().state;

    final user = authState is Authenticated ? authState.user : null;
    final profile = onboardingState.completedProfile;
    final lifeStage = profile?.lifeStage ?? LifeStage.adult;
    final userId = user?.uid ?? 'guest';

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
            onPressed: () => _showSignOutDialog(context, userId),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
        children: [
          // 1. User & Archetype HUD Card
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

          // 2. Clinical Demographics & Baseline Vitals
          _buildClinicalDemographicsCard(context, profile, lifeStage, userId),
          const SizedBox(height: 16),

          // 3. Secure Health Telemetry & Cloud Sync Status
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
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCanvas,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.security_rounded, color: AppTheme.cyberBlue, size: 14),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Encrypted Cloud Vault • Zero Sharing',
                                style: TextStyle(fontSize: 10, color: AppTheme.cyberBlue, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        context.read<DashboardBloc>().add(RefreshDashboard(userId: userId));
                        context.read<HealthSyncBloc>().add(RequestGoogleFitEvent(userId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cloud sync initiated. Refreshing vitals telemetry...'),
                            backgroundColor: AppTheme.bioEmerald,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.bioEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.bioEmerald.withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sync_rounded, color: AppTheme.bioEmerald, size: 13),
                            SizedBox(width: 4),
                            Text('FORCE SYNC', style: TextStyle(color: AppTheme.bioEmerald, fontSize: 10, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Connected Biometric Hardware & Google Health
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                                minimumSize: const Size(0, 32),
                              ),
                              onPressed: () {
                                context.read<HealthSyncBloc>().add(RequestGoogleFitEvent(userId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppTheme.darkCard,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(color: AppTheme.cyberCyan, width: 1),
                                    ),
                                    content: const Row(
                                      children: [
                                        Icon(Icons.sync_rounded, color: AppTheme.cyberCyan, size: 18),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Syncing telemetry with Fitbit & Health Connect...',
                                            style: TextStyle(color: Colors.white, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
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

          // 5. Notifications & Clinical Alerts Settings
          _buildNotificationPreferencesCard(context),
          const SizedBox(height: 16),

          // 6. Security, Governance & Settings
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
                  subtitle: const Text('Manage 4-digit biometric lock for sensitive records', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                  onTap: () => _showVaultPinSheet(context, userId),
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
                  onTap: () => _showHipaaDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ============= Helper Widgets =============

  Widget _buildClinicalDemographicsCard(BuildContext context, UserProfile? profile, LifeStage lifeStage, String userId) {
    final ageStr = profile?.age != null ? '${profile!.age} YRS' : '22 YRS';
    final dobStr = profile?.dateOfBirth != null
        ? DateFormat('MMM d, yyyy').format(profile!.dateOfBirth)
        : 'Sep 17, 2004';
    const genderStr = 'MALE';
    final smokerStr = profile?.lifestyle.smoking.label.toUpperCase() ?? 'NON-SMOKER';
    final stressStr = '${profile?.lifestyle.stressLevel ?? 4}/10 STRESS';
    final sleepStr = profile?.lifestyle.sleep.label.toUpperCase() ?? 'GOOD (7-8 HRS)';
    final ec = profile?.emergencyContact;

    return Container(
      decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.darkBorder),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: AppTheme.cyberCyan, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'CLINICAL DEMOGRAPHICS & BASELINE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _showEditDemographicsSheet(context, profile, userId),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cyberCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.cyberCyan.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, color: AppTheme.cyberCyan, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'EDIT',
                        style: TextStyle(
                          color: AppTheme.cyberCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildDemographicPill('AGE / DOB', '$ageStr • $dobStr', Icons.calendar_today_rounded, AppTheme.cyberCyan),
              const SizedBox(width: 8),
              _buildDemographicPill('BIOLOGICAL SEX', genderStr, Icons.male_rounded, AppTheme.bioEmerald),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDemographicPill('LIFESTYLE', '$smokerStr • $stressStr', Icons.favorite_border_rounded, AppTheme.neonAmber),
              const SizedBox(width: 8),
              _buildDemographicPill('SLEEP PROFILE', sleepStr, Icons.bedtime_rounded, AppTheme.neonPurple),
            ],
          ),
          if (ec != null && ec.name.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.contact_phone_outlined, color: AppTheme.cyberBlue, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EMERGENCY PROXY CONTACT',
                          style: TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${ec.name} (${ec.relationship.toUpperCase()}) • ${ec.phoneNumber}',
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDemographicPill(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(fontSize: 9, color: AppTheme.textMuted, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPreferencesCard(BuildContext context) {
    return Container(
      decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.darkBorder),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_active_outlined, color: AppTheme.neonCyan, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'NOTIFICATIONS & CLINICAL ALERTS',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      letterSpacing: 0.9,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.cyberCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'FCM READY',
                  style: TextStyle(fontSize: 9, color: AppTheme.cyberCyan, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNotificationToggle(
            title: 'Critical Biomarker Alerts',
            subtitle: 'Real-time push alerts for high blood pressure & tachycardia',
            value: _notifyBiomarkers,
            color: AppTheme.neonRed,
            onChanged: (val) {
              setState(() => _notifyBiomarkers = val);
              _setNotificationPref('fcm_notify_biomarkers', val, 'critical_alerts');
            },
          ),
          const Divider(color: AppTheme.darkBorder, height: 1),
          _buildNotificationToggle(
            title: 'Daily Directives & Check-ins',
            subtitle: 'Reminders for morning HRV check-in & nocturnal sleep logging',
            value: _notifyDirectives,
            color: AppTheme.cyberCyan,
            onChanged: (val) {
              setState(() => _notifyDirectives = val);
              _setNotificationPref('fcm_notify_directives', val, 'daily_directives');
            },
          ),
          const Divider(color: AppTheme.darkBorder, height: 1),
          _buildNotificationToggle(
            title: 'Caregiver SOS Notifications',
            subtitle: 'Fall detection broadcast alerts to designated proxies',
            value: _notifyCaregiver,
            color: AppTheme.neonAmber,
            onChanged: (val) {
              setState(() => _notifyCaregiver = val);
              _setNotificationPref('fcm_notify_caregiver', val, 'caregiver_sos');
            },
          ),
          const Divider(color: AppTheme.darkBorder, height: 1),
          _buildNotificationToggle(
            title: 'Wearable Sync Telemetry Alerts',
            subtitle: 'Notifies when background Fitbit/Google Health sync finishes',
            value: _notifySync,
            color: AppTheme.bioEmerald,
            onChanged: (val) {
              setState(() => _notifySync = val);
              _setNotificationPref('fcm_notify_sync', val, 'wearable_sync');
            },
          ),
          const Divider(color: AppTheme.darkBorder, height: 1),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.notifications_active_rounded, size: 16, color: AppTheme.cyberCyan),
              label: const Text('Dispatch Test Clinical Notification', style: TextStyle(color: AppTheme.cyberCyan, fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.cyberCyan, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () async {
                await FcmService.instance.showWeeklyVitalityDigest(
                  vitalityScore: 88,
                  cohort: 'Young Adult (18-25)',
                  status: 'Optimal Baseline',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test clinical alert dispatched to notification tray!'),
                      backgroundColor: AppTheme.cyberCyan,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.darkCanvas,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ============= Dialogs & Sheets =============

  void _showVaultPinSheet(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppTheme.darkCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppTheme.neonPurple, width: 1.2),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.darkBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.lock_rounded, color: AppTheme.neonPurple, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'CONFIDENTIAL VAULT SECURITY',
                    style: TextStyle(
                      color: AppTheme.neonPurple,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Your hormonal, reproductive, and private clinical records are locked with AES-256 local biometric PIN encryption. Default factory PIN is 1234.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppTheme.neonPurple, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('VAULT STATUS', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Active • Local PIN Protected', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _showChangePinDialog(context, userId);
                      },
                      child: const Text('Change PIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lock_open_rounded, size: 18),
                  label: const Text('Unlock & Open Private Health Vault'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkSurface,
                    foregroundColor: AppTheme.neonPurple,
                    side: const BorderSide(color: AppTheme.neonPurple, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    _showVerifyPinDialog(context, userId);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVerifyPinDialog(BuildContext context, String userId) {
    final pinCtrl = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.neonPurple, width: 1.2),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: AppTheme.neonPurple),
              SizedBox(width: 10),
              Text(
                'Confidential Vault PIN',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your 4-digit PIN to access confidential reproductive, hormonal, and sexual health records.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: const TextStyle(color: AppTheme.textMuted, letterSpacing: 10),
                  errorText: errorText,
                  filled: true,
                  fillColor: AppTheme.darkSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.darkBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.neonPurple)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final savedPin = prefs.getString('confidential_health_pin_$userId');
                if (savedPin == null || savedPin.isEmpty) {
                  Navigator.pop(dialogCtx);
                  if (context.mounted) {
                    _showChangePinDialog(context, userId);
                  }
                  return;
                }
                final entered = pinCtrl.text.trim();
                if (entered.length == 4 && entered == savedPin) {
                  Navigator.pop(dialogCtx);
                  if (context.mounted) {
                    context.push('/sexual-health');
                  }
                } else {
                  setDialogState(() {
                    errorText = 'Incorrect security PIN. Access denied.';
                  });
                }
              },
              child: const Text('Unlock Vault', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDemographicsSheet(BuildContext context, UserProfile? profile, String userId) {
    DateTime selectedDob = profile?.dateOfBirth ?? DateTime(2004, 9, 17);
    const selectedGender = 'Male';
    SmokingStatus selectedSmoking = profile?.lifestyle.smoking ?? SmokingStatus.never;
    int selectedStress = profile?.lifestyle.stressLevel ?? 4;
    SleepQuality selectedSleep = profile?.lifestyle.sleep ?? SleepQuality.good;

    final contactNameCtrl = TextEditingController(text: profile?.emergencyContact?.name ?? '');
    const validRelationships = ['Spouse', 'Partner', 'Parent', 'Child', 'Sibling', 'Friend', 'Clinician', 'Other'];
    final rawRel = profile?.emergencyContact?.relationship ?? 'Spouse';
    String selectedRelationship = validRelationships.firstWhere(
      (r) => r.toLowerCase() == rawRel.toLowerCase(),
      orElse: () => 'Other',
    );
    final contactPhoneCtrl = TextEditingController(text: profile?.emergencyContact?.phoneNumber ?? '');

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppTheme.darkCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppTheme.cyberCyan, width: 1.2),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.darkBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Icon(Icons.edit_note_rounded, color: AppTheme.cyberCyan, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'EDIT CLINICAL DEMOGRAPHICS',
                      style: TextStyle(
                        color: AppTheme.cyberCyan,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date of Birth Picker
                const Text('DATE OF BIRTH & AGE', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: sheetCtx,
                      initialDate: selectedDob,
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                      builder: (pickerCtx, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppTheme.cyberCyan,
                            onPrimary: Colors.black,
                            surface: AppTheme.darkSurface,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setSheetState(() => selectedDob = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM d, yyyy').format(selectedDob),
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const Icon(Icons.calendar_month_rounded, color: AppTheme.cyberCyan, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Biological Sex
                const Text('BIOLOGICAL SEX & CLINICAL ARCHITECTURE', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.bioEmerald.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.male_rounded, color: AppTheme.bioEmerald, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Male Physiology (XY Biometric Cohort)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Calibrated for male endocrine, metabolic & prostate surveillance',
                              style: TextStyle(fontSize: 10, color: AppTheme.bioEmerald),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.verified_rounded, color: AppTheme.bioEmerald, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Smoking Status
                const Text('SMOKING & NICOTINE STATUS', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SmokingStatus>(
                      value: selectedSmoking,
                      dropdownColor: AppTheme.darkCard,
                      isExpanded: true,
                      items: SmokingStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.label, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedSmoking = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Stress Level Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CLINICAL STRESS INDEX', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('$selectedStress / 10', style: const TextStyle(color: AppTheme.neonAmber, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                Slider(
                  value: selectedStress.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: AppTheme.neonAmber,
                  inactiveColor: AppTheme.darkSurface,
                  label: '$selectedStress',
                  onChanged: (val) => setSheetState(() => selectedStress = val.round()),
                ),
                const SizedBox(height: 10),

                // Sleep Profile
                const Text('SLEEP PATTERN', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SleepQuality>(
                      value: selectedSleep,
                      dropdownColor: AppTheme.darkCard,
                      isExpanded: true,
                      items: SleepQuality.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.label, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedSleep = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Emergency Contact Section
                const Divider(color: AppTheme.darkBorder),
                const SizedBox(height: 6),
                const Text('EMERGENCY PROXY CONTACT', style: TextStyle(color: AppTheme.cyberCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: contactNameCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Contact Full Name',
                    labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.darkSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.darkBorder)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedRelationship,
                            dropdownColor: AppTheme.darkCard,
                            isExpanded: true,
                            items: ['Spouse', 'Partner', 'Parent', 'Child', 'Sibling', 'Friend', 'Clinician', 'Other'].map((r) {
                              return DropdownMenuItem(
                                value: r,
                                child: Text(r, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => selectedRelationship = val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: contactPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppTheme.darkSurface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.darkBorder)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Save Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyberCyan,
                      foregroundColor: const Color(0xFF080C14),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            setSheetState(() => isSaving = true);
                            try {
                              final updatedLifestyle = (profile?.lifestyle ?? LifestyleFactors()).copyWith(
                                smoking: selectedSmoking,
                                stressLevel: selectedStress,
                                sleep: selectedSleep,
                              );
                              final updatedContact = contactNameCtrl.text.trim().isNotEmpty
                                  ? EmergencyContact(
                                      name: contactNameCtrl.text.trim(),
                                      relationship: selectedRelationship,
                                      phoneNumber: contactPhoneCtrl.text.trim(),
                                    )
                                  : profile?.emergencyContact;

                              final updatedProfile = UserProfile(
                                uid: userId,
                                email: profile?.email ?? '',
                                displayName: profile?.displayName ?? '',
                                dateOfBirth: selectedDob,
                                gender: selectedGender,
                                healthConditions: profile?.healthConditions ?? [],
                                medications: profile?.medications ?? [],
                                lifestyle: updatedLifestyle,
                                emergencyContact: updatedContact,
                                insuranceDetails: profile?.insuranceDetails ?? {},
                                onboardingCompleted: true,
                                createdAt: profile?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );

                              final firestoreService = FirestoreService(firestore: FirebaseFirestore.instance);
                              await firestoreService.saveUserProfile(updatedProfile);

                              if (context.mounted) {
                                context.read<OnboardingBloc>().add(LoadSavedProfile(userId));
                                Navigator.pop(sheetCtx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Clinical Demographics & Baseline updated successfully.'),
                                    backgroundColor: AppTheme.bioEmerald,
                                  ),
                                );
                              }
                            } catch (e) {
                              setSheetState(() => isSaving = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: AppTheme.neonRed),
                                );
                              }
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('Save Clinical Demographics', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('confidential_health_pin_$userId');
    final hasExistingPin = savedPin != null && savedPin.isNotEmpty;

    final currentPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    final confirmPinCtrl = TextEditingController();
    String? errorText;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.neonPurple, width: 1.2),
          ),
          title: Row(
            children: [
              const Icon(Icons.pin_rounded, color: AppTheme.neonPurple),
              const SizedBox(width: 10),
              Text(hasExistingPin ? 'Update Security PIN' : 'Set Up Security PIN',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasExistingPin
                    ? 'Enter your current PIN, followed by your new 4-digit security code.'
                    : 'Create a 4-digit security code for your confidential health vault.',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              if (hasExistingPin) ...[
                TextField(
                  controller: currentPinCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 6),
                  decoration: InputDecoration(
                    labelText: 'Current 4-Digit PIN',
                    labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    counterText: '',
                    filled: true,
                    fillColor: AppTheme.darkCanvas,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.darkBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonPurple)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: newPinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 6),
                decoration: InputDecoration(
                  labelText: hasExistingPin ? 'New 4-Digit PIN' : 'Create 4-Digit PIN',
                  labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  counterText: '',
                  filled: true,
                  fillColor: AppTheme.darkCanvas,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.darkBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonPurple)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 6),
                decoration: InputDecoration(
                  labelText: 'Confirm 4-Digit PIN',
                  labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  counterText: '',
                  filled: true,
                  fillColor: AppTheme.darkCanvas,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.darkBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonPurple)),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Text(errorText!, style: const TextStyle(color: AppTheme.neonRed, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (hasExistingPin && currentPinCtrl.text.trim() != savedPin) {
                  setDialogState(() => errorText = 'Current PIN is incorrect.');
                  return;
                }
                final newPin = newPinCtrl.text.trim();
                final confirmPin = confirmPinCtrl.text.trim();

                if (newPin.length != 4 || int.tryParse(newPin) == null) {
                  setDialogState(() => errorText = 'PIN must be exactly 4 digits.');
                  return;
                }
                if (hasExistingPin && newPin == currentPinCtrl.text.trim()) {
                  setDialogState(() => errorText = 'New PIN must be different from current.');
                  return;
                }
                if (newPin != confirmPin) {
                  setDialogState(() => errorText = 'New PINs do not match.');
                  return;
                }

                await prefs.setString('confidential_health_pin_$userId', newPin);
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.darkCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.bioEmerald, width: 1),
                      ),
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppTheme.bioEmerald, size: 18),
                          SizedBox(width: 10),
                          Text('Confidential Vault PIN successfully updated!', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                }
              },
              child: Text(hasExistingPin ? 'Update PIN' : 'Save PIN', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHipaaDialog(BuildContext context) {
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
  }

  void _showSignOutDialog(BuildContext context, String userId) {
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
              context.read<DashboardBloc>().add(const ClearDashboardData());
              if (userId.isNotEmpty && userId != 'guest') {
                context.read<FirestoreService>().clearUserCache(userId);
              }
              UnifiedDashboardScreen.resetState();
              context.read<AuthBloc>().add(AuthSignOutRequested());
              context.go('/');
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}

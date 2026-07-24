import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/bloc/auth/auth_bloc.dart';
import '../../core/bloc/auth/auth_event.dart';
import '../../core/bloc/auth/auth_state.dart';
import '../../core/bloc/health_sync/health_sync_bloc.dart';
import '../../core/bloc/onboarding/onboarding_bloc.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingState = context.watch<OnboardingBloc>().state;
    final healthSyncState = context.watch<HealthSyncBloc>().state;
    final authState = context.watch<AuthBloc>().state;

    final profile = onboardingState.completedProfile;
    final lifeStage = onboardingState.detectedLifeStage;
    final userName = profile?.displayName ?? 
        (authState is Authenticated ? authState.user.displayName : 'User');
    final userEmail = profile?.email ?? 
        (authState is Authenticated ? authState.user.email : '');

    // Get current greeting based on time
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : 
                     hour < 17 ? 'Good Afternoon' : 
                     'Good Evening';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF4F46E5),
                radius: 22,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF0F172A)
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      fontSize: 11, 
                      color: Color(0xFF64748B)
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(AuthSignOutRequested());
              } else if (value == 'profile') {
                // TODO: Navigate to profile
              } else if (value == 'settings') {
                // TODO: Navigate to settings
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh data
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Text(
                '$greeting,',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              // Quick Stats Row
              Row(
                children: [
                  _buildQuickStat(
                    context,
                    icon: Icons.calendar_today_rounded,
                    value: lifeStage.name,
                    label: 'Life Stage',
                    color: lifeStage.badgeColor,
                  ),
                  const SizedBox(width: 12),
                  _buildQuickStat(
                    context,
                    icon: Icons.fitness_center_rounded,
                    value: onboardingState.lifestyle.exercise.name,
                    label: 'Exercise',
                    color: const Color(0xFF0D9488),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickStat(
                    context,
                    icon: Icons.medication_rounded,
                    value: onboardingState.medications.length.toString(),
                    label: 'Medications',
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main Life-Stage Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [lifeStage.badgeColor, lifeStage.badgeColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: lifeStage.badgeColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            '${lifeStage.name.toUpperCase()} STAGE',
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.w800, 
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(lifeStage.icon, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Age Range: ${lifeStage.ageRange}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lifeStage.description,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 15, 
                        fontWeight: FontWeight.w500, 
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Navigate to detailed assessment
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withOpacity(0.4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('View Full Assessment'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Health Data Imports / Connected Sources
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Health Integrations',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF0F172A)
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Refresh health data
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildHealthSourceCard(
                      title: 'Apple Health',
                      icon: Icons.apple_rounded,
                      isConnected: healthSyncState.isAppleHealthAuthorized,
                      lastSync: healthSyncState.appleHealthLastSync,
                      isLoading: healthSyncState.isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHealthSourceCard(
                      title: 'Google Fit',
                      icon: Icons.fitness_center_rounded,
                      isConnected: healthSyncState.isGoogleFitAuthorized,
                      lastSync: healthSyncState.googleFitLastSync,
                      isLoading: healthSyncState.isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Health Metrics Section
              const Text(
                'Health Metrics',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF0F172A)
                ),
              ),
              const SizedBox(height: 12),

              // Lifestyle & Stress Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.psychology_rounded, 
                              color: Color(0xFF4F46E5),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lifestyle & Stress',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Stress Level: ${onboardingState.lifestyle.stressLevel}/10',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStressIndicator(onboardingState.lifestyle.stressLevel),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getExerciseIcon(onboardingState.lifestyle.exercise.name),
                              size: 16,
                              color: const Color(0xFF475569),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Exercise: ${onboardingState.lifestyle.exercise.name}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Medications Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6FFFA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medication_rounded, 
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  title: const Text(
                    'Tracked Medications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    onboardingState.medications.isEmpty
                        ? 'No active medications registered'
                        : '${onboardingState.medications.length} medications tracked',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  trailing: onboardingState.medications.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${onboardingState.medications.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    // TODO: Show medications list
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Emergency Contact Card
              if (onboardingState.emergencyContact != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.contact_phone_rounded, 
                        color: Colors.redAccent,
                      ),
                    ),
                    title: Text(
                      'Emergency Contact: ${onboardingState.emergencyContact!.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${onboardingState.emergencyContact!.relationship} • ${onboardingState.emergencyContact!.phoneNumber}',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone_forwarded_rounded, color: Colors.redAccent),
                      onPressed: () {
                        // TODO: Initiate emergency call
                      },
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSourceCard({
    required String title,
    required IconData icon,
    required bool isConnected,
    required DateTime? lastSync,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
          width: isConnected ? 2 : 1,
        ),
        boxShadow: [
          if (isConnected)
            BoxShadow(
              color: const Color(0xFF0D9488).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isConnected 
                      ? const Color(0xFF0D9488).withOpacity(0.1) 
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon, 
                  color: isConnected ? const Color(0xFF0D9488) : const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4F46E5),
                  ),
                )
              else
                Icon(
                  isConnected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isConnected ? const Color(0xFF0D9488) : const Color(0xFF94A3B8),
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isConnected && lastSync != null
                ? 'Last sync: ${DateFormat('MMM d, hh:mm a').format(lastSync)}'
                : 'Not Connected',
            style: TextStyle(
              fontSize: 11,
              color: isConnected ? const Color(0xFF0D9488) : const Color(0xFF64748B),
              fontWeight: isConnected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isConnected ? null : () {
                // TODO: Connect health source
              },
              style: TextButton.styleFrom(
                backgroundColor: isConnected 
                    ? const Color(0xFF0D9488).withOpacity(0.05) 
                    : const Color(0xFF4F46E5).withOpacity(0.1),
                foregroundColor: isConnected ? const Color(0xFF0D9488) : const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isConnected ? 'Connected' : 'Connect',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressIndicator(int stressLevel) {
    Color color;
    if (stressLevel <= 3) {
      color = const Color(0xFF0D9488);
    } else if (stressLevel <= 6) {
      color = const Color(0xFFF59E0B);
    } else {
      color = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$stressLevel/10',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  IconData _getExerciseIcon(String exercise) {
    switch (exercise.toLowerCase()) {
      case 'running':
        return Icons.directions_run_rounded;
      case 'cycling':
        return Icons.directions_bike_rounded;
      case 'swimming':
        return Icons.pool_rounded;
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'yoga':
        return Icons.self_improvement_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }
}
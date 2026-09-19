import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class UnifiedTrackScreen extends StatelessWidget {
  final String userId;

  const UnifiedTrackScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidianBase,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.track_changes_rounded, color: AppTheme.neonCyan, size: 20),
            SizedBox(width: 8),
            Text(
              'TELEMETRY INGESTION CHANNELS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.neonCyan.withOpacity(0.35)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.neonCyan.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppTheme.neonCyan, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CALIBRATE LIVE BIOMETRICS',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Direct sensor feeds continuously recalibrate your Composite Vitality Index.',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.neonCyan,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AVAILABLE TELEMETRY CHANNELS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neonCyan,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildTrackTile(
            context,
            icon: Icons.monitor_heart_rounded,
            title: 'VITAL SIGNS & HEMODYNAMICS',
            subtitle: 'Blood Pressure, Resting Heart Rate, Body Composition, Glucose',
            color: AppTheme.neonCrimson,
            route: '/add-metric',
          ),
          _buildTrackTile(
            context,
            icon: Icons.psychology_rounded,
            title: 'NEURO-AFFECTIVE CHECK-IN',
            subtitle: 'PHQ-2 depression & GAD-2 anxiety clinical screening with stressors',
            color: AppTheme.neonPurple,
            route: '/mood-checkin',
          ),
          _buildTrackTile(
            context,
            icon: Icons.bedtime_rounded,
            title: 'CIRCADIAN & SLEEP ARCHITECTURE',
            subtitle: 'REM latency, efficiency metrics, and sleep phase continuity',
            color: AppTheme.neonCyan,
            route: '/sleep-optimizer',
          ),
          _buildTrackTile(
            context,
            icon: Icons.restaurant_rounded,
            title: 'METABOLIC & MACRONUTRIENT LOG',
            subtitle: 'Caloric load, bioavailable protein, micronutrient index & hydration',
            color: AppTheme.neonAmber,
            route: '/fitness-nutrition',
          ),
          _buildTrackTile(
            context,
            icon: Icons.medication_rounded,
            title: 'PHARMACOTHERAPY ADHERENCE',
            subtitle: 'Log scheduled prescription doses and check therapeutic windows',
            color: AppTheme.neonCyan,
            route: '/medications',
          ),
          _buildTrackTile(
            context,
            icon: Icons.local_bar_rounded,
            title: 'TOXICOLOGY & SUBSTANCE AUDIT',
            subtitle: 'AUDIT-C evidence-based scoring and harm reduction monitoring',
            color: AppTheme.neonCrimson,
            route: '/substance-assessment',
          ),
          _buildTrackTile(
            context,
            icon: Icons.male_rounded,
            title: 'ENDOCRINE & ADAM QUESTIONNAIRE',
            subtitle: 'Androgen deficiency clinical 10-point symptom telemetry',
            color: AppTheme.neonPurple,
            route: '/sexual-health',
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cyberCardDecoration(borderColor: color.withOpacity(0.35)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 12,
            letterSpacing: 0.8,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add_rounded, color: color, size: 18),
        ),
        onTap: () => context.push(route),
      ),
    );
  }
}


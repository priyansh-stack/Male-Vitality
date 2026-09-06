import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnifiedTrackScreen extends StatelessWidget {
  final String userId;

  const UnifiedTrackScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Unified Health Logging',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'What would you like to log right now?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Record daily inputs to update your real-time Vitality Score.',
            style: TextStyle(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 16),

          _buildTrackTile(
            context,
            icon: Icons.monitor_heart_rounded,
            title: 'Vital Signs',
            subtitle: 'Blood Pressure, Resting Heart Rate, Weight, Fasting Glucose',
            color: const Color(0xFFEF4444),
            route: '/add-metric',
          ),
          _buildTrackTile(
            context,
            icon: Icons.mood_rounded,
            title: 'Mood & Emotional State',
            subtitle: 'PHQ-2 depression & GAD-2 anxiety check-in with triggers',
            color: const Color(0xFF8B5CF6),
            route: '/mood-checkin',
          ),
          _buildTrackTile(
            context,
            icon: Icons.bedtime_rounded,
            title: 'Sleep Session',
            subtitle: 'Duration, sleep efficiency, and morning grogginess rating',
            color: const Color(0xFF6366F1),
            route: '/sleep-optimizer',
          ),
          _buildTrackTile(
            context,
            icon: Icons.restaurant_rounded,
            title: 'Meal & Nutrition',
            subtitle: 'Calories, protein grams, carbs, fat, and daily hydration',
            color: const Color(0xFFF97316),
            route: '/fitness-nutrition',
          ),
          _buildTrackTile(
            context,
            icon: Icons.medication_rounded,
            title: 'Medication Dose',
            subtitle: 'Confirm scheduled doses taken and check refill status',
            color: const Color(0xFF0284C7),
            route: '/medications',
          ),
          _buildTrackTile(
            context,
            icon: Icons.local_bar_rounded,
            title: 'Alcohol & Substance',
            subtitle: 'AUDIT-C screening check and reduction goal progress',
            color: const Color(0xFFEC4899),
            route: '/substance-assessment',
          ),
          _buildTrackTile(
            context,
            icon: Icons.male_rounded,
            title: 'Testosterone Symptoms',
            subtitle: 'ADAM questionnaire 10-symptom endocrine tracking',
            color: const Color(0xFF2563EB),
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
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
        trailing: const Icon(Icons.add_circle_outline, color: Colors.white70),
        onTap: () => context.push(route),
      ),
    );
  }
}

import 'package:flutter/material.dart';

enum LifeStage {
  teen(
    name: 'Teen',
    ageRange: '13 - 17',
    description: 'Focus on growth, puberty, academic balance, and sports.',
    icon: Icons.school_rounded,
    badgeColor: Color(0xFF06B6D4), // Cyan
  ),
  youngAdult(
    name: 'Young Adult',
    ageRange: '18 - 25',
    description: 'Emphasis on fitness, mental resilience, energy, and habit building.',
    icon: Icons.directions_run_rounded,
    badgeColor: Color(0xFF0D9488), // Teal
  ),
  adult(
    name: 'Adult',
    ageRange: '26 - 39',
    description: 'Work-life harmony, preventive screening, and stress mitigation.',
    icon: Icons.fitness_center_rounded,
    badgeColor: Color(0xFF6366F1), // Indigo
  ),
  midLife(
    name: 'Mid-Life',
    ageRange: '40 - 54',
    description: 'Cardiovascular maintenance, metabolic health, and sleep tracking.',
    icon: Icons.favorite_rounded,
    badgeColor: Color(0xFF8B5CF6), // Purple
  ),
  olderAdult(
    name: 'Older Adult',
    ageRange: '55 - 69',
    description: 'Joint flexibility, bone density, medication safety, and routine checkups.',
    icon: Icons.spa_rounded,
    badgeColor: Color(0xFFF59E0B), // Amber
  ),
  senior(
    name: 'Senior',
    ageRange: '70+',
    description: 'Vitality, balance, emergency readiness, and comprehensive care.',
    icon: Icons.health_and_safety_rounded,
    badgeColor: Color(0xFFEC4899), // Pink
  );

  final String name;
  final String ageRange;
  final String description;
  final IconData icon;
  final Color badgeColor;

  const LifeStage({
    required this.name,
    required this.ageRange,
    required this.description,
    required this.icon,
    required this.badgeColor,
  });

  static LifeStage calculateFromDOB(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    if (age <= 17) return LifeStage.teen;
    if (age <= 25) return LifeStage.youngAdult;
    if (age <= 39) return LifeStage.adult;
    if (age <= 54) return LifeStage.midLife;
    if (age <= 69) return LifeStage.olderAdult;
    return LifeStage.senior;
  }
}

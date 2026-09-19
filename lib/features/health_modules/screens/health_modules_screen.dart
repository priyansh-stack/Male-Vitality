import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../../core/engine/life_stage_adaptive_rules.dart';
import '../../../core/models/life_stage.dart';
import '../../../core/theme/app_theme.dart';

class HealthModulesScreen extends StatefulWidget {
  const HealthModulesScreen({super.key});

  @override
  State<HealthModulesScreen> createState() => _HealthModulesScreenState();
}

class _HealthModulesScreenState extends State<HealthModulesScreen> {
  LifeStage? _overrideStage;

  @override
  Widget build(BuildContext context) {
    final onboardingState = context.watch<OnboardingBloc>().state;
    final userStage = _overrideStage ??
        onboardingState.completedProfile?.lifeStage ??
        LifeStage.adult;

    final activeModules = LifeStageAdaptiveRules.getModulesForStage(userStage);
    final focusHeadline = LifeStageAdaptiveRules.getLifeStageFocusHeadline(userStage);

    return Scaffold(
      backgroundColor: AppTheme.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidianBase,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.view_in_ar_rounded, color: AppTheme.neonCyan, size: 20),
            SizedBox(width: 8),
            Text(
              'BIOMETRIC MODULE MATRIX',
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
          // Life-Stage Holographic Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: userStage.badgeColor.withOpacity(0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.obsidianCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: userStage.badgeColor.withOpacity(0.6), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: userStage.badgeColor.withOpacity(0.25),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(userStage.icon, color: userStage.badgeColor, size: 26),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${userStage.name.toUpperCase()} ARCHETYPE',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: userStage.badgeColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: userStage.badgeColor.withOpacity(0.4)),
                                ),
                                child: Text(
                                  userStage.ageRange,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: userStage.badgeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            focusHeadline,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'SIMULATE ARCHETYPE PROFILE:',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.neonCyan,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LifeStage.values.map((stage) {
                      final isSelected = stage == userStage;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() => _overrideStage = stage);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? stage.badgeColor.withOpacity(0.2) : AppTheme.obsidianCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? stage.badgeColor : AppTheme.obsidianBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              stage.name.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textMuted,
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
              Text(
                'ACTIVE SURVEILLANCE VECTORS (${activeModules.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neonCyan,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Modules Grid
          ...activeModules.map((module) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: AppTheme.cyberCardDecoration(
                  borderColor: module.accentColor.withOpacity(0.35),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: module.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: module.accentColor.withOpacity(0.3)),
                    ),
                    child: Icon(module.icon, color: module.accentColor, size: 22),
                  ),
                  title: Text(
                    module.title.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      module.description,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.obsidianCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.obsidianBorder),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.neonCyan),
                  ),
                  onTap: () {
                    context.push(module.route);
                  },
                ),
              )),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/bloc/onboarding/onboarding_bloc.dart';
import '../../../core/engine/life_stage_adaptive_rules.dart';
import '../../../core/models/life_stage.dart';

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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Life-Stage Health Modules',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Life-Stage Adaptive Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  userStage.badgeColor.withValues(alpha: 0.3),
                  const Color(0xFF1E293B),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: userStage.badgeColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: userStage.badgeColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(userStage.icon, color: userStage.badgeColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                userStage.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  userStage.ageRange,
                                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            focusHeadline,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Switch Life Stage Preview:',
                  style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LifeStage.values.map((stage) {
                      final isSelected = stage == userStage;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(stage.name),
                          selected: isSelected,
                          selectedColor: stage.badgeColor,
                          backgroundColor: const Color(0xFF0F172A),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _overrideStage = stage);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Active Modules (${activeModules.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),

          // Modules Grid
          ...activeModules.map((module) => Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: module.accentColor.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: module.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(module.icon, color: module.accentColor, size: 24),
                  ),
                  title: Text(
                    module.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      module.description,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
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

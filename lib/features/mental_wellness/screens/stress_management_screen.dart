import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/bloc/mental_wellness/guided_exercise_bloc/guided_exercise_bloc.dart';
import '../../../core/models/mental_wellness/guided_exercise.dart';
import '../../../core/models/life_stage.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/exercise_card.dart';

class StressManagementScreen extends StatefulWidget {
  final String userId;
  final LifeStage? userLifeStage;

  const StressManagementScreen({
    super.key,
    required this.userId,
    this.userLifeStage,
  });

  @override
  State<StressManagementScreen> createState() => _StressManagementScreenState();
}

class _StressManagementScreenState extends State<StressManagementScreen> {
  int _stressLevel = 5;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    context.read<GuidedExerciseBloc>().add(
      LoadGuidedExercisesEvent(
        ageGroup: widget.userLifeStage,
      ),
    );
  }

  void _goBack() {
    context.go('/wellness?userId=${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Stress Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStressAssessment(),
            const SizedBox(height: 24),
            _buildAgeAdaptedTools(),
            const SizedBox(height: 24),
            _buildExerciseRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildStressAssessment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stress Check-in',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'How stressed are you feeling right now?',
              style: TextStyle(color: AppTheme.textMedium),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Low', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _stressLevel.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: _getStressColor(_stressLevel),
                    onChanged: (value) {
                      setState(() => _stressLevel = value.round());
                    },
                  ),
                ),
                const Text('High', style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stress Level: $_stressLevel/10',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStressColor(_stressLevel),
                  ),
                ),
                if (_stressLevel >= 7)
                  const Text(
                    '⚠️ High Stress',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'What\'s causing your stress? (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stress check-in saved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Save Check-in'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeAdaptedTools() {
    final stage = widget.userLifeStage ?? LifeStage.adult;
    final tools = _getAgeAdaptedTools(stage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Age-Adapted Stress Tools',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: stage.badgeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: stage.badgeColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(stage.icon, color: stage.badgeColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Adapted for ${stage.name} (${stage.ageRange})',
                style: TextStyle(
                  fontSize: 12,
                  color: stage.badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...tools.map((tool) => _buildToolCard(tool)),
      ],
    );
  }

  Widget _buildToolCard(Map<String, dynamic> tool) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (tool['color'] as Color).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(tool['icon'] as IconData, color: tool['color'] as Color),
        ),
        title: Text(tool['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(tool['description'] as String),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${tool['title']}...'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Exercises',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Based on your stress level and age',
          style: TextStyle(color: AppTheme.textMedium),
        ),
        const SizedBox(height: 16),
        BlocBuilder<GuidedExerciseBloc, GuidedExerciseState>(
          builder: (context, state) {
            if (state is ExerciseLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ExerciseLibraryLoadedState) {
              final stressExercises = state.exercises
                  .where((e) => e.type == ExerciseType.breathing ||
                      e.type == ExerciseType.meditation ||
                      e.type == ExerciseType.progressiveRelaxation)
                  .take(3)
                  .toList();

              if (stressExercises.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No stress management exercises available')),
                  ),
                );
              }

              return Column(
                children: stressExercises.map((exercise) {
                  final progress = state.progress[exercise.id] ?? 0;
                  return ExerciseCard(
                    exercise: exercise,
                    progress: progress,
                    onTap: () {
                      context.push(
                        '/exercise-player/${exercise.id}',
                        extra: exercise,
                      );
                    },
                  );
                }).toList(),
              );
            }

            return const Center(child: Text('No exercises available'));
          },
        ),
      ],
    );
  }

  Color _getStressColor(int level) {
    if (level <= 3) return AppTheme.healthyGreen;
    if (level <= 6) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  List<Map<String, dynamic>> _getAgeAdaptedTools(LifeStage stage) {
    final tools = <Map<String, dynamic>>[];

    switch (stage) {
      case LifeStage.teen:
        tools.addAll([
          {
            'title': 'Teen Stress Management',
            'description': 'Manage academic pressure and social stress',
            'icon': Icons.school,
            'color': const Color(0xFF06B6D4),
          },
          {
            'title': 'Digital Detox',
            'description': 'Reduce stress from social media and screen time',
            'icon': Icons.phone,
            'color': const Color(0xFF6366F1),
          },
        ]);
        break;
      case LifeStage.youngAdult:
        tools.addAll([
          {
            'title': 'Work-Life Balance',
            'description': 'Manage career and personal life stress',
            'icon': Icons.work,
            'color': const Color(0xFF0D9488),
          },
          {
            'title': 'Financial Wellness',
            'description': 'Reduce financial stress with planning tools',
            'icon': Icons.attach_money,
            'color': const Color(0xFF10B981),
          },
        ]);
        break;
      case LifeStage.adult:
        tools.addAll([
          {
            'title': 'Career Stress Management',
            'description': 'Professional stress and burnout prevention',
            'icon': Icons.business_center,
            'color': const Color(0xFF6366F1),
          },
          {
            'title': 'Parenting Stress',
            'description': 'Manage stress of raising children',
            'icon': Icons.family_restroom,
            'color': const Color(0xFF8B5CF6),
          },
        ]);
        break;
      case LifeStage.midLife:
        tools.addAll([
          {
            'title': 'Midlife Transition Support',
            'description': 'Navigate life changes and career transitions',
            'icon': Icons.transform,
            'color': const Color(0xFF8B5CF6),
          },
          {
            'title': 'Health Anxiety Management',
            'description': 'Cope with health-related stress and anxiety',
            'icon': Icons.health_and_safety,
            'color': const Color(0xFFF59E0B),
          },
        ]);
        break;
      case LifeStage.olderAdult:
        tools.addAll([
          {
            'title': 'Retirement Transition',
            'description': 'Adjust to retirement and lifestyle changes',
            'icon': Icons.beach_access,
            'color': const Color(0xFFF59E0B),
          },
          {
            'title': 'Caregiving Support',
            'description': 'Manage stress of caring for loved ones',
            'icon': Icons.volunteer_activism,
            'color': const Color(0xFFEC4899),
          },
        ]);
        break;
      case LifeStage.senior:
        tools.addAll([
          {
            'title': 'Senior Wellness',
            'description': 'Maintain mental health in senior years',
            'icon': Icons.self_improvement,
            'color': const Color(0xFFEC4899),
          },
          {
            'title': 'Mobility & Exercise',
            'description': 'Gentle exercises for senior stress relief',
            'icon': Icons.directions_walk,
            'color': const Color(0xFF06B6D4),
          },
        ]);
        break;
    }

    tools.addAll([
      {
        'title': 'Guided Breathing',
        'description': 'Quick 5-minute breathing exercise',
        'icon': Icons.air,
        'color': const Color(0xFF06B6D4),
      },
      {
        'title': 'Mindfulness Meditation',
        'description': '10-minute mindfulness practice',
        'icon': Icons.self_improvement,
        'color': const Color(0xFF6366F1),
      },
    ]);

    return tools;
  }
}
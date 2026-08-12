import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/bloc/mental_wellness/guided_exercise_bloc/guided_exercise_bloc.dart';
import '../../../core/models/mental_wellness/guided_exercise.dart';
import '../../../core/theme/app_theme.dart';

class GuidedExercisePlayerScreen extends StatefulWidget {
  final String exerciseId;

  const GuidedExercisePlayerScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  State<GuidedExercisePlayerScreen> createState() => _GuidedExercisePlayerScreenState();
}

class _GuidedExercisePlayerScreenState extends State<GuidedExercisePlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    context.read<GuidedExerciseBloc>().add(
      LoadGuidedExerciseByIdEvent(exerciseId: widget.exerciseId),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _goBack() {
    context.go('/exercises');
  }

  Future<void> _toggleAudio(String? url) async {
    if (url == null) return;

    if (_isAudioPlaying) {
      await _audioPlayer.pause();
      setState(() => _isAudioPlaying = false);
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() => _isAudioPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Exercise Player'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: BlocConsumer<GuidedExerciseBloc, GuidedExerciseState>(
        listener: (context, state) {
          if (state is ExerciseCompletedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Exercise completed! Great job!'),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.go('/exercises');
              }
            });
          }
          if (state is ExerciseErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExerciseLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExercisePlayerState) {
            return _buildPlayerContent(context, state);
          }

          if (state is ExercisePausedState) {
            return _buildPausedContent(context, state);
          }

          if (state is ExerciseCompletedState) {
            return _buildCompletedContent(context, state);
          }

          return const Center(child: Text('Loading exercise...'));
        },
      ),
    );
  }

  Widget _buildPlayerContent(BuildContext context, ExercisePlayerState state) {
    final exercise = state.exercise;
    final progress = state.exercise.steps.isNotEmpty
        ? (state.currentStep + 1) / state.exercise.steps.length
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: exercise.type.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  exercise.type.icon,
                  color: exercise.type.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${exercise.type.displayName} • ${exercise.durationMinutes} min',
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.borderLight,
            color: AppTheme.primaryTeal,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${state.currentStep + 1} of ${exercise.steps.length}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                _formatDuration(state.elapsedTime),
                style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryTeal,
                      radius: 16,
                      child: Text(
                        '${state.currentStep + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Current Step',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  exercise.steps[state.currentStep],
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (exercise.steps.length > 1) ...[
            const Text(
              'All Steps',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...exercise.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isCompleted = index < state.currentStep;
              final isCurrent = index == state.currentStep;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppTheme.primaryTeal.withOpacity(0.1)
                      : isCompleted
                          ? AppTheme.healthyGreen.withOpacity(0.05)
                          : AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? AppTheme.primaryTeal
                        : AppTheme.borderLight,
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isCompleted
                          ? AppTheme.healthyGreen
                          : isCurrent
                              ? AppTheme.primaryTeal
                              : AppTheme.borderLight,
                      radius: 12,
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : AppTheme.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          color: isCompleted
                              ? AppTheme.textMuted
                              : AppTheme.textDark,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 24),

          if (exercise.audioUrl != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppTheme.primaryTeal,
                      size: 32,
                    ),
                    onPressed: () => _toggleAudio(exercise.audioUrl),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audio Guidance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Listen along with the exercise',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _isAudioPlaying ? 'Playing' : 'Paused',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isAudioPlaying ? AppTheme.healthyGreen : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.currentStep > 0
                      ? () {
                          context.read<GuidedExerciseBloc>().add(
                            TrackExerciseStepEvent(
                              stepIndex: state.currentStep - 1,
                            ),
                          );
                        }
                      : null,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: state.currentStep < exercise.steps.length - 1
                      ? () {
                          context.read<GuidedExerciseBloc>().add(
                            TrackExerciseStepEvent(
                              stepIndex: state.currentStep + 1,
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    state.currentStep < exercise.steps.length - 1
                        ? 'Next Step'
                        : 'Complete Exercise',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (state.isPlaying) {
                  context.read<GuidedExerciseBloc>().add(
                    PauseGuidedExerciseEvent(),
                  );
                } else {
                  context.read<GuidedExerciseBloc>().add(
                    ResumeGuidedExerciseEvent(),
                  );
                }
              },
              icon: Icon(
                state.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              label: Text(state.isPlaying ? 'Pause' : 'Resume'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _goBack,
              child: const Text('Exit Exercise'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPausedContent(BuildContext context, ExercisePausedState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pause_circle_outline,
              size: 80,
              color: AppTheme.warningOrange,
            ),
            const SizedBox(height: 24),
            Text(
              'Exercise Paused',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.exercise.title,
              style: const TextStyle(fontSize: 18, color: AppTheme.textMedium),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${state.currentStep + 1} of ${state.exercise.steps.length}',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    context.read<GuidedExerciseBloc>().add(
                      ResumeGuidedExerciseEvent(),
                    );
                  },
                  child: const Text('Resume'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<GuidedExerciseBloc>().add(
                      const CompleteGuidedExerciseEvent(),
                    );
                  },
                  child: const Text('Complete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedContent(BuildContext context, ExerciseCompletedState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: AppTheme.healthyGreen,
            ),
            const SizedBox(height: 24),
            Text(
              'Exercise Complete!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.exercise.title,
              style: const TextStyle(fontSize: 18, color: AppTheme.textMedium),
            ),
            const SizedBox(height: 16),
            Text(
              'Time: ${_formatDuration(state.totalTime)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _goBack,
                  child: const Text('Done'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _showRatingDialog(context, state.exercise);
                  },
                  child: const Text('Rate Exercise'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showRatingDialog(BuildContext context, GuidedExercise exercise) {
    showDialog(
      context: context,
      builder: (context) {
        int rating = 0;
        return AlertDialog(
          title: const Text('Rate This Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How was the ${exercise.title}?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() => rating = index + 1);
                    },
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: rating > 0
                  ? () {
                      context.read<GuidedExerciseBloc>().add(
                        CompleteGuidedExerciseEvent(rating: rating),
                      );
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
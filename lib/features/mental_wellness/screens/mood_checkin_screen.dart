import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/bloc/mental_wellness/mood_bloc/mood_bloc.dart';
import '../../../core/bloc/mental_wellness/risk_detection_bloc/risk_detection_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/mood_rating_selector.dart';
import '../widgets/phq2_questionnaire.dart';
import '../widgets/gad2_questionnaire.dart';

class MoodCheckinScreen extends StatefulWidget {
  final String userId;

  const MoodCheckinScreen({super.key, required this.userId});

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> {
  int _currentStep = 0;
  int? _moodRating;
  int? _phq2Score;
  int? _gad2Score;
  String? _notes;
  List<String> _triggers = [];
  final TextEditingController _notesController = TextEditingController();

  final List<String> _availableTriggers = [
    'Stress',
    'Sleep',
    'Relationships',
    'Work',
    'Health',
    'Nutrition',
    'Exercise',
    'Financial',
    'Other',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _goBack() {
    context.go('/wellness?userId=${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Mood Check-in',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        actions: [
          if (_currentStep < 4)
            TextButton(
              onPressed: _goBack,
              child: const Text('Skip'),
            ),
        ],
      ),
      body: BlocConsumer<MoodBloc, MoodState>(
        listener: (context, state) {
          if (state is MoodCheckinCompletedState) {
            context.read<RiskDetectionBloc>().add(
              CheckMoodRisksEvent(userId: widget.userId),
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mood check-in saved successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.go('/wellness?userId=${widget.userId}');
              }
            });
          }
          if (state is MoodErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.dangerRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MoodSubmittingState) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving your check-in...'),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildStepContent(),
                ),
                const SizedBox(height: 16),
                _buildNavigationButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: index <= _currentStep
                ? AppTheme.primaryTeal
                : AppTheme.borderLight,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return MoodRatingSelector(
          selectedRating: _moodRating,
          onRatingSelected: (rating) {
            setState(() => _moodRating = rating);
          },
        );
      case 1:
        return PHQ2Questionnaire(
          onScoreCalculated: (score) {
            setState(() => _phq2Score = score);
          },
        );
      case 2:
        return GAD2Questionnaire(
          onScoreCalculated: (score) {
            setState(() => _gad2Score = score);
          },
        );
      case 3:
        return _buildTriggersAndNotesStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTriggersAndNotesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What contributed to your mood today?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select all that apply',
          style: TextStyle(color: AppTheme.textMedium),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTriggers.map((trigger) {
            final isSelected = _triggers.contains(trigger);
            return FilterChip(
              label: Text(trigger),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _triggers.add(trigger);
                  } else {
                    _triggers.remove(trigger);
                  }
                });
              },
              selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
              backgroundColor: AppTheme.surfaceWhite,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Any additional notes?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: 'How are you feeling? Share any thoughts...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) => _notes = value,
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final isStepValid = _isStepValid();

    return Row(
      children: [
        if (_currentStep < 3)
          Expanded(
            child: ElevatedButton(
              onPressed: isStepValid
                  ? () => setState(() => _currentStep++)
                  : null,
              child: const Text('Continue'),
            ),
          ),
        if (_currentStep == 3)
          Expanded(
            child: ElevatedButton(
              onPressed: isStepValid
                  ? () {
                      context.read<MoodBloc>().add(
                        SubmitMoodEntryEvent(
                          userId: widget.userId,
                          moodRating: _moodRating ?? 5,
                          phq2Score: _phq2Score,
                          gad2Score: _gad2Score,
                          notes: _notes,
                          triggers: _triggers,
                          context: {
                            'checkin_type': 'full',
                            'source': 'manual',
                          },
                        ),
                      );
                    }
                  : null,
              child: const Text('Complete Check-in'),
            ),
          ),
      ],
    );
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0:
        return _moodRating != null;
      case 1:
        return _phq2Score != null;
      case 2:
        return _gad2Score != null;
      case 3:
        return true;
      default:
        return false;
    }
  }
}
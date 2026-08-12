import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GAD2Questionnaire extends StatefulWidget {
  final Function(int) onScoreCalculated;

  const GAD2Questionnaire({
    super.key,
    required this.onScoreCalculated,
  });

  @override
  State<GAD2Questionnaire> createState() => _GAD2QuestionnaireState();
}

class _GAD2QuestionnaireState extends State<GAD2Questionnaire> {
  int _question1 = -1; // Feeling nervous, anxious, or on edge
  int _question2 = -1; // Unable to stop or control worrying

  final List<String> _options = [
    'Not at all',
    'Several days',
    'More than half the days',
    'Nearly every day',
  ];

  void _updateScore() {
    if (_question1 >= 0 && _question2 >= 0) {
      final score = _question1 + _question2;
      widget.onScoreCalculated(score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GAD-2 Anxiety Screening',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Over the past 2 weeks, how often have you been bothered by the following problems?',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 24),
        _buildQuestion(
          '1. Feeling nervous, anxious, or on edge',
          _question1,
          (value) {
            setState(() {
              _question1 = value;
              _updateScore();
            });
          },
        ),
        const SizedBox(height: 24),
        _buildQuestion(
          '2. Unable to stop or control worrying',
          _question2,
          (value) {
            setState(() {
              _question2 = value;
              _updateScore();
            });
          },
        ),
        if (_question1 >= 0 && _question2 >= 0)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: _buildScoreResult(),
          ),
      ],
    );
  }

  Widget _buildQuestion(String question, int selectedValue, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _options.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isSelected = selectedValue == index;

            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onChanged(index);
              },
              selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
              backgroundColor: AppTheme.surfaceSubtle,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryTeal : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScoreResult() {
    final score = _question1 + _question2;
    String interpretation;
    Color color;

    if (score <= 1) {
      interpretation = 'Low anxiety risk. Keep monitoring your mood.';
      color = AppTheme.healthyGreen;
    } else if (score == 2) {
      interpretation = 'Moderate anxiety risk. Consider follow-up screening.';
      color = AppTheme.warningOrange;
    } else {
      interpretation = 'High anxiety risk. Consider speaking with a mental health professional.';
      color = AppTheme.dangerRed;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              score.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              interpretation,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
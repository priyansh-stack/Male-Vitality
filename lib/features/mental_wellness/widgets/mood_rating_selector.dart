import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MoodRatingSelector extends StatelessWidget {
  final int? selectedRating;
  final Function(int) onRatingSelected;

  const MoodRatingSelector({
    super.key,
    this.selectedRating,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you feeling today?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select your mood on a scale of 1-10',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              final rating = index + 1;
              final isSelected = selectedRating == rating;
              final color = _getMoodColor(rating);

              return GestureDetector(
                onTap: () => onRatingSelected(rating),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : AppTheme.borderLight,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      Text(
                        _getMoodLabel(rating),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (selectedRating != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getMoodColor(selectedRating!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Selected: ${selectedRating} - ${_getMoodLabel(selectedRating!)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getMoodColor(selectedRating!),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getMoodColor(int rating) {
    if (rating >= 8) return AppTheme.healthyGreen;
    if (rating >= 6) return AppTheme.primaryTeal;
    if (rating >= 4) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String _getMoodLabel(int rating) {
    if (rating >= 9) return 'Amazing';
    if (rating >= 7) return 'Good';
    if (rating >= 5) return 'Okay';
    if (rating >= 3) return 'Low';
    return 'Terrible';
  }
}
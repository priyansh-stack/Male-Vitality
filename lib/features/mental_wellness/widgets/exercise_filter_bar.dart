import 'package:flutter/material.dart';
import '../../../core/models/mental_wellness/guided_exercise.dart';
import '../../../core/models/life_stage.dart';
import '../../../core/theme/app_theme.dart';

class ExerciseFilterBar extends StatelessWidget {
  final ExerciseType? selectedType;
  final LifeStage? selectedAgeGroup;
  final Function(ExerciseType?) onTypeChanged;
  final Function(LifeStage?) onAgeGroupChanged;
  final VoidCallback onClearFilters;

  const ExerciseFilterBar({
    super.key,
    this.selectedType,
    this.selectedAgeGroup,
    required this.onTypeChanged,
    required this.onAgeGroupChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Exercises',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (selectedType != null || selectedAgeGroup != null)
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  selected: selectedType == null && selectedAgeGroup == null,
                  onTap: () {
                    onTypeChanged(null);
                    onAgeGroupChanged(null);
                  },
                ),
                const SizedBox(width: 4),
                ...ExerciseType.values.map((type) {
                  return _buildFilterChip(
                    label: type.displayName,
                    selected: selectedType == type,
                    onTap: () => onTypeChanged(type),
                    color: type.color,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Age: ',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                ...LifeStage.values.map((stage) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: FilterChip(
                      label: Text(
                        stage.name,
                        style: const TextStyle(fontSize: 10),
                      ),
                      selected: selectedAgeGroup == stage,
                      onSelected: (selected) {
                        if (selected) {
                          onAgeGroupChanged(stage);
                        } else {
                          onAgeGroupChanged(null);
                        }
                      },
                      selectedColor: stage.badgeColor.withOpacity(0.2),
                      backgroundColor: AppTheme.surfaceSubtle,
                      labelStyle: TextStyle(
                        color: selectedAgeGroup == stage
                            ? stage.badgeColor
                            : AppTheme.textMuted,
                        fontWeight: selectedAgeGroup == stage
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilterChip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: (color ?? AppTheme.primaryTeal).withOpacity(0.2),
        backgroundColor: AppTheme.surfaceSubtle,
        labelStyle: TextStyle(
          color: selected ? (color ?? AppTheme.primaryTeal) : AppTheme.textMuted,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
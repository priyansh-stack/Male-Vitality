import 'package:flutter/material.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';
import '../../../core/theme/app_theme.dart';

class TodayFocusCard extends StatelessWidget {
  final TodayFocus focus;
  final Function(FocusAction)? onActionTap;

  const TodayFocusCard({
    Key? key,
    required this.focus,
    this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  focus.type.icon,
                  color: _getPriorityColor(focus.priority),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    focus.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildPriorityBadge(focus.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              focus.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            if (focus.actions.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: focus.actions.map((action) {
                  return _buildActionButton(action);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(FocusAction action) {
    return OutlinedButton.icon(
      onPressed: () => onActionTap?.call(action),
      icon: Icon(action.icon, size: 16),
      label: Text(action.label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(int priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        'Priority ${priority > 3 ? 'High' : priority > 2 ? 'Medium' : 'Normal'}',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 4) return AppTheme.dangerRed;
    if (priority >= 3) return AppTheme.warningOrange;
    if (priority >= 2) return AppTheme.infoBlue;
    return AppTheme.healthyGreen;
  }
}
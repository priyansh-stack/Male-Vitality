import 'package:flutter/material.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';
import '../../../core/theme/app_theme.dart';

class TodayFocusCard extends StatelessWidget {
  final TodayFocus focus;
  final Function(FocusAction)? onActionTap;

  const TodayFocusCard({
    super.key,
    required this.focus,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(focus.priority);

    return Container(
      decoration: AppTheme.cyberCardDecoration(
        borderColor: priorityColor.withOpacity(0.4),
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: priorityColor.withOpacity(0.4)),
                ),
                child: Icon(
                  focus.type.icon,
                  color: priorityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY HEALTH DIRECTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: priorityColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      focus.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPriorityBadge(focus.priority, priorityColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            focus.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
          if (focus.actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: focus.actions.map((action) {
                return _buildActionButton(action);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(FocusAction action) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyberCyan.withOpacity(0.25),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => onActionTap?.call(action),
        icon: Icon(action.icon, size: 14, color: Colors.white),
        label: Text(
          action.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.cyberCyan,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(int priority, Color color) {
    final label = priority >= 4 ? 'CRITICAL' : priority >= 3 ? 'ELEVATED' : 'STANDARD';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 4) return AppTheme.neonRed;
    if (priority >= 3) return AppTheme.neonAmber;
    if (priority >= 2) return AppTheme.cyberCyan;
    return AppTheme.bioEmerald;
  }
}
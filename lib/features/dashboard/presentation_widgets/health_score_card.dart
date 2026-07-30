import 'package:flutter/material.dart';
import '../../../core/models/health_score.dart';
import '../../../core/models/health_enums.dart';
import '../../../core/theme/app_theme.dart';

class HealthScoreCard extends StatelessWidget {
  final HealthScore healthScore;
  final VoidCallback? onTap;

  const HealthScoreCard({
    Key? key,
    required this.healthScore,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Vitality',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Icon(Icons.info_outline, size: 20, color: AppTheme.textMuted),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildScoreCircle(context),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          healthScore.status.displayname,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _getStatusColor(healthScore.score),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on ${healthScore.categoryScores.length} health metrics',
                          style: const TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: healthScore.categoryScores.entries
                              .take(3)
                              .map((entry) => _buildCategoryChip(entry))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (healthScore.recommendations.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.primaryTeal,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Insight',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              healthScore.recommendations.first,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context) {
    final score = healthScore.score;
    final color = _getStatusColor(score);

    return SizedBox(
      width: 85,
      height: 85,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 8,
            backgroundColor: AppTheme.surfaceSubtle,
            color: color,
            strokeCap: StrokeCap.round,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(MapEntry<HealthCategory, int> entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${_getCategoryShortName(entry.key)}: ${entry.value}',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMedium),
      ),
    );
  }

  Color _getStatusColor(int score) {
    if (score >= 80) return AppTheme.healthyGreen;
    if (score >= 60) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String _getCategoryShortName(HealthCategory category) {
    switch (category) {
      case HealthCategory.activity: return 'Activity';
      case HealthCategory.sleep: return 'Sleep';
      case HealthCategory.nutrition: return 'Nutrition';
      case HealthCategory.screening: return 'Screening';
      case HealthCategory.mental: return 'Mental';
      case HealthCategory.cardioVascular: return 'Cardio';
      case HealthCategory.metabolic: return 'Metabolic';
    }
  }
}
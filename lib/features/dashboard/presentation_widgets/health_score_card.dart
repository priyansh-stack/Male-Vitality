import 'package:flutter/material.dart';
import '../../../core/models/health_score.dart';
import '../../../core/models/health_enums.dart';
import '../../../core/theme/app_theme.dart';

class HealthScoreCard extends StatelessWidget {
  final HealthScore healthScore;
  final VoidCallback? onTap;

  const HealthScoreCard({
    super.key,
    required this.healthScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(healthScore.score);

    return Container(
      decoration: AppTheme.cyberCardDecoration(
        borderColor: statusColor.withOpacity(0.35),
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
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DAILY VITALITY INDEX',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.cyberCyan,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.info_outline, size: 18, color: AppTheme.textMuted),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _buildScoreCircle(context, statusColor),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          healthScore.status.displayname.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Calibrated from comprehensive male vitality & biometric streams',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: healthScore.categoryScores.entries
                              .take(4)
                              .map((entry) => _buildCategoryChip(entry))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (healthScore.recommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.cyberCyan.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.cyberCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppTheme.cyberCyan,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CLINICAL HEALTH SUMMARY',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.cyberCyan,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              healthScore.recommendations.first,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                height: 1.4,
                              ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context, Color statusColor) {
    final score = healthScore.score;

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: AppTheme.darkBorder,
              color: statusColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'VITALITY',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.0,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getCategoryShortName(entry.key),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
          ),
          const SizedBox(width: 4),
          Text(
            '${entry.value}',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.cyberCyan),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int score) {
    if (score >= 80) return AppTheme.bioEmerald;
    if (score >= 60) return AppTheme.neonAmber;
    return AppTheme.cyberCyan;
  }

  String _getCategoryShortName(HealthCategory category) {
    switch (category) {
      case HealthCategory.activity: return 'Activity';
      case HealthCategory.sleep: return 'Sleep';
      case HealthCategory.nutrition: return 'Nutrition';
      case HealthCategory.screening: return 'Screening';
      case HealthCategory.mental: return 'Mind';
      case HealthCategory.cardioVascular: return 'Cardio';
      case HealthCategory.metabolic: return 'Metabolic';
    }
  }
}
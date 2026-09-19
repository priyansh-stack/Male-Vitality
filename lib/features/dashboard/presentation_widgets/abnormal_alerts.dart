import 'package:flutter/material.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';
import '../../../core/theme/app_theme.dart';

class AbnormalAlerts extends StatelessWidget {
  final List<AbnormalMetrices> alerts;
  final Function(AbnormalMetrices) onAlertTap;

  const AbnormalAlerts({
    super.key,
    required this.alerts,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: AppTheme.cyberCardDecoration(
        borderColor: AppTheme.neonCrimson.withOpacity(0.55),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.neonCrimson,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonCrimson,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'CLINICAL SENTINEL ALERTS (${alerts.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neonCrimson,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...alerts.take(3).map((alert) => _buildAlertItem(alert)),
          if (alerts.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '+ ${alerts.length - 3} additional abnormal markers recorded',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(AbnormalMetrices alert) {
    final sevColor = _getSeverityColor(alert.alertSevirity);

    return InkWell(
      onTap: () => onAlertTap(alert),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.obsidianCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.obsidianBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sevColor,
                boxShadow: [
                  BoxShadow(
                    color: sevColor,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.alertmessage,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (alert.recommendation != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      alert.recommendation!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMuted.withOpacity(0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSevirity severity) {
    switch (severity) {
      case AlertSevirity.info:
        return AppTheme.neonCyan;
      case AlertSevirity.low:
        return AppTheme.neonEmerald;
      case AlertSevirity.medium:
        return AppTheme.neonAmber;
      case AlertSevirity.high:
      case AlertSevirity.critical:
        return AppTheme.neonCrimson;
    }
  }
}
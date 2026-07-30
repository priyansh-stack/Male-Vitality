import 'package:flutter/material.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';
import 'package:life_stage_health_app/core/models/supporting_health_classes.dart';

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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Health Alerts (${alerts.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.take(3).map((alert) => _buildAlertItem(alert)),
            if (alerts.length > 3)
              TextButton(
                onPressed: () {
                  // Show all alerts
                },
                child: Text('View all ${alerts.length} alerts'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(AbnormalMetrices alert) {
    return InkWell(
      onTap: () => onAlertTap(alert),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getSeverityColor(alert.alertSevirity),
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
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (alert.recommendation != null)
                    Text(
                      alert.recommendation!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSevirity severity) {
    switch (severity) {
      case AlertSevirity.info:
        return Colors.blue;
      case AlertSevirity.low:
        return Colors.green;
      case AlertSevirity.medium:
        return Colors.orange;
      case AlertSevirity.high:
        return Colors.red.shade400;
      case AlertSevirity.critical:
        return Colors.red.shade900;
    }
  }
}
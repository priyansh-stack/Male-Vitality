import 'package:flutter/material.dart';
import '../../../core/models/mental_wellness/risk_alert.dart';
import '../../../core/theme/app_theme.dart';

class RiskAlertBanner extends StatelessWidget {
  final RiskAlert alert;
  final VoidCallback onAcknowledge;
  final VoidCallback onGetHelp;

  const RiskAlertBanner({
    super.key,
    required this.alert,
    required this.onAcknowledge,
    required this.onGetHelp,
  });

  @override
  Widget build(BuildContext context) {
    final color = alert.severity.color;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  alert.severity == RiskSeverity.critical
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alert.type.displayName} Alert',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Severity: ${alert.severity.displayName}',
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (alert.requiresImmediateAction)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          if (alert.recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'What you can do:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...alert.recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAcknowledge,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color),
                  ),
                  child: Text(
                    alert.requiresImmediateAction
                        ? 'I Understand'
                        : 'Acknowledge',
                    style: TextStyle(color: color),
                  ),
                ),
              ),
              if (alert.requiresImmediateAction) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onGetHelp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Get Help Now'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
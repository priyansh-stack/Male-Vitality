  import 'package:flutter/material.dart';
  import 'package:life_stage_health_app/core/models/health_enums.dart';
  import 'package:life_stage_health_app/core/models/health_metric.dart';

  class TodayFocus{
    final String title;
    final String description;
    final FocusType type;
    final int priority;
    final List<FocusAction> actions;
    final String? metricId;
    final DateTime time;

    const TodayFocus({
      required this.title,
      required this.description,
      required this.type,
      required this.priority,
      required this.actions,
      this.metricId,
      required this.time,
    });
  }

  class FocusAction {
    final String label;
    final String action;
    final IconData icon;

    const FocusAction({
      required this.label,
      required this.action,
      required this.icon
    });
  }

  class AbnormalMetrices {
    final HealthMetric metric;
    final String alertmessage;
    final AlertSevirity alertSevirity;
    final String? recommendation;
    final String category;

    const AbnormalMetrices({
      required this.metric,
      required this.alertmessage,
      required this.alertSevirity,
      this.recommendation,
      required this.category,
    });

  }
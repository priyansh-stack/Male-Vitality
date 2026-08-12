part of 'risk_detection_bloc.dart';


enum RiskLevel { low, moderate, high, critical }

abstract class RiskDetectionState extends Equatable {
  const RiskDetectionState();
  @override
  List<Object?> get props => [];
}

class RiskInitialState extends RiskDetectionState {}

class RiskScanningState extends RiskDetectionState {}

class RiskAnalyzedState extends RiskDetectionState {
  final List<RiskAlert> activeAlerts;
  final List<RiskAlert> historicalAlerts;
  final RiskLevel overallRiskLevel;
  final Map<String, double> riskScores;

  const RiskAnalyzedState({
    required this.activeAlerts,
    required this.historicalAlerts,
    required this.overallRiskLevel,
    required this.riskScores,
  });

  @override
  List<Object> get props => [activeAlerts, historicalAlerts, overallRiskLevel, riskScores];
}

class RiskAlertTriggeredState extends RiskDetectionState {
  final RiskAlert alert;
  final bool requiresImmediateAction;

  const RiskAlertTriggeredState({
    required this.alert,
    this.requiresImmediateAction = false,
  });

  @override
  List<Object> get props => [alert, requiresImmediateAction];
}

class RiskAlertAcknowledgedState extends RiskDetectionState {
  final String alertId;

  const RiskAlertAcknowledgedState({required this.alertId});

  @override
  List<Object> get props => [alertId];
}

class RiskEscalatedState extends RiskDetectionState {
  final String alertId;

  const RiskEscalatedState({required this.alertId});

  @override
  List<Object> get props => [alertId];
}

class RiskErrorState extends RiskDetectionState {
  final String message;

  const RiskErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
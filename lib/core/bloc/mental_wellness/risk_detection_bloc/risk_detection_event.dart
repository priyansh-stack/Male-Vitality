part of 'risk_detection_bloc.dart';


abstract class RiskDetectionEvent extends Equatable {
  const RiskDetectionEvent();
  @override
  List<Object?> get props => [];
}

class CheckMoodRisksEvent extends RiskDetectionEvent {
  final String userId;

  const CheckMoodRisksEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class AcknowledgeRiskAlertEvent extends RiskDetectionEvent {
  final String alertId;

  const AcknowledgeRiskAlertEvent({required this.alertId});

  @override
  List<Object> get props => [alertId];
}

class GetRiskHistoryEvent extends RiskDetectionEvent {
  final String userId;

  const GetRiskHistoryEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class DismissRiskAlertEvent extends RiskDetectionEvent {
  final String alertId;

  const DismissRiskAlertEvent({required this.alertId});

  @override
  List<Object> get props => [alertId];
}

class EscalateRiskEvent extends RiskDetectionEvent {
  final String alertId;

  const EscalateRiskEvent({required this.alertId});

  @override
  List<Object> get props => [alertId];
}

class ClearRisksEvent extends RiskDetectionEvent {}
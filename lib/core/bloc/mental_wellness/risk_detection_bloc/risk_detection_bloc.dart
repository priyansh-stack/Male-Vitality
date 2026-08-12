import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/check_anxiety_risk_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/check_depression_risk_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/check_suicide_risk_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/detect_risk_patterns_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/generate_risk_alert_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_risk_history_usecase.dart';
import '../../../models/mental_wellness/risk_alert.dart';
part 'risk_detection_event.dart';
part 'risk_detection_state.dart';

class RiskDetectionBloc extends Bloc<RiskDetectionEvent, RiskDetectionState> {
  final DetectRiskPatternsUseCase detectRiskPatternsUseCase;
  final GetRiskHistoryUseCase getRiskHistoryUseCase;
  final GenerateRiskAlertUseCase generateRiskAlertUseCase;
  final CheckSuicideRiskUseCase checkSuicideRiskUseCase;
  final CheckDepressionRiskUseCase checkDepressionRiskUseCase;
  final CheckAnxietyRiskUseCase checkAnxietyRiskUseCase;

  RiskDetectionBloc({
    required this.detectRiskPatternsUseCase,
    required this.getRiskHistoryUseCase,
    required this.generateRiskAlertUseCase,
    required this.checkSuicideRiskUseCase,
    required this.checkDepressionRiskUseCase,
    required this.checkAnxietyRiskUseCase,
  }) : super(RiskInitialState()) {
    on<CheckMoodRisksEvent>(_onCheckMoodRisks);
    on<AcknowledgeRiskAlertEvent>(_onAcknowledgeRiskAlert);
    on<GetRiskHistoryEvent>(_onGetRiskHistory);
    on<DismissRiskAlertEvent>(_onDismissRiskAlert);
    on<EscalateRiskEvent>(_onEscalateRisk);
    on<ClearRisksEvent>(_onClearRisks);
  }

  Future<void> _onCheckMoodRisks(
    CheckMoodRisksEvent event,
    Emitter<RiskDetectionState> emit,
  ) async {
    emit(RiskScanningState());

    try {
      final depressionRisk = await checkDepressionRiskUseCase.execute(event.userId);
      final anxietyRisk = await checkAnxietyRiskUseCase.execute(event.userId);
      final suicideRisk = await checkSuicideRiskUseCase.execute(event.userId);

      final allRisks = [...depressionRisk, ...anxietyRisk, ...suicideRisk];

      if (allRisks.isNotEmpty) {
        final highRiskAlerts = allRisks.where(
          (r) => r.severity == RiskSeverity.high || r.severity == RiskSeverity.critical
        ).toList();

        if (highRiskAlerts.isNotEmpty) {
          for (final alert in highRiskAlerts) {
            emit(RiskAlertTriggeredState(
              alert: alert,
              requiresImmediateAction: alert.severity == RiskSeverity.critical,
            ));
          }
        } else {
          final riskScores = _calculateRiskScores(allRisks);
          emit(RiskAnalyzedState(
            activeAlerts: allRisks,
            historicalAlerts: await getRiskHistoryUseCase.execute(event.userId),
            overallRiskLevel: _calculateOverallRiskLevel(allRisks),
            riskScores: riskScores,
          ));
        }
      } else {
        emit(RiskAnalyzedState(
          activeAlerts: [],
          historicalAlerts: await getRiskHistoryUseCase.execute(event.userId),
          overallRiskLevel: RiskLevel.low,
          riskScores: {},
        ));
      }
    } catch (e) {
      emit(RiskErrorState(message: e.toString()));
    }
  }

  Future<void> _onAcknowledgeRiskAlert(
    AcknowledgeRiskAlertEvent event,
    Emitter<RiskDetectionState> emit,
  ) async {
    try {
      await generateRiskAlertUseCase.execute(
        alertId: event.alertId,
        acknowledged: true,
      );
      emit(RiskAlertAcknowledgedState(alertId: event.alertId));
    } catch (e) {
      emit(RiskErrorState(message: e.toString()));
    }
  }

  Future<void> _onGetRiskHistory(
    GetRiskHistoryEvent event,
    Emitter<RiskDetectionState> emit,
  ) async {
    try {
      final history = await getRiskHistoryUseCase.execute(event.userId);
      emit(RiskAnalyzedState(
        activeAlerts: history.where((a) => !a.acknowledged).toList(),
        historicalAlerts: history,
        overallRiskLevel: _calculateOverallRiskLevel(history),
        riskScores: _calculateRiskScores(history),
      ));
    } catch (e) {
      emit(RiskErrorState(message: e.toString()));
    }
  }

  Future<void> _onDismissRiskAlert(
    DismissRiskAlertEvent event,
    Emitter<RiskDetectionState> emit,
  ) async {
    try {
      await generateRiskAlertUseCase.execute(
        alertId: event.alertId,
        dismissed: true,
      );
      emit(RiskInitialState());
    } catch (e) {
      emit(RiskErrorState(message: e.toString()));
    }
  }

  Future<void> _onEscalateRisk(
    EscalateRiskEvent event,
    Emitter<RiskDetectionState> emit,
  ) async {
    try {
      await generateRiskAlertUseCase.execute(
        alertId: event.alertId,
        escalated: true,
      );
      emit(RiskEscalatedState(alertId: event.alertId));
    } catch (e) {
      emit(RiskErrorState(message: e.toString()));
    }
  }

  void _onClearRisks(
    ClearRisksEvent event,
    Emitter<RiskDetectionState> emit,
  ) {
    emit(RiskInitialState());
  }

  RiskLevel _calculateOverallRiskLevel(List<RiskAlert> alerts) {
    if (alerts.any((a) => a.severity == RiskSeverity.critical)) {
      return RiskLevel.critical;
    }
    if (alerts.any((a) => a.severity == RiskSeverity.high)) {
      return RiskLevel.high;
    }
    if (alerts.any((a) => a.severity == RiskSeverity.moderate)) {
      return RiskLevel.moderate;
    }
    return RiskLevel.low;
  }

  Map<String, double> _calculateRiskScores(List<RiskAlert> alerts) {
    final scores = <String, double>{};
    for (final alert in alerts) {
      scores[alert.type.displayName] = _getRiskScore(alert.severity);
    }
    return scores;
  }

  double _getRiskScore(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.low:
        return 0.25;
      case RiskSeverity.moderate:
        return 0.5;
      case RiskSeverity.high:
        return 0.75;
      case RiskSeverity.critical:
        return 1.0;
    }
  }
}
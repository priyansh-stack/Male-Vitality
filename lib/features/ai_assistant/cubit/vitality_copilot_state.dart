import 'package:equatable/equatable.dart';
import '../services/vitality_gemini_service.dart';

enum VitalityCopilotStatus { initial, loading, success, failure }

class VitalityCopilotState extends Equatable {
  final VitalityCopilotStatus status;
  final List<ChatMessage> messages;
  final bool hasApiKey;
  final bool isProModel;
  final String? errorMessage;
  final bool hasEmergencyAlert;
  final String? activeEmergencyMessage;

  const VitalityCopilotState({
    this.status = VitalityCopilotStatus.initial,
    this.messages = const [],
    this.hasApiKey = false,
    this.isProModel = false,
    this.errorMessage,
    this.hasEmergencyAlert = false,
    this.activeEmergencyMessage,
  });

  VitalityCopilotState copyWith({
    VitalityCopilotStatus? status,
    List<ChatMessage>? messages,
    bool? hasApiKey,
    bool? isProModel,
    String? errorMessage,
    bool? hasEmergencyAlert,
    String? activeEmergencyMessage,
  }) {
    return VitalityCopilotState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      isProModel: isProModel ?? this.isProModel,
      errorMessage: errorMessage,
      hasEmergencyAlert: hasEmergencyAlert ?? this.hasEmergencyAlert,
      activeEmergencyMessage: activeEmergencyMessage ?? this.activeEmergencyMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        hasApiKey,
        isProModel,
        errorMessage,
        hasEmergencyAlert,
        activeEmergencyMessage,
      ];
}

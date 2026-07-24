import 'package:equatable/equatable.dart';

abstract class HealthSyncEvent extends Equatable {
  const HealthSyncEvent();

  @override
  List<Object?> get props => [];
}

class RequestAppleHealthEvent extends HealthSyncEvent {
  final String uid;
  const RequestAppleHealthEvent(this.uid);

  @override
  List<Object?> get props => [uid];
}

class RequestGoogleFitEvent extends HealthSyncEvent {
  final String uid;
  const RequestGoogleFitEvent(this.uid);

  @override
  List<Object?> get props => [uid];
}

class ToggleNotificationsEvent extends HealthSyncEvent {
  final bool enabled;
  const ToggleNotificationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

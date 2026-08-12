part of 'crisis_resource_bloc.dart';


abstract class CrisisResourceEvent extends Equatable {
  const CrisisResourceEvent();
  @override
  List<Object?> get props => [];
}

class LoadCrisisResourcesEvent extends CrisisResourceEvent {
  final String? location;

  const LoadCrisisResourcesEvent({this.location});

  @override
  List<Object?> get props => [location];
}

class LoadLocalEmergencyServicesEvent extends CrisisResourceEvent {
  final String location;

  const LoadLocalEmergencyServicesEvent({required this.location});

  @override
  List<Object> get props => [location];
}

class LoadNationalHotlinesEvent extends CrisisResourceEvent {}

class TriggerEmergencyProtocolEvent extends CrisisResourceEvent {
  final String userId;

  const TriggerEmergencyProtocolEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class CallCrisisLifelineEvent extends CrisisResourceEvent {
  final String phoneNumber;

  const CallCrisisLifelineEvent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class SendCrisisTextEvent extends CrisisResourceEvent {
  final String textNumber;
  final String message;

  const SendCrisisTextEvent({
    required this.textNumber,
    this.message = 'HOME',
  });

  @override
  List<Object> get props => [textNumber, message];
}

class DismissCrisisAlertEvent extends CrisisResourceEvent {}

class AddCustomCrisisResourceEvent extends CrisisResourceEvent {
  final Map<String, dynamic> resourceData;

  const AddCustomCrisisResourceEvent({required this.resourceData});

  @override
  List<Object> get props => [resourceData];
}
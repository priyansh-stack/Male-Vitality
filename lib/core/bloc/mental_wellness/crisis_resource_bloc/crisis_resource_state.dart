part of 'crisis_resource_bloc.dart';


abstract class CrisisResourceState extends Equatable {
  const CrisisResourceState();
  @override
  List<Object?> get props => [];
}

class CrisisInitialState extends CrisisResourceState {}

class CrisisLoadingState extends CrisisResourceState {
  final String? message;
  const CrisisLoadingState({this.message});
  @override
  List<Object?> get props => [message];
}

class CrisisResourcesLoadedState extends CrisisResourceState {
  final List<CrisisResource> nationalResources;
  final List<CrisisResource> localResources;
  final List<EmergencyService> emergencyServices;

  const CrisisResourcesLoadedState({
    required this.nationalResources,
    required this.localResources,
    required this.emergencyServices,
  });

  @override
  List<Object> get props => [nationalResources, localResources, emergencyServices];
}

class LocalServicesLoadedState extends CrisisResourceState {
  final List<EmergencyService> services;

  const LocalServicesLoadedState({required this.services});

  @override
  List<Object> get props => [services];
}

class NationalHotlinesLoadedState extends CrisisResourceState {
  final List<CrisisResource> hotlines;

  const NationalHotlinesLoadedState({required this.hotlines});

  @override
  List<Object> get props => [hotlines];
}

class EmergencyProtocolTriggeredState extends CrisisResourceState {
  final String message;
  final List<String> steps;

  const EmergencyProtocolTriggeredState({
    required this.message,
    this.steps = const [],
  });

  @override
  List<Object> get props => [message, steps];
}

class CrisisLifelineConnectedState extends CrisisResourceState {
  final String number;
  final bool isText;

  const CrisisLifelineConnectedState({
    required this.number,
    this.isText = false,
  });

  @override
  List<Object> get props => [number, isText];
}

class CrisisErrorState extends CrisisResourceState {
  final String message;

  const CrisisErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
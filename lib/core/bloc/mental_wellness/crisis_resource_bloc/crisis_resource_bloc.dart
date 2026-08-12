import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_local_emergency_services_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_national_hotlines_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/trigger_emergency_protocol_usecase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/mental_wellness/crisis_resource.dart';
import '../../../models/mental_wellness/emergency_service.dart';
import '../../../../features/mental_wellness/usecases/get_crisis_resources_usecase.dart';
part 'crisis_resource_event.dart';
part 'crisis_resource_state.dart';

class CrisisResourceBloc extends Bloc<CrisisResourceEvent, CrisisResourceState> {
  final GetCrisisResourcesUseCase getCrisisResourcesUseCase;
  final GetLocalEmergencyServicesUseCase getLocalEmergencyServicesUseCase;
  final GetNationalHotlinesUseCase getNationalHotlinesUseCase;
  final TriggerEmergencyProtocolUseCase triggerEmergencyProtocolUseCase;

  CrisisResourceBloc({
    required this.getCrisisResourcesUseCase,
    required this.getLocalEmergencyServicesUseCase,
    required this.getNationalHotlinesUseCase,
    required this.triggerEmergencyProtocolUseCase,
  }) : super(CrisisInitialState()) {
    on<LoadCrisisResourcesEvent>(_onLoadResources);
    on<LoadLocalEmergencyServicesEvent>(_onLoadLocalServices);
    on<LoadNationalHotlinesEvent>(_onLoadNationalHotlines);
    on<TriggerEmergencyProtocolEvent>(_onTriggerEmergencyProtocol);
    on<CallCrisisLifelineEvent>(_onCallLifeline);
    on<SendCrisisTextEvent>(_onSendText);
    on<DismissCrisisAlertEvent>(_onDismissAlert);
    on<AddCustomCrisisResourceEvent>(_onAddCustomResource);
  }

  Future<void> _onLoadResources(
    LoadCrisisResourcesEvent event,
    Emitter<CrisisResourceState> emit,
  ) async {
    emit(const CrisisLoadingState(message: 'Loading crisis resources...'));

    try {
      final nationalResources = await getNationalHotlinesUseCase.execute();
      final localResources = await getCrisisResourcesUseCase.execute(
        location: event.location,
      );
      final emergencyServices = await getLocalEmergencyServicesUseCase.execute(
        location: event.location ?? 'current',
      );

      emit(CrisisResourcesLoadedState(
        nationalResources: nationalResources,
        localResources: localResources,
        emergencyServices: emergencyServices,
      ));
    } catch (e) {
      // Fallback to default resources
      emit(CrisisResourcesLoadedState(
        nationalResources: CrisisResource.defaultResources,
        localResources: [],
        emergencyServices: [],
      ));
    }
  }

  Future<void> _onLoadLocalServices(
    LoadLocalEmergencyServicesEvent event,
    Emitter<CrisisResourceState> emit,
  ) async {
    emit(const CrisisLoadingState(message: 'Loading local services...'));

    try {
      final services = await getLocalEmergencyServicesUseCase.execute(
        location: event.location,
      );
      emit(LocalServicesLoadedState(services: services));
    } catch (e) {
      emit(CrisisErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadNationalHotlines(
    LoadNationalHotlinesEvent event,
    Emitter<CrisisResourceState> emit,
  ) async {
    emit(const CrisisLoadingState(message: 'Loading national hotlines...'));

    try {
      final hotlines = await getNationalHotlinesUseCase.execute();
      emit(NationalHotlinesLoadedState(hotlines: hotlines));
    } catch (e) {
      emit(CrisisErrorState(message: e.toString()));
    }
  }

  Future<void> _onTriggerEmergencyProtocol(
    TriggerEmergencyProtocolEvent event,
    Emitter<CrisisResourceState> emit,
  ) async {
    try {
      final protocol = await triggerEmergencyProtocolUseCase.execute(
        userId: event.userId,
      );
      emit(EmergencyProtocolTriggeredState(
        message: protocol.message,
        steps: protocol.steps,
      ));
    } catch (e) {
      emit(CrisisErrorState(message: e.toString()));
    }
  }

  Future<void> _onCallLifeline(
    CallCrisisLifelineEvent event,
    Emitter<CrisisResourceState> emit,
  ) async {
    try {
      final url = 'tel:${event.phoneNumber}';
      if (await canLaunch(url)) {
        await launch(url);
        emit(CrisisLifelineConnectedState(number: event.phoneNumber));
      } else {
        emit(CrisisErrorState(message: 'Unable to make call. Please dial ${event.phoneNumber} manually.'));
      }
    } catch (e) {
      emit(CrisisErrorState(message: e.toString()));
    }
  }

  Future<void> _onSendText(
    SendCrisisTextEvent event,
    Emitter<CrisisResourceState> emit,
  ) async {
    try {
      final url = 'sms:${event.textNumber}?body=${Uri.encodeComponent(event.message)}';
      if (await canLaunch(url)) {
        await launch(url);
        emit(CrisisLifelineConnectedState(
          number: event.textNumber,
          isText: true,
        ));
      } else {
        emit(CrisisErrorState(message: 'Unable to send text. Please text ${event.textNumber} manually.'));
      }
    } catch (e) {
      emit(CrisisErrorState(message: e.toString()));
    }
  }

  void _onDismissAlert(
    DismissCrisisAlertEvent event,
    Emitter<CrisisResourceState> emit,
  ) {
    emit(CrisisInitialState());
  }

  void _onAddCustomResource(
    AddCustomCrisisResourceEvent event,
    Emitter<CrisisResourceState> emit,
  ) {
    // Add custom resource to state
    final currentState = state;
    if (currentState is CrisisResourcesLoadedState) {
      final newResource = CrisisResource.fromMap(event.resourceData);
      emit(CrisisResourcesLoadedState(
        nationalResources: currentState.nationalResources,
        localResources: [...currentState.localResources, newResource],
        emergencyServices: currentState.emergencyServices,
      ));
    }
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/health_sync_service.dart';
import 'health_sync_event.dart';
import 'health_sync_state.dart';

class HealthSyncBloc extends Bloc<HealthSyncEvent, HealthSyncState> {
  final HealthSyncService _healthSyncService;

  HealthSyncBloc(this._healthSyncService) : super(const HealthSyncState()) {
    on<RequestAppleHealthEvent>(_onRequestAppleHealth);
    on<RequestGoogleFitEvent>(_onRequestGoogleFit);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
  }

  Future<void> _onRequestAppleHealth(RequestAppleHealthEvent event, Emitter<HealthSyncState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _healthSyncService.requestAppleHealthPermission(event.uid);
    emit(state.copyWith(
      isLoading: false,
      isAppleHealthAuthorized: result,
      appleHealthLastSync: result ? _healthSyncService.appleHealthLastSync : null,
    ));
  }

  Future<void> _onRequestGoogleFit(RequestGoogleFitEvent event, Emitter<HealthSyncState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _healthSyncService.requestGoogleFitPermission(event.uid);
    emit(state.copyWith(
      isLoading: false,
      isGoogleFitAuthorized: result,
      googleFitLastSync: result ? _healthSyncService.googleFitLastSync : null,
    ));
  }

  Future<void> _onToggleNotifications(ToggleNotificationsEvent event, Emitter<HealthSyncState> emit) async {
    await _healthSyncService.toggleNotifications(event.enabled);
    emit(state.copyWith(isNotificationsEnabled: event.enabled));
  }
}

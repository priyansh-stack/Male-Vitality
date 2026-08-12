import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/book_therapy_session_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/filter_therapists_by_insurance_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_teletherapy_providers_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/get_therapist_availability_usecase.dart';
import 'package:life_stage_health_app/features/mental_wellness/usecases/search_therapists_usecase.dart';
import '../../../models/mental_wellness/therapist.dart';
import '../../../models/mental_wellness/teletherapy_provider.dart';
import '../../../models/mental_wellness/search_criteria.dart';
import '../../../models/mental_wellness/booking_request.dart';
part 'therapist_finder_event.dart';
part 'therapist_finder_state.dart';

class TherapistFinderBloc extends Bloc<TherapistFinderEvent, TherapistFinderState> {
  final SearchTherapistsUseCase searchTherapistsUseCase;
  final GetTeletherapyProvidersUseCase getTeletherapyProvidersUseCase;
  final FilterTherapistsByInsuranceUseCase filterTherapistsByInsuranceUseCase;
  final BookTherapySessionUseCase bookTherapySessionUseCase;
  final GetTherapistAvailabilityUseCase getTherapistAvailabilityUseCase;

  TherapistFinderBloc({
    required this.searchTherapistsUseCase,
    required this.getTeletherapyProvidersUseCase,
    required this.filterTherapistsByInsuranceUseCase,
    required this.bookTherapySessionUseCase,
    required this.getTherapistAvailabilityUseCase,
  }) : super(TherapistInitialState()) {
    on<SearchTherapistsEvent>(_onSearchTherapists);
    on<LoadTeletherapyProvidersEvent>(_onLoadTeletherapyProviders);
    on<FilterTherapistsByInsuranceEvent>(_onFilterByInsurance);
    on<FilterTherapistsByLocationEvent>(_onFilterByLocation);
    on<SelectTherapistEvent>(_onSelectTherapist);
    on<BookTherapySessionEvent>(_onBookSession);
    on<ClearSearchResultsEvent>(_onClearResults);
    on<UpdateSearchCriteriaEvent>(_onUpdateCriteria);
  }

  Future<void> _onSearchTherapists(
    SearchTherapistsEvent event,
    Emitter<TherapistFinderState> emit,
  ) async {
    emit(TherapistSearchingState(query: event.criteria.query));

    try {
      final therapists = await searchTherapistsUseCase.execute(event.criteria);
      emit(TherapistListLoadedState(
        therapists: therapists,
        criteria: event.criteria,
        totalResults: therapists.length,
      ));
    } catch (e) {
      emit(TherapistErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadTeletherapyProviders(
    LoadTeletherapyProvidersEvent event,
    Emitter<TherapistFinderState> emit,
  ) async {
    try {
      final providers = await getTeletherapyProvidersUseCase.execute();
      emit(TeletherapyProvidersLoadedState(providers: providers));
    } catch (e) {
      emit(TherapistErrorState(message: e.toString()));
    }
  }

  Future<void> _onFilterByInsurance(
    FilterTherapistsByInsuranceEvent event,
    Emitter<TherapistFinderState> emit,
  ) async {
    final currentState = state;
    if (currentState is TherapistListLoadedState) {
      try {
        final filtered = await filterTherapistsByInsuranceUseCase.execute(
          currentState.therapists,
          event.insurance,
        );
        emit(TherapistListLoadedState(
          therapists: filtered,
          criteria: currentState.criteria,
          totalResults: filtered.length,
        ));
      } catch (e) {
        emit(TherapistErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _onFilterByLocation(
    FilterTherapistsByLocationEvent event,
    Emitter<TherapistFinderState> emit,
  ) async {
    final currentState = state;
    if (currentState is TherapistListLoadedState) {
      final updatedCriteria = currentState.criteria.copyWith(
        location: event.location,
        radius: event.radius,
      );
      add(SearchTherapistsEvent(criteria: updatedCriteria));
    }
  }

  Future<void> _onSelectTherapist(
    SelectTherapistEvent event,
    Emitter<TherapistFinderState> emit,
  ) async {
    final currentState = state;
    if (currentState is TherapistListLoadedState) {
      final therapist = currentState.therapists
          .firstWhere((t) => t.id == event.therapistId);
      emit(TherapistSelectedState(therapist: therapist));
    }
  }

  Future<void> _onBookSession(
    BookTherapySessionEvent event,
    Emitter<TherapistFinderState> emit,
  ) async {
    emit(TherapistBookingState(
      request: event.bookingRequest,
      isSubmitting: true,
    ));

    try {
      final bookingId = await bookTherapySessionUseCase.execute(event.bookingRequest);
      emit(TherapistBookingCompleteState(
        bookingId: bookingId,
        message: 'Booking request sent successfully!',
      ));
    } catch (e) {
      emit(TherapistErrorState(message: e.toString()));
    }
  }

  void _onClearResults(
    ClearSearchResultsEvent event,
    Emitter<TherapistFinderState> emit,
  ) {
    emit(TherapistInitialState());
  }

  void _onUpdateCriteria(
    UpdateSearchCriteriaEvent event,
    Emitter<TherapistFinderState> emit,
  ) {
    add(SearchTherapistsEvent(criteria: event.criteria));
  }
}
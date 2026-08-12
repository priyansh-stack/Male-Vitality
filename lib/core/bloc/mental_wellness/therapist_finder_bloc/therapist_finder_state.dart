part of 'therapist_finder_bloc.dart';


abstract class TherapistFinderState extends Equatable {
  const TherapistFinderState();
  @override
  List<Object?> get props => [];
}

class TherapistInitialState extends TherapistFinderState {}

class TherapistSearchingState extends TherapistFinderState {
  final String? query;
  const TherapistSearchingState({this.query});
  @override
  List<Object?> get props => [query];
}

class TherapistListLoadedState extends TherapistFinderState {
  final List<Therapist> therapists;
  final SearchCriteria criteria;
  final int totalResults;

  const TherapistListLoadedState({
    required this.therapists,
    required this.criteria,
    this.totalResults = 0,
  });

  @override
  List<Object> get props => [therapists, criteria, totalResults];
}

class TeletherapyProvidersLoadedState extends TherapistFinderState {
  final List<TeletherapyProvider> providers;

  const TeletherapyProvidersLoadedState({required this.providers});

  @override
  List<Object> get props => [providers];
}

class TherapistSelectedState extends TherapistFinderState {
  final Therapist therapist;

  const TherapistSelectedState({required this.therapist});

  @override
  List<Object> get props => [therapist];
}

class TherapistBookingState extends TherapistFinderState {
  final BookingRequest request;
  final bool isSubmitting;

  const TherapistBookingState({
    required this.request,
    this.isSubmitting = false,
  });

  @override
  List<Object> get props => [request, isSubmitting];
}

class TherapistBookingCompleteState extends TherapistFinderState {
  final String bookingId;
  final String message;

  const TherapistBookingCompleteState({
    required this.bookingId,
    required this.message,
  });

  @override
  List<Object> get props => [bookingId, message];
}

class TherapistErrorState extends TherapistFinderState {
  final String message;

  const TherapistErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
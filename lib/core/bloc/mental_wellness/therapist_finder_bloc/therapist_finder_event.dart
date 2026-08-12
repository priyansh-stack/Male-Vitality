part of 'therapist_finder_bloc.dart';


abstract class TherapistFinderEvent extends Equatable {
  const TherapistFinderEvent();
  @override
  List<Object?> get props => [];
}

class SearchTherapistsEvent extends TherapistFinderEvent {
  final SearchCriteria criteria;

  const SearchTherapistsEvent({required this.criteria});

  @override
  List<Object> get props => [criteria];
}

class LoadTeletherapyProvidersEvent extends TherapistFinderEvent {}

class FilterTherapistsByInsuranceEvent extends TherapistFinderEvent {
  final String insurance;

  const FilterTherapistsByInsuranceEvent({required this.insurance});

  @override
  List<Object> get props => [insurance];
}

class FilterTherapistsByLocationEvent extends TherapistFinderEvent {
  final String location;
  final double? radius;

  const FilterTherapistsByLocationEvent({
    required this.location,
    this.radius,
  });

  @override
  List<Object?> get props => [location, radius];
}

class SelectTherapistEvent extends TherapistFinderEvent {
  final String therapistId;

  const SelectTherapistEvent({required this.therapistId});

  @override
  List<Object> get props => [therapistId];
}

class BookTherapySessionEvent extends TherapistFinderEvent {
  final BookingRequest bookingRequest;

  const BookTherapySessionEvent({required this.bookingRequest});

  @override
  List<Object> get props => [bookingRequest];
}

class ClearSearchResultsEvent extends TherapistFinderEvent {}

class UpdateSearchCriteriaEvent extends TherapistFinderEvent {
  final SearchCriteria criteria;

  const UpdateSearchCriteriaEvent({required this.criteria});

  @override
  List<Object> get props => [criteria];
}
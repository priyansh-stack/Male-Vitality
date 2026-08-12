import 'package:equatable/equatable.dart';
import 'therapist.dart';

class SearchCriteria extends Equatable {
  final String? query;
  final List<TherapistSpecialty> specialties;
  final List<TherapyModality> modalities;
  final String? location;
  final double? radius; // in miles
  final List<String> acceptedInsurances;
  final bool? acceptsNewPatients;
  final double? minRating;
  final TherapistGender? preferredGender;
  final int? maxPrice;
  final bool? onlyTeletherapy;
  final String? language;

  const SearchCriteria({
    this.query,
    this.specialties = const [],
    this.modalities = const [],
    this.location,
    this.radius,
    this.acceptedInsurances = const [],
    this.acceptsNewPatients,
    this.minRating,
    this.preferredGender,
    this.maxPrice,
    this.onlyTeletherapy,
    this.language,
  });

  bool get isEmpty => 
    query == null &&
    specialties.isEmpty &&
    modalities.isEmpty &&
    location == null &&
    radius == null &&
    acceptedInsurances.isEmpty &&
    acceptsNewPatients == null &&
    minRating == null &&
    preferredGender == null &&
    maxPrice == null &&
    onlyTeletherapy == null &&
    language == null;

  SearchCriteria copyWith({
    String? query,
    List<TherapistSpecialty>? specialties,
    List<TherapyModality>? modalities,
    String? location,
    double? radius,
    List<String>? acceptedInsurances,
    bool? acceptsNewPatients,
    double? minRating,
    TherapistGender? preferredGender,
    int? maxPrice,
    bool? onlyTeletherapy,
    String? language,
  }) {
    return SearchCriteria(
      query: query ?? this.query,
      specialties: specialties ?? this.specialties,
      modalities: modalities ?? this.modalities,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      acceptedInsurances: acceptedInsurances ?? this.acceptedInsurances,
      acceptsNewPatients: acceptsNewPatients ?? this.acceptsNewPatients,
      minRating: minRating ?? this.minRating,
      preferredGender: preferredGender ?? this.preferredGender,
      maxPrice: maxPrice ?? this.maxPrice,
      onlyTeletherapy: onlyTeletherapy ?? this.onlyTeletherapy,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
    query, specialties, modalities, location, radius,
    acceptedInsurances, acceptsNewPatients, minRating,
    preferredGender, maxPrice, onlyTeletherapy, language
  ];
}
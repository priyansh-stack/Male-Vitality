import 'package:equatable/equatable.dart';

enum TherapistSpecialty {
  cbt,
  dbt,
  trauma,
  family,
  addiction,
  anxiety,
  depression,
  ptsd,
  ocd,
  adhd,
  eatingDisorder,
  grief,
  couples,
  child,
  adolescent,
  senior,
}

enum TherapistGender {
  male,
  female,
  nonBinary,
  any,
}

enum TherapyModality {
  inPerson,
  video,
  phone,
  chat,
}

extension TherapistSpecialtyExtension on TherapistSpecialty {
  String get displayName {
    switch (this) {
      case TherapistSpecialty.cbt:
        return 'Cognitive Behavioral Therapy (CBT)';
      case TherapistSpecialty.dbt:
        return 'Dialectical Behavior Therapy (DBT)';
      case TherapistSpecialty.trauma:
        return 'Trauma Therapy';
      case TherapistSpecialty.family:
        return 'Family Therapy';
      case TherapistSpecialty.addiction:
        return 'Addiction Counseling';
      case TherapistSpecialty.anxiety:
        return 'Anxiety Treatment';
      case TherapistSpecialty.depression:
        return 'Depression Treatment';
      case TherapistSpecialty.ptsd:
        return 'PTSD Treatment';
      case TherapistSpecialty.ocd:
        return 'OCD Treatment';
      case TherapistSpecialty.adhd:
        return 'ADHD Management';
      case TherapistSpecialty.eatingDisorder:
        return 'Eating Disorder Treatment';
      case TherapistSpecialty.grief:
        return 'Grief Counseling';
      case TherapistSpecialty.couples:
        return 'Couples Therapy';
      case TherapistSpecialty.child:
        return 'Child Therapy';
      case TherapistSpecialty.adolescent:
        return 'Adolescent Therapy';
      case TherapistSpecialty.senior:
        return 'Senior Mental Health';
    }
  }
}

class Therapist extends Equatable {
  final String id;
  final String name;
  final String credentials;
  final String? photoUrl;
  final List<TherapistSpecialty> specialties;
  final List<TherapyModality> modalities;
  final String location;
  final double? latitude;
  final double? longitude;
  final int yearsExperience;
  final List<String> acceptedInsurances;
  final bool acceptsNewPatients;
  final double? rating;
  final int? reviewCount;
  final String? bio;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final Map<String, dynamic> availability; // Day -> List<TimeSlot>

  const Therapist({
    required this.id,
    required this.name,
    required this.credentials,
    this.photoUrl,
    this.specialties = const [],
    this.modalities = const [],
    required this.location,
    this.latitude,
    this.longitude,
    this.yearsExperience = 0,
    this.acceptedInsurances = const [],
    this.acceptsNewPatients = true,
    this.rating,
    this.reviewCount,
    this.bio,
    this.phoneNumber,
    this.email,
    this.website,
    this.availability = const {},
  });

  factory Therapist.fromMap(Map<String, dynamic> map) {
    return Therapist(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      credentials: map['credentials'] ?? '',
      photoUrl: map['photoUrl'],
      specialties: (map['specialties'] as List<dynamic>?)
          ?.map((e) => TherapistSpecialty.values.firstWhere(
                (s) => s.toString() == e,
                orElse: () => TherapistSpecialty.cbt,
              ))
          .toList() ?? [],
      modalities: (map['modalities'] as List<dynamic>?)
          ?.map((e) => TherapyModality.values.firstWhere(
                (m) => m.toString() == e,
                orElse: () => TherapyModality.video,
              ))
          .toList() ?? [],
      location: map['location'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      yearsExperience: map['yearsExperience'] ?? 0,
      acceptedInsurances: List<String>.from(map['acceptedInsurances'] ?? []),
      acceptsNewPatients: map['acceptsNewPatients'] ?? true,
      rating: (map['rating'] as num?)?.toDouble(),
      reviewCount: map['reviewCount'],
      bio: map['bio'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      website: map['website'],
      availability: Map<String, dynamic>.from(map['availability'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'credentials': credentials,
      'photoUrl': photoUrl,
      'specialties': specialties.map((e) => e.toString()).toList(),
      'modalities': modalities.map((e) => e.toString()).toList(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'yearsExperience': yearsExperience,
      'acceptedInsurances': acceptedInsurances,
      'acceptsNewPatients': acceptsNewPatients,
      'rating': rating,
      'reviewCount': reviewCount,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'availability': availability,
    };
  }

  @override
  List<Object?> get props => [
    id, name, credentials, photoUrl, specialties, modalities, location,
    latitude, longitude, yearsExperience, acceptedInsurances,
    acceptsNewPatients, rating, reviewCount, bio, phoneNumber, email,
    website, availability
  ];
}
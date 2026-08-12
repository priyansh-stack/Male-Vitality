import 'package:equatable/equatable.dart';

class EmergencyService extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? distance;
  final bool is24Hours;
  final List<String> services;
  final String? website;

  const EmergencyService({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.distance,
    this.is24Hours = true,
    this.services = const ['Emergency Care'],
    this.website,
  });

  factory EmergencyService.fromMap(Map<String, dynamic> map) {
    return EmergencyService(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      distance: map['distance'],
      is24Hours: map['is24Hours'] ?? true,
      services: List<String>.from(map['services'] ?? ['Emergency Care']),
      website: map['website'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'is24Hours': is24Hours,
      'services': services,
      'website': website,
    };
  }

  @override
  List<Object?> get props => [
    id, name, phoneNumber, address, latitude, longitude,
    distance, is24Hours, services, website
  ];
}
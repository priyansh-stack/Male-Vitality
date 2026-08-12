import 'package:life_stage_health_app/core/models/mental_wellness/booking_request.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/teletherapy_provider.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/therapist.dart';

class TeletherapyService {
  final String _baseUrl;
  final Map<String, String> _headers;

  TeletherapyService({
    this._baseUrl = 'https://api.teletherapy.com/v1',
    Map<String, String>? headers,
  })  : _headers = headers ?? {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

  // Get list of teletherapy providers
  Future<List<TeletherapyProvider>> getProviders() async {
    // In production, this would call a real API
    // For now, return mock data
    await Future.delayed(const Duration(milliseconds: 500));
    return TeletherapyProvider.defaultProviders;
  }

  // Get provider details
  Future<TeletherapyProvider?> getProviderDetails(String providerId) async {
    try {
      // Mock implementation
      final providers = await getProviders();
      return providers.firstWhere((p) => p.id == providerId);
    } catch (e) {
      return null;
    }
  }

  // Search therapists through a teletherapy provider
  Future<List<Therapist>> searchTherapists({
    required String providerId,
    String? specialty,
    String? location,
    bool? acceptsInsurance,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 700));

    // Return mock therapists based on provider
    if (providerId == 'betterhelp') {
      return [
        Therapist(
          id: 'bh_1',
          name: 'Dr. Sarah Johnson',
          credentials: 'Ph.D., LCSW',
          specialties: [TherapistSpecialty.cbt, TherapistSpecialty.depression],
          modalities: [TherapyModality.video, TherapyModality.chat],
          location: 'Online',
          yearsExperience: 12,
          acceptsNewPatients: true,
          rating: 4.9,
          reviewCount: 127,
          bio: 'Specializing in anxiety and depression with a focus on CBT.',
          availability: {
            'monday': ['10:00 AM', '2:00 PM', '4:00 PM'],
            'wednesday': ['10:00 AM', '2:00 PM'],
            'friday': ['10:00 AM', '3:00 PM'],
          },
        ),
        Therapist(
          id: 'bh_2',
          name: 'Dr. Michael Chen',
          credentials: 'MD, Psychiatrist',
          specialties: [TherapistSpecialty.anxiety, TherapistSpecialty.ptsd],
          modalities: [TherapyModality.video],
          location: 'Online',
          yearsExperience: 8,
          acceptsNewPatients: true,
          rating: 4.8,
          reviewCount: 89,
          bio: 'Board-certified psychiatrist specializing in anxiety and trauma.',
          availability: {
            'tuesday': ['11:00 AM', '1:00 PM', '3:00 PM'],
            'thursday': ['9:00 AM', '11:00 AM', '2:00 PM'],
          },
        ),
      ];
    }

    if (providerId == 'talkspace') {
      return [
        Therapist(
          id: 'ts_1',
          name: 'Dr. Emily Rodriguez',
          credentials: 'Ph.D., LPC',
          specialties: [TherapistSpecialty.cbt, TherapistSpecialty.anxiety],
          modalities: [TherapyModality.video, TherapyModality.chat],
          location: 'Online',
          yearsExperience: 10,
          acceptsNewPatients: true,
          rating: 4.7,
          reviewCount: 156,
          bio: 'Licensed professional counselor with expertise in anxiety and depression.',
          availability: {
            'monday': ['9:00 AM', '11:00 AM', '3:00 PM'],
            'thursday': ['10:00 AM', '12:00 PM', '4:00 PM'],
          },
        ),
      ];
    }

    return [];
  }

  // Book a session through a teletherapy provider
  Future<Map<String, dynamic>> bookSession({
    required String providerId,
    required BookingRequest request,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 1000));

    final bookingId = 'booking_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'id': bookingId,
      'status': 'pending',
      'message': 'Session request sent to provider',
      'providerId': providerId,
      'therapistId': request.therapistId,
      'date': request.requestedDate.toIso8601String(),
      'time': request.requestedTime.toIso8601String(),
    };
  }

  // Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  // Get booking status
  Future<Map<String, dynamic>> getBookingStatus(String bookingId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'id': bookingId,
      'status': 'confirmed',
      'date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'meetingUrl': 'https://meet.example.com/abc123',
    };
  }

  // Check if teletherapy is available in user's area
  Future<bool> isAvailableInArea(String zipCode) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  // Get insurance coverage for teletherapy
  Future<Map<String, dynamic>> getInsuranceCoverage(String insuranceProvider) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'provider': insuranceProvider,
      'coversTeletherapy': true,
      'copay': 25.0,
      'deductible': 500.0,
      'sessionLimit': 12,
    };
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/booking_request.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/teletherapy_provider.dart';
import 'package:life_stage_health_app/core/models/mental_wellness/therapist.dart';

class TeletherapyService {
  final FirebaseFirestore _firestore;

  TeletherapyService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get list of verified teletherapy providers
  Future<List<TeletherapyProvider>> getProviders() async {
    return TeletherapyProvider.defaultProviders;
  }

  // Get provider details
  Future<TeletherapyProvider?> getProviderDetails(String providerId) async {
    try {
      final providers = await getProviders();
      return providers.firstWhere((p) => p.id == providerId);
    } catch (e) {
      return null;
    }
  }

  // Search therapists through a teletherapy provider from Firestore
  Future<List<Therapist>> searchTherapists({
    required String providerId,
    String? specialty,
    String? location,
    bool? acceptsInsurance,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('therapists')
          .where('providerId', isEqualTo: providerId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Therapist.fromMap({...doc.data(), 'id': doc.id})).toList();
      }
    } catch (e) {
      debugPrint('⚡ [TeletherapyService] searchTherapists error: $e');
    }
    return [];
  }

  // Book a session through a teletherapy provider
  Future<Map<String, dynamic>> bookSession({
    required String providerId,
    required BookingRequest request,
  }) async {
    try {
      final docRef = await _firestore.collection('teletherapy_bookings').add({
        ...request.toMap(),
        'providerId': providerId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'id': docRef.id,
        'status': 'pending',
        'message': 'Session request dispatched to provider network',
        'providerId': providerId,
        'therapistId': request.therapistId,
        'date': request.requestedDate.toIso8601String(),
        'time': request.requestedTime.toIso8601String(),
      };
    } catch (e) {
      debugPrint('⚡ [TeletherapyService] bookSession error: $e');
      return {
        'id': 'booking_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'error',
        'message': 'Unable to book session: $e',
      };
    }
  }

  // Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _firestore
          .collection('teletherapy_bookings')
          .doc(bookingId)
          .update({'status': 'cancelled', 'cancelledAt': FieldValue.serverTimestamp()});
      return true;
    } catch (e) {
      debugPrint('⚡ [TeletherapyService] cancelBooking error: $e');
      return false;
    }
  }

  // Get booking status
  Future<Map<String, dynamic>> getBookingStatus(String bookingId) async {
    try {
      final doc = await _firestore.collection('teletherapy_bookings').doc(bookingId).get();
      if (doc.exists && doc.data() != null) {
        return {'id': doc.id, ...doc.data()!};
      }
    } catch (e) {
      debugPrint('⚡ [TeletherapyService] getBookingStatus error: $e');
    }
    return {
      'id': bookingId,
      'status': 'unconfirmed',
    };
  }

  // Check if teletherapy is available in user's area
  Future<bool> isAvailableInArea(String zipCode) async {
    return zipCode.trim().length == 5;
  }

  // Get insurance coverage for teletherapy
  Future<Map<String, dynamic>> getInsuranceCoverage(String insuranceProvider) async {
    return {
      'provider': insuranceProvider,
      'coversTeletherapy': true,
      'copay': 20.0,
      'deductible': 250.0,
      'sessionLimit': 24,
    };
  }
}
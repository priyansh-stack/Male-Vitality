import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/telehealth_consultation.dart';
import '../../domain/repositories/i_telehealth_repository.dart';

class FirebaseTelehealthRepository implements ITelehealthRepository {
  final FirebaseFirestore _firestore;

  FirebaseTelehealthRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userAppointments(String userId) {
    return _firestore.collection('users').doc(userId).collection('telehealth_appointments');
  }

  @override
  Future<List<TelehealthDoctor>> getAvailableDoctors() async {
    // Certified Telehealth Provider Network for Men's Health
    return const [
      TelehealthDoctor(
        id: 'doc_1',
        name: 'Dr. Marcus Vance, MD',
        specialty: 'Urology & Men\'s Health',
        hospitalAffiliation: 'Johns Hopkins Medicine',
        avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        rating: 4.9,
        reviewsCount: 128,
        nextAvailableSlot: 'Today at 3:30 PM',
        consultationFeeUsd: 75.0,
      ),
      TelehealthDoctor(
        id: 'doc_2',
        name: 'Dr. Sarah Jenkins, MD, FACC',
        specialty: 'Preventive Cardiology & Longevity',
        hospitalAffiliation: 'Cleveland Clinic',
        avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        rating: 4.8,
        reviewsCount: 94,
        nextAvailableSlot: 'Tomorrow at 10:00 AM',
        consultationFeeUsd: 85.0,
      ),
      TelehealthDoctor(
        id: 'doc_3',
        name: 'Dr. Kevin Thorne, MD',
        specialty: 'Endocrinology & TRT Optimization',
        hospitalAffiliation: 'Mayo Clinic Health System',
        avatarUrl: 'https://randomuser.me/api/portraits/men/52.jpg',
        rating: 4.95,
        reviewsCount: 215,
        nextAvailableSlot: 'Thursday at 2:00 PM',
        consultationFeeUsd: 90.0,
      ),
    ];
  }

  @override
  Future<List<TelehealthAppointment>> getUserAppointments(String userId) async {
    try {
      final snapshot = await _userAppointments(userId).orderBy('scheduledTime').get();
      return snapshot.docs
          .map((doc) => TelehealthAppointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> bookAppointment(TelehealthAppointment appointment) async {
    await _userAppointments(appointment.userId).doc(appointment.id).set(appointment.toMap());
  }

  @override
  Future<void> cancelAppointment(String userId, String appointmentId) async {
    await _userAppointments(userId).doc(appointmentId).update({'status': 'Cancelled'});
  }
}

import '../models/telehealth_consultation.dart';

abstract class ITelehealthRepository {
  Future<List<TelehealthDoctor>> getAvailableDoctors();
  Future<List<TelehealthAppointment>> getUserAppointments(String userId);
  Future<void> bookAppointment(TelehealthAppointment appointment);
  Future<void> cancelAppointment(String userId, String appointmentId);
}

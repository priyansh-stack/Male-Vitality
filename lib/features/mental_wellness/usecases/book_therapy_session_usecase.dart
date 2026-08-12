import '../../../core/models/mental_wellness/booking_request.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class BookTherapySessionUseCase {
  final MentalWellnessRepository repository;

  BookTherapySessionUseCase({required this.repository});

  Future<String> execute(BookingRequest request) {
    return repository.bookTherapySession(request);
  }
}
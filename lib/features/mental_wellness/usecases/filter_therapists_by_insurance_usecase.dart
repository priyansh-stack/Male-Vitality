import '../../../core/models/mental_wellness/therapist.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class FilterTherapistsByInsuranceUseCase {
  final MentalWellnessRepository repository;

  FilterTherapistsByInsuranceUseCase({required this.repository});

  Future<List<Therapist>> execute(
    List<Therapist> therapists,
    String insurance,
  ) {
    return repository.filterTherapistsByInsurance(therapists, insurance);
  }
}
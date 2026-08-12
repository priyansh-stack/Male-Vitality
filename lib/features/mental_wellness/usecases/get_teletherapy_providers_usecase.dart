import '../../../core/models/mental_wellness/teletherapy_provider.dart';
import '../../../core/services/mental_wellness/mental_wellness_repository.dart';

class GetTeletherapyProvidersUseCase {
  final MentalWellnessRepository repository;

  GetTeletherapyProvidersUseCase({required this.repository});

  Future<List<TeletherapyProvider>> execute() {
    return repository.getTeletherapyProviders();
  }
}
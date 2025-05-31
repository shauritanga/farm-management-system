import '../repositories/onboarding_repository.dart';

class CompleteOnboardingUsecase {
  final OnboardingRepository _repository;

  CompleteOnboardingUsecase(this._repository);

  Future<void> call() async {
    try {
      await _repository.completeOnboarding();
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }
}

import '../repositories/onboarding_repository.dart';

class CheckOnboardingStatusUsecase {
  final OnboardingRepository _repository;

  CheckOnboardingStatusUsecase(this._repository);

  Future<bool> call() async {
    try {
      return await _repository.hasCompletedOnboarding();
    } catch (e) {
      throw Exception('Failed to check onboarding status: $e');
    }
  }
}

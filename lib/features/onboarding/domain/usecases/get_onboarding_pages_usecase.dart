import '../entities/onboarding_page.dart';
import '../repositories/onboarding_repository.dart';

class GetOnboardingPagesUsecase {
  final OnboardingRepository _repository;

  GetOnboardingPagesUsecase(this._repository);

  Future<List<OnboardingPageEntity>> call() async {
    try {
      return await _repository.getOnboardingPages();
    } catch (e) {
      throw Exception('Failed to get onboarding pages: $e');
    }
  }
}

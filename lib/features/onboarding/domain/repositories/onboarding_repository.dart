import '../entities/onboarding_page.dart';

abstract class OnboardingRepository {
  /// Get all onboarding pages
  Future<List<OnboardingPageEntity>> getOnboardingPages();
  
  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding();
  
  /// Mark onboarding as completed
  Future<void> completeOnboarding();
  
  /// Reset onboarding status (useful for testing)
  Future<void> resetOnboarding();
}

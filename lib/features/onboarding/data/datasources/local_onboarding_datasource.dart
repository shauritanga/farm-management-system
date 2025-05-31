import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_page_model.dart';
import '../../../../core/services/image_service.dart';

class LocalOnboardingDataSource {
  static const String _onboardingKey = 'onboarding_completed';

  /// Get predefined onboarding pages
  Future<List<OnboardingPageModel>> getOnboardingPages() async {
    // Return predefined onboarding pages for agricultural app with network illustrations
    return [
      OnboardingPageModel(
        id: '1',
        title: 'Manage Your Farm Efficiently',
        description:
            'Track your crops, monitor growth stages, manage livestock, and keep detailed records of all your farming activities in one place.',
        imagePath: ImageService.getOnboardingImage('farm_management'),
        order: 1,
      ),
      OnboardingPageModel(
        id: '2',
        title: 'Cooperative Management Made Easy',
        description:
            'Cooperatives can efficiently manage their farmers, track sales, monitor production, and facilitate better communication with members.',
        imagePath: ImageService.getOnboardingImage('cooperative_management'),
        order: 2,
      ),
      OnboardingPageModel(
        id: '3',
        title: 'Start Your Agricultural Journey',
        description:
            'Join thousands of farmers and cooperatives in Tanzania who are already using Agripoa to improve their agricultural productivity and sales.',
        imagePath: ImageService.getOnboardingImage('agricultural_journey'),
        buttonText: 'Get Started',
        order: 3,
      ),
    ];
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  /// Reset onboarding status (useful for testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
  }
}

final localOnboardingDataSourceProvider = Provider<LocalOnboardingDataSource>((
  ref,
) {
  return LocalOnboardingDataSource();
});

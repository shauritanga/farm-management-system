import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/onboarding_page.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/local_onboarding_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final LocalOnboardingDataSource _localDataSource;

  OnboardingRepositoryImpl(this._localDataSource);

  @override
  Future<List<OnboardingPageEntity>> getOnboardingPages() async {
    try {
      final models = await _localDataSource.getOnboardingPages();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get onboarding pages: $e');
    }
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      return await _localDataSource.hasCompletedOnboarding();
    } catch (e) {
      throw Exception('Failed to check onboarding status: $e');
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      await _localDataSource.completeOnboarding();
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  @override
  Future<void> resetOnboarding() async {
    try {
      await _localDataSource.resetOnboarding();
    } catch (e) {
      throw Exception('Failed to reset onboarding: $e');
    }
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.read(localOnboardingDataSourceProvider));
});

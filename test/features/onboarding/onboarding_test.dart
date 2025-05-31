import 'package:flutter_test/flutter_test.dart';
import 'package:agripoa/features/onboarding/data/datasources/local_onboarding_datasource.dart';
import 'package:agripoa/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:agripoa/features/onboarding/domain/usecases/get_onboarding_pages_usecase.dart';

void main() {
  group('Onboarding Feature Tests', () {
    late LocalOnboardingDataSource dataSource;
    late OnboardingRepositoryImpl repository;
    late GetOnboardingPagesUsecase usecase;

    setUp(() {
      dataSource = LocalOnboardingDataSource();
      repository = OnboardingRepositoryImpl(dataSource);
      usecase = GetOnboardingPagesUsecase(repository);
    });

    test('should return 3 onboarding pages', () async {
      // Act
      final pages = await usecase();

      // Assert
      expect(pages.length, 3);
      expect(pages[0].title, 'Manage Your Farm Efficiently');
      expect(pages[1].title, 'Cooperative Management Made Easy');
      expect(pages[2].title, 'Start Your Agricultural Journey');
    });

    test('should have correct page order', () async {
      // Act
      final pages = await usecase();

      // Assert
      expect(pages[0].order, 1);
      expect(pages[1].order, 2);
      expect(pages[2].order, 3);
    });

    test('should have button text only on last page', () async {
      // Act
      final pages = await usecase();

      // Assert
      expect(pages[0].buttonText, isNull);
      expect(pages[1].buttonText, isNull);
      expect(pages[2].buttonText, 'Get Started');
    });

    test('should have correct image paths', () async {
      // Act
      final pages = await usecase();

      // Assert
      expect(pages[0].imagePath, contains('unsplash.com'));
      expect(pages[1].imagePath, contains('unsplash.com'));
      expect(pages[2].imagePath, contains('unsplash.com'));
      expect(pages[0].imagePath, contains('photo-1574943320219'));
      expect(pages[1].imagePath, contains('photo-1500382017468'));
      expect(pages[2].imagePath, contains('photo-1625246333195'));
    });
  });
}

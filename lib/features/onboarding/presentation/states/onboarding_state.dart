import '../../domain/entities/onboarding_page.dart';

// Simple state classes without freezed
abstract class OnboardingStateBase {}

class OnboardingInitial extends OnboardingStateBase {}

class OnboardingLoading extends OnboardingStateBase {}

class OnboardingLoaded extends OnboardingStateBase {
  final List<OnboardingPageEntity> pages;
  final int currentPageIndex;
  final bool isCompleted;

  OnboardingLoaded({
    required this.pages,
    required this.currentPageIndex,
    required this.isCompleted,
  });

  OnboardingLoaded copyWith({
    List<OnboardingPageEntity>? pages,
    int? currentPageIndex,
    bool? isCompleted,
  }) {
    return OnboardingLoaded(
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OnboardingError extends OnboardingStateBase {
  final String message;

  OnboardingError(this.message);
}

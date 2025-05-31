import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/usecases/get_onboarding_pages_usecase.dart';
import '../../domain/usecases/check_onboarding_status_usecase.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import '../states/onboarding_state.dart';

// Use case providers
final getOnboardingPagesUsecaseProvider = Provider<GetOnboardingPagesUsecase>((ref) {
  return GetOnboardingPagesUsecase(ref.read(onboardingRepositoryProvider));
});

final checkOnboardingStatusUsecaseProvider = Provider<CheckOnboardingStatusUsecase>((ref) {
  return CheckOnboardingStatusUsecase(ref.read(onboardingRepositoryProvider));
});

final completeOnboardingUsecaseProvider = Provider<CompleteOnboardingUsecase>((ref) {
  return CompleteOnboardingUsecase(ref.read(onboardingRepositoryProvider));
});

// State notifier for onboarding
class OnboardingNotifier extends StateNotifier<OnboardingStateBase> {
  final GetOnboardingPagesUsecase _getOnboardingPagesUsecase;
  final CheckOnboardingStatusUsecase _checkOnboardingStatusUsecase;
  final CompleteOnboardingUsecase _completeOnboardingUsecase;

  OnboardingNotifier(
    this._getOnboardingPagesUsecase,
    this._checkOnboardingStatusUsecase,
    this._completeOnboardingUsecase,
  ) : super(OnboardingInitial());

  Future<void> loadOnboardingPages() async {
    state = OnboardingLoading();
    try {
      final pages = await _getOnboardingPagesUsecase();
      final isCompleted = await _checkOnboardingStatusUsecase();
      
      state = OnboardingLoaded(
        pages: pages,
        currentPageIndex: 0,
        isCompleted: isCompleted,
      );
    } catch (e) {
      state = OnboardingError(e.toString());
    }
  }

  void updateCurrentPage(int index) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      state = currentState.copyWith(currentPageIndex: index);
    }
  }

  Future<void> completeOnboarding() async {
    try {
      await _completeOnboardingUsecase();
      if (state is OnboardingLoaded) {
        final currentState = state as OnboardingLoaded;
        state = currentState.copyWith(isCompleted: true);
      }
    } catch (e) {
      state = OnboardingError(e.toString());
    }
  }

  Future<bool> checkOnboardingStatus() async {
    try {
      return await _checkOnboardingStatusUsecase();
    } catch (e) {
      return false;
    }
  }
}

// State notifier provider
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingStateBase>((ref) {
  return OnboardingNotifier(
    ref.read(getOnboardingPagesUsecaseProvider),
    ref.read(checkOnboardingStatusUsecaseProvider),
    ref.read(completeOnboardingUsecaseProvider),
  );
});

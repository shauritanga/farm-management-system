import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../providers/onboarding_provider.dart';
import '../states/onboarding_state.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Load onboarding pages when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).loadOnboardingPages();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final state = ref.read(onboardingProvider);
    if (state is OnboardingLoaded) {
      if (state.currentPageIndex < state.pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _completeOnboarding();
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child:
            onboardingState is OnboardingLoading
                ? const Center(child: CircularProgressIndicator())
                : onboardingState is OnboardingError
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading onboarding',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        onboardingState.message,
                        style: GoogleFonts.inter(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(onboardingProvider.notifier)
                              .loadOnboardingPages();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
                : onboardingState is OnboardingLoaded
                ? _buildOnboardingContent(onboardingState, theme)
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildOnboardingContent(OnboardingLoaded state, ThemeData theme) {
    return Column(
      children: [
        // Top bar with skip button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo or app name
              Text(
                'Agripoa',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              // Placeholder or Skip button
              state.currentPageIndex < state.pages.length - 1
                  ? TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  )
                  : SizedBox(
                    width:
                        ResponsiveUtils
                            .fontSize16, // Match approximate width of "Skip"
                    height:
                        ResponsiveUtils.fontSize16 *
                        1.6, // Approximate height of TextButton
                  ),
            ],
          ),
        ),

        // Page view
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              ref.read(onboardingProvider.notifier).updateCurrentPage(index);
            },
            itemCount: state.pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageWidget(
                page: state.pages[index],
                onButtonPressed:
                    index == state.pages.length - 1
                        ? _completeOnboarding
                        : null,
              );
            },
          ),
        ),

        // Bottom navigation
        Padding(
          padding: EdgeInsets.all(ResponsiveUtils.spacing24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              if (state.currentPageIndex > 0)
                TextButton.icon(
                  onPressed: _previousPage,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: ResponsiveUtils.iconSize16,
                  ),
                  label: Text(
                    'Back',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize16,
                    ),
                  ),
                )
              else
                SizedBox(width: ResponsiveUtils.width80),

              // Page indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: state.pages.length,
                effect: WormEffect(
                  dotHeight: ResponsiveUtils.height8,
                  dotWidth: ResponsiveUtils.width8,
                  spacing: ResponsiveUtils.spacing8,
                  activeDotColor: theme.colorScheme.primary,
                  dotColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),

              // Next button (hide on last page)
              if (state.currentPageIndex < state.pages.length - 1)
                TextButton.icon(
                  onPressed: _nextPage,
                  label: Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize16,
                    ),
                  ),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: ResponsiveUtils.iconSize16,
                  ),
                )
              else
                SizedBox(width: ResponsiveUtils.width80),
            ],
          ),
        ),
      ],
    );
  }
}

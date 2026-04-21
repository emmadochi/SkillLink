import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      gradient: AppColors.heroGradient,
      icon: Icons.search_rounded,
      title: 'Find the Right\nArtisan Instantly',
      subtitle:
          'Browse hundreds of skilled professionals in your area — plumbers, electricians, carpenters, and more.',
    ),
    _OnboardingPage(
      gradient: LinearGradient(
        colors: [Color(0xFF001B7A), Color(0xFF2C4DE1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.verified_rounded,
      title: 'Verified &\nTrusted Experts',
      subtitle:
          'Every artisan is background-checked, rated by real customers, and certified in their craft.',
    ),
    _OnboardingPage(
      gradient: LinearGradient(
        colors: [Color(0xFF000C47), Color(0xFF7A5232)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.bolt_rounded,
      title: 'Book in Seconds,\nRelax in Minutes',
      subtitle:
          'Select a service, pick a time, and your artisan is on the way. Track progress in real-time.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) =>
                _OnboardingPageView(page: _pages[index]),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.40),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.onPrimary,
                      dotColor: AppColors.onPrimary.withOpacity(0.40),
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_currentPage < _pages.length - 1)
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: Text('Skip',
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.onPrimary.withOpacity(0.70),
                              )),
                        ),
                        const Spacer(),
                        SkillLinkButton(
                          label: 'Next',
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded,
                              size: 16, color: AppColors.onPrimary),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        SkillLinkButton.gradient(
                          label: 'Get Started',
                          width: double.infinity,
                          onPressed: () => context.go(AppRoutes.signup),
                        ),
                        const SizedBox(height: 16),
                        SkillLinkButton.outlined(
                          label: 'I already have an account',
                          width: double.infinity,
                          onPressed: () => context.go(AppRoutes.login),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo icon mark on every slide
              Image.asset(
                'assets/images/logo2.png',
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 40),
              Text(
                page.title,
                style: AppTypography.displayMd.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                page.subtitle,
                style: AppTypography.bodyLg.copyWith(
                  color: Colors.white.withOpacity(0.75),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

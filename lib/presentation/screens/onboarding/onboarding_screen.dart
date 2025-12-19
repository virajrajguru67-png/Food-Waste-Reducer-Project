import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import '../../widgets/animated_button.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Save Food, Save Planet',
      description: 'Join thousands of people reducing food waste and helping the environment',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: 'Get Great Deals',
      description: 'Save up to 60% on perfectly good food from restaurants and stores',
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
      color: AppColors.secondary,
    ),
    OnboardingPage(
      title: 'Make a Difference',
      description: 'Track your impact - see how much food and CO2 you\'ve saved',
      imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800',
      color: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.pageTransitionDuration,
        curve: AppAnimations.smoothCurve,
      );
    } else {
      _goToSignIn();
    }
  }

  void _goToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _goToSignIn,
                child: Text(
                  'Skip',
                  style: AppTextStyles.bodyMediumWithColor(
                    AppColors.textSecondary,
                  ),
                ),
              ),
            ).animate().fadeIn(),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageWidget(
                    page: _pages[index],
                    pageIndex: index,
                  );
                },
              ),
            ),

            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _PageIndicator(
                  isActive: index == _currentPage,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 300)),

            const SizedBox(height: AppSpacing.xl),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: AnimatedButton(
                label: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                icon: _currentPage == _pages.length - 1
                    ? Icons.arrow_forward
                    : Icons.arrow_forward_ios,
                onPressed: _nextPage,
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 400))
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final int pageIndex;

  const _OnboardingPageWidget({
    required this.page,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
              child: Image.network(
                page.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: page.color.withOpacity(0.2),
                  child: Icon(
                    Icons.fastfood,
                    size: 100,
                    color: page.color,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * pageIndex))
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
              .then()
              .shimmer(duration: const Duration(seconds: 2)),

          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            page.title,
            style: AppTextStyles.heading1WithColor(page.color),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 200 + 100 * pageIndex))
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppSpacing.lg),

          // Description
          Text(
            page.description,
            style: AppTextStyles.bodyLargeWithColor(AppColors.textSecondary),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 300 + 100 * pageIndex))
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;

  const _PageIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppAnimations.normal,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imageUrl;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.color,
  });
}


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      titleKey: 'onboarding_title_1',
      descriptionKey: 'onboarding_desc_1',
      accent: AppColors.primary,
    ),
    _OnboardingData(
      titleKey: 'onboarding_title_2',
      descriptionKey: 'onboarding_desc_2',
      accent: AppColors.primary,
    ),
    _OnboardingData(
      titleKey: 'onboarding_title_3',
      descriptionKey: 'onboarding_desc_3',
      accent: AppColors.primary,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 42,
                      height: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'welcome'.tr(), // من الـ JSON
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'splash_tagline'
                                .tr(), // "Save time & focus on your life"
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToHome,
                      child: Text(
                        'skip'.tr(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: CustomButton(
                  text: _currentPage == _pages.length - 1
                      ? 'get_started'.tr()
                      : 'next'.tr(),
                  onPressed: _nextPage,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${'crafted_by'.tr()} · ${'country_egypt'.tr()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              boxShadow: [
                BoxShadow(
                  color: data.accent.withOpacity(0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/onboarding_${_pages.indexOf(data) + 1}.png',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            data.titleKey.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.descriptionKey.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.white.withOpacity(0.82),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.titleKey,
    required this.descriptionKey,
    required this.accent,
  });

  final String titleKey;
  final String descriptionKey;
  final Color accent;
}

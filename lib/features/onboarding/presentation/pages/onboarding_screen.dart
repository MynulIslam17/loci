import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/onboarding/data/models/onboarding_item.dart';
import 'package:loci/features/onboarding/presentation/widgets/onboarding_bottom_bar.dart';
import 'package:loci/features/onboarding/presentation/widgets/onboarding_card_stack.dart';
import 'package:loci/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  final List<OnboardingItem>? items;

  const OnboardingScreen({super.key, this.items});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;
  final RxDouble _scrollPosition = 0.0.obs;

  late final List<OnboardingItem> _pages;

  @override
  void initState() {
    super.initState();
    _pages = widget.items ?? OnboardingItem.defaultItems;
    _pageController.addListener(() {
      _scrollPosition.value = _pageController.page ?? 0.0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    _currentPage.value = page;
  }

  void _nextPage() {
    if (_currentPage.value < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final scrollPosition = _scrollPosition.value;
                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    final double delta = index - scrollPosition;
                    final double opacity = (1.0 - delta.abs()).clamp(0.0, 1.0);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Dual-Card 3D Parallax Stack
                          OnboardingCardStack(item: item, delta: delta),

                          const SizedBox(height: 36),

                          // 2. Fade & Glide Text Content
                          Opacity(
                            opacity: opacity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.displayXs(
                                    color: colors.onSurface,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.textMd(
                                      color: colors.onSurfaceVariant,
                                      weight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            // 3. Modern Bottom Bar Navigation
            Obx(
              () => OnboardingBottomBar(
                currentPage: _currentPage.value,
                totalPages: _pages.length,
                onSkip: _navigateToLogin,
                onNext: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
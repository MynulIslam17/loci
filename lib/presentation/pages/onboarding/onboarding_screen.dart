import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../gen/assets.gen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _scrollPosition = 0.0;

  final List<Map<String, dynamic>> _pages = [
    {
      "title": "Discover Together",
      "description": "Connect with locals by asking questions, sharing answers, and discovering great businesses.",
      "image1": Assets.images.onimg1,
      "image2": Assets.images.onimg2,
    },
    {
      "title": "Discover your Place",
      "description": "Find local events, meet friendly faces, and discover your place together.",
      "image1": Assets.images.onimg3,
      "image2": Assets.images.onimg4,
    },
    {
      "title": "Where locals Lead",
      "description": "Simplify networking and Elevate your events.",
      "image1": Assets.images.onimg5,
      "image2": Assets.images.onimg6,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _scrollPosition = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {

    Get.toNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];

              // delta: distance from center (0.0 is center)
              double delta = (index - _scrollPosition);

              // Calculate opacity based on distance from center
              double opacity = (1.0 - delta.abs()).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 380,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // --- 1. BACKGROUND CONTAINER ---
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateZ(-0.15 + (delta * 0.05)),
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                color: context.colorScheme.primaryContainer.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(48),
                              ),
                            ),
                          ),

                          // --- 2. BACK IMAGE ---
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..translate(-20.0 - (delta * 12), -10.0, 0.0)
                              ..rotateZ(-0.22 - (delta * 0.08))
                              ..rotateY(-0.1),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: _buildAssetWidget(
                                page['image1'].path,
                                width: 200,
                                height: 240,

                              ),
                            ),
                          ),

                          // --- 3. FRONT IMAGE ---
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..translate(35.0 + (delta * 12), 50.0 + (delta * 8), 0.0)
                              ..rotateZ(0.08 + (delta * 0.05)),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(12, 12),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: _buildAssetWidget(
                                  page['image2'].path,
                                  width: 200,
                                  height: 240,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),


                    //  ensure opacity is high enough to be seen when the page is near active
                    Opacity(
                      opacity: opacity,
                      child: Column(
                        children: [
                          Text(
                            page['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page['description'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: context.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom Navigation Controls (Static on top of PageView)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                Visibility(
                  visible: _currentPage < _pages.length - 1,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: TextButton(
                    onPressed: _navigateToHome,
                    child: const Text("Skip", style: TextStyle(color: Colors.white54)),
                  ),
                ),

                // Indicators
                Row(
                  children: List.generate(
                    _pages.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? context.colorScheme.primary : context.colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Next Button
                IconButton(
                  onPressed: _nextPage,
                  icon: Icon(
                    _currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// widget for show image based on extention
  Widget _buildAssetWidget(String path, {double? width, double? height, Color? tintColor}) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        colorFilter: tintColor != null ? ColorFilter.mode(tintColor, BlendMode.srcIn) : null,
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      color: tintColor,
      colorBlendMode: tintColor != null ? BlendMode.darken : null,
    );
  }
}
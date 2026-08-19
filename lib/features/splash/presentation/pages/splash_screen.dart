import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/services/connectivity/connectivity_service.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/gen/assets.gen.dart';
import 'package:loci/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();
    _moveToNextScreen();
  }

  void _moveToNextScreen() async {
    final authController = Get.find<AuthController>();

    // Ensure session data is fully loaded from local storage before checking auth state
    await Future.wait([
      authController.loadUserData(),
      Future.delayed(const Duration(milliseconds: 2800)),
    ]);

    if (!mounted) return;

    if (Get.isRegistered<ConnectivityService>()) {
      Get.find<ConnectivityService>().isAppReady.value = true;
    }

    if (authController.isLoggedIn) {
      Get.offAllNamed(AppRoutes.bottomNav);
    } else {
      Get.offAllNamed(AppRoutes.onBoarding);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTeal = AppColors.primaryG500;
    final accentTeal = AppColors.primaryG400;

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. Rich Modern Gradient Background ────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF091C1A),
                          const Color(0xFF141414),
                          const Color(0xFF0D2421),
                          const Color(0xFF141414),
                        ]
                      : [
                          const Color(0xFFE8F7F5),
                          const Color(0xFFF9FBFA),
                          const Color(0xFFD7EAEB),
                          const Color(0xFFF4FAF9),
                        ],
                  stops: const [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // ── 2. Ambient Glowing Orbs ───────────────────────────────────────
          // Top-Right Ambient Glow
          Positioned(
            top: -60,
            right: -60,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryTeal.withValues(
                      alpha: isDark
                          ? (0.18 * _glowAnimation.value)
                          : (0.22 * _glowAnimation.value),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom-Left Ambient Glow
          Positioned(
            bottom: -80,
            left: -80,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentTeal.withValues(
                      alpha: isDark
                          ? (0.14 * _glowAnimation.value)
                          : (0.18 * _glowAnimation.value),
                    ),
                  ),
                );
              },
            ),
          ),

          // Frosted glass blur filter over background ambient glow
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox.expand(),
            ),
          ),

          // ── 3. Centered Brand Content ─────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glowing Frosted Glass Logo Pod
                        Container(
                          width: 120,
                          height: 120,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF1E1E1E).withValues(alpha: 0.85)
                                : Colors.white.withValues(alpha: 0.9),
                            border: Border.all(
                              color: primaryTeal.withValues(
                                alpha: isDark ? 0.35 : 0.25,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryTeal.withValues(
                                  alpha: isDark ? 0.28 : 0.16,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              Assets.images.logoPng.path,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // App Title
                        Text(
                          'LOCI',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4.0,
                            color: isDark ? Colors.white : AppColors.dark900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


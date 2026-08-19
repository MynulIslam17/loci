import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/onboarding/data/models/onboarding_item.dart';

/// Renders the 3D-stacked dual-card parallax visual for an onboarding slide.
class OnboardingCardStack extends StatelessWidget {
  final OnboardingItem item;
  final double delta;

  const OnboardingCardStack({
    super.key,
    required this.item,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 380,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Background Tinted Rotated Shape
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ(-0.15 + (delta * 0.05)),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(
                  alpha: isDark ? 0.25 : 0.40,
                ),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
          ),

          // 2. Back Card Image
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..translateByDouble(-20.0 - (delta * 12), -10.0, 0.0, 1.0)
              ..rotateZ(-0.22 - (delta * 0.08))
              ..rotateY(-0.1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
                    blurRadius: 24,
                    offset: const Offset(-4, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: _buildImage(item.backImagePath, width: 200, height: 240),
              ),
            ),
          ),

          // 3. Front Card Image with Ambient Elevation
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..translateByDouble(
                35.0 + (delta * 12),
                50.0 + (delta * 8),
                0.0,
                1.0,
              )
              ..rotateZ(0.08 + (delta * 0.05)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.22),
                    blurRadius: 30,
                    offset: const Offset(12, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: _buildImage(item.frontImagePath, width: 200, height: 240),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path, {required double width, required double height}) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}

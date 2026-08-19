import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/gen/assets.gen.dart';

/// Reusable parallax hero header with 3D tilted dual image cards
/// for authentication screens (Login, Sign Up).
class AuthParallaxHeader extends StatelessWidget {
  final AssetGenImage firstImage;
  final AssetGenImage secondImage;

  const AuthParallaxHeader({
    super.key,
    required this.firstImage,
    required this.secondImage,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: topPadding + 20,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background decorative shape
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translateByDouble(-10.0, -10.0, 0.0, 1.0)
                      ..rotateZ(-0.20),
                    child: Container(
                      width: 300,
                      height: 260,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.6,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  // Left image
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translateByDouble(-45.0, 15.0, 0.0, 1.0)
                      ..rotateZ(-0.55),
                    child: _buildImageCard(firstImage),
                  ),
                  // Right (top) image
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translateByDouble(50.0, -10.0, 0.0, 1.0)
                      ..rotateZ(0.62),
                    child: _buildImageCard(secondImage),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(AssetGenImage asset) {
    return Container(
      width: 180,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: asset.image(fit: BoxFit.fill),
      ),
    );
  }
}

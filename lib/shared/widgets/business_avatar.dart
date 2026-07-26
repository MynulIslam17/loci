import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// Circular business logo with a consistent storefront fallback shown when the
/// logo is null/empty or fails to load.
///
/// Single source of truth for the business placeholder — used by poll options,
/// poll previews and business search results so the fallback stays uniform.
class BusinessAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const BusinessAvatar({super.key, required this.imageUrl, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CustomCachedImage(
      width: size,
      height: size,
      isCircle: true,
      imageUrl: imageUrl,
      fallbackIcon: Icons.storefront_outlined,
    );
  }
}

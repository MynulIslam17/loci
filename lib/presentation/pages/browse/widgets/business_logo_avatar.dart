import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

/// Shows a business logo, with a clean fallback when the logo is missing.
///
/// A lot of businesses have `logo: null` (e.g. freshly claimed listings).
/// Passing an empty URL to [CustomCachedImage] renders a grey broken-image
/// box, which looks like a "wrong" logo. Instead, this widget shows a neutral
/// placeholder — the business initial, or a storefront icon when even the name
/// is empty — so a missing logo reads as intentional rather than broken.
class BusinessLogoAvatar extends StatelessWidget {
  final String? logo;
  final String name;
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const BusinessLogoAvatar({
    super.key,
    required this.logo,
    required this.name,
    this.size = 52,
    this.borderRadius = 10,
    this.fit = BoxFit.cover,
  });

  bool get _hasLogo => logo != null && logo!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    if (_hasLogo) {
      return CustomCachedImage(
        width: size,
        height: size,
        imageUrl: logo,
        borderRadius: borderRadius,
        fit: fit,
      );
    }

    final trimmedName = name.trim();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: trimmedName.isNotEmpty
          ? Text(
              trimmedName[0].toUpperCase(),
              style: AppTextStyle.textLg(
                color: scheme.primary,
                weight: FontWeight.w700,
              ).copyWith(fontSize: size * 0.4),
            )
          : Icon(
              Icons.storefront_rounded,
              size: size * 0.45,
              color: scheme.primary,
            ),
    );
  }
}

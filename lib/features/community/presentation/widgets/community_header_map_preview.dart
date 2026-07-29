import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/widgets/community_ui_constants.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// Map-style preview card for member community header.
class CommunityHeaderMapPreview extends StatelessWidget {
  const CommunityHeaderMapPreview({
    super.key,
    required this.businessName,
    this.imageUrl,
    this.height = 150,
  });

  final String businessName;
  final String? imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final url = imageUrl?.trim();
    final hasImage = url != null && url.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(CommunityUi.cardRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              CustomCachedImage(
                imageUrl: url,
                width: double.infinity,
                height: height,
                fit: BoxFit.cover,
              )
            else
              ColoredBox(
                color: colors.surfaceContainerHighest,
                child: Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.45),
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Text(
                businessName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.textSm(
                  weight: FontWeight.w600,
                  color: Colors.white,
                ).copyWith(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

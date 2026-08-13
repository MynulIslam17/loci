import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/image_viewer.dart';

class BusinessLogo extends StatelessWidget {
  final String? logo;
  const BusinessLogo(this.logo, {super.key});

  @override
  Widget build(BuildContext context) {
    final url = logo?.trim();
    final hasImage = url != null && url.isNotEmpty;

    return Center(
      child: GestureDetector(
        onTap: hasImage
            ? () => showImageViewer(
                  context,
                  imageUrl: url,
                  heroTag: 'browse-business-logo-$url',
                )
            : null,
        child: Container(
          height: 140,
          width: 140,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.colorScheme.primary, width: 1.5),
          ),
          child: hasImage
              ? Hero(
                  tag: 'browse-business-logo-$url',
                  child: CustomCachedImage(imageUrl: url, isCircle: true),
                )
              : const CustomCachedImage(imageUrl: null, isCircle: true),
        ),
      ),
    );
  }
}

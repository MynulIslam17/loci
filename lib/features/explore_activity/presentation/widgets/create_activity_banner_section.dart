import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_imagepicker.dart';

class CreateActivityBannerSection extends StatelessWidget {
  const CreateActivityBannerSection({
    super.key,
    this.bannerImage,
    this.imageUrl,
    required this.onSelected,
  });

  final File? bannerImage;
  final String? imageUrl;
  final ValueChanged<File> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CustomImagePicker(
        backgroundColor: colorScheme.surface,
        imageUrl: imageUrl,
        selectedImage: bannerImage,
        height: 180,
        onImageSelected: onSelected,
        placeholder: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: colorScheme.primary,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to upload banner',
                style: AppTextStyle.textSm(
                  color: colorScheme.onSurface,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Recommended: wide image, JPG or PNG',
                style: AppTextStyle.textXs(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

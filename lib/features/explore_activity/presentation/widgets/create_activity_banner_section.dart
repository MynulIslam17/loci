import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_imagepicker.dart';

class CreateActivityBannerSection extends StatelessWidget {
  const CreateActivityBannerSection({
    super.key,
    required this.bannerImage,
    required this.onSelected,
  });

  final File? bannerImage;
  final ValueChanged<File> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return CustomImagePicker(
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedImage: bannerImage,
      height: 200,
      onImageSelected: onSelected,
      placeholder: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: colorScheme.onSurface,
              size: 30,
            ),
            Text(
              'Browse image',
              style: AppTextStyle.textMd(
                color: colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

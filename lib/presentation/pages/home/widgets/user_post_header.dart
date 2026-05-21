import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class UserPostHeader extends StatelessWidget {
  final String fullName;
  final String date;
  final String category;
  final String imagePath;

  const UserPostHeader({
    super.key,
    required this.fullName,
    required this.date,
    required this.category,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Row(
      children: [
       CustomCachedImage(
         imageUrl: imagePath,
         width: 40,
         height: 40,
         isCircle: true,
       ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textMd(
                        weight: FontWeight.w600,
                        color: theme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "•",
                    style: TextStyle(color: AppColors.neutral300),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: AppTextStyle.textXs(color: AppColors.primaryG500),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: AppTextStyle.textXs(color: theme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
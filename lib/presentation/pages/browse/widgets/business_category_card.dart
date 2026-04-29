import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';

import 'business_category_ui_helper.dart';


class BusinessCategoryCard extends StatelessWidget {
  final BusinessCategory category;
  final VoidCallback onTap;

  const BusinessCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: color.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              BusinessCategoryUI.icon(category),
              height: 32,
              colorFilter: ColorFilter.mode(
                color.onSurface,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              BusinessCategoryUI.label(category),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
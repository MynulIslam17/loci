import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';

class MyOwnBusiness extends StatelessWidget {
  final String businessName;
  final VoidCallback? onTap;

  const MyOwnBusiness({
    super.key,
    required this.businessName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final hasBusinessName = businessName.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Business",
          style: AppTextStyle.textMd(
            weight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasBusinessName
                      ? colorScheme.primary.withOpacity(0.4)
                      : colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: hasBusinessName
                          ? colorScheme.primary.withOpacity(0.1)
                          : colorScheme.onSurface.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business_center_rounded,
                      size: 18,
                      color: hasBusinessName
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),

                  //  Business name
                  Expanded(
                    child: Text(
                      hasBusinessName ? businessName : "No Business",
                      style: AppTextStyle.textMd(
                        weight: FontWeight.w600,
                        color: hasBusinessName
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
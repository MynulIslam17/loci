import 'package:flutter/cupertino.dart';

import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/theme_extention.dart';

class BusinessHeaderSection extends StatelessWidget {
  final String name;
  final String location;
  final String phone;
  final String category;

  const BusinessHeaderSection({
    super.key,
    required this.name,
    required this.location,
    required this.phone,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // NAME
        Text(
          name,
          style: AppTextStyle.textXl(
            weight: FontWeight.w700,
            color: context.colorScheme.primary,
          ),
        ),

        const SizedBox(height: 6),

        // LOCATION
        Text(
          location,
          textAlign: TextAlign.center,
          style: AppTextStyle.textXs(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 4),

        // PHONE
        Text(
          phone,
          style: AppTextStyle.textXs(
            color: context.colorScheme.onSurfaceVariant,
            weight: FontWeight.w500,
          ),
        ),

        Text(
          category,
          style: AppTextStyle.textXs(
            color: context.colorScheme.onSurfaceVariant,
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
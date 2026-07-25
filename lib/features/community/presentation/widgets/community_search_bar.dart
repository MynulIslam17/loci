import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class CommunitySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onFilterTap;

  const CommunitySearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: controller,
            hintText: hintText,
            borderColor: colorScheme.outline,
            fontSize: 14,
            textColor: colorScheme.onSurface,
            hintTextColor: colorScheme.onSurfaceVariant,
            suffixIcon: Icon(
              Icons.search,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Icon(Icons.tune, color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}

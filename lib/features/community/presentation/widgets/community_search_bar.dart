import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class CommunitySearchBar extends StatelessWidget {
  const CommunitySearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return CustomTextField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      showClearButton: true,
      onClear: onClear,
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
      scrollPadding: const EdgeInsets.only(bottom: 120),
      borderColor: colorScheme.outline,
      fontSize: 14,
      textColor: colorScheme.onSurface,
      hintTextColor: colorScheme.onSurfaceVariant,
      suffixIcon: Icon(
        Icons.search,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

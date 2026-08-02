import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

/// Read-only field for date/time pickers — icon on the leading edge.
class CreateActivityPickerField extends StatelessWidget {
  const CreateActivityPickerField({
    super.key,
    required this.controller,
    required this.title,
    required this.hintText,
    required this.icon,
    required this.onTap,
    this.validator,
    this.isRequired = true,
    this.fontSize = 13,
  });

  final TextEditingController controller;
  final String title;
  final String hintText;
  final IconData icon;
  final VoidCallback onTap;
  final FormFieldValidator<String>? validator;
  final bool isRequired;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return CustomTextField(
      controller: controller,
      title: title,
      isRequired: isRequired,
      hintText: hintText,
      readOnly: true,
      onTap: onTap,
      fontSize: fontSize,
      prefixIcon: Icon(
        icon,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      borderColor: colorScheme.outline,
      textColor: colorScheme.onSurface,
      validator: validator,
    );
  }
}

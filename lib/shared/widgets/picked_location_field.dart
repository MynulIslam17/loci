import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/places/data/models/place_models.dart';
import 'package:loci/features/places/presentation/pages/location_picker_screen.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

/// Reusable form field for picking a place.
///
/// Tapping opens [LocationPickerScreen]. The address is written to [controller];
/// pass [onPicked] when coordinates are also needed.
class PickedLocationField extends StatelessWidget {
  const PickedLocationField({
    super.key,
    required this.controller,
    this.onPicked,
    this.title = 'Location',
    this.hintText = 'Search address or place',
    this.isRequired = true,
    this.validator,
    this.borderColor,
    this.fillColor,
    this.fontSize,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<PickedLocation>? onPicked;
  final String title;
  final String hintText;
  final bool isRequired;
  final FormFieldValidator<String>? validator;
  final Color? borderColor;
  final Color? fillColor;
  final double? fontSize;
  final bool enabled;

  static String? validateRequired(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please pick a location from search';
    return null;
  }

  FormFieldValidator<String>? _effectiveValidator() {
    if (validator != null) return validator;
    if (isRequired) return validateRequired;
    return null;
  }

  Future<void> _openPicker(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final result = await Get.to<PickedLocation?>(
      () => const LocationPickerScreen(),
      fullscreenDialog: true,
    );
    if (result != null) {
      controller.text = result.address;
      onPicked?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return CustomTextField(
      controller: controller,
      title: title,
      isRequired: isRequired,
      hintText: hintText,
      readOnly: true,
      validator: _effectiveValidator(),
      borderColor: borderColor ?? colorScheme.outline,
      fillColor: fillColor,
      fontSize: fontSize,
      onTap: enabled ? () => _openPicker(context) : null,
      prefixIcon: Icon(
        Icons.location_on_outlined,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      suffixIcon: Icon(
        Icons.search,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

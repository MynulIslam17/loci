import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/location/location_models.dart';
import 'package:loci/shared/widgets/location/location_picker_screen.dart';

/// A read-only location field: tapping it opens [LocationPickerScreen], and the
/// chosen place fills [controller] (the address) and is reported via [onPicked].
///
/// Reuse anywhere a location is needed:
///  • Event / Route forms use [onPicked] to keep the coordinates for submit.
///  • Text-only screens (e.g. business claim) can ignore the coordinates and
///    just read [controller].text.
class LocationPickerField extends StatelessWidget {
  const LocationPickerField({
    super.key,
    required this.controller,
    this.onPicked,
    this.title = 'Location',
    this.hintText = 'Search address or place',
    this.validator,
    this.isRequired = true,
    this.borderColor,
    this.fillColor,
    this.fontSize,
    this.enabled = true,
  });

  final TextEditingController controller;

  /// Optional — only needed when the caller wants the coordinates. The address
  /// text is written to [controller] regardless. Text-only screens can omit it.
  final ValueChanged<PickedLocation>? onPicked;

  final String title;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final bool isRequired;

  final Color? borderColor;
  final Color? fillColor;
  final double? fontSize;
  final bool enabled;

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
    return CustomTextField(
      controller: controller,
      title: title,
      isRequired: isRequired,
      hintText: hintText,
      readOnly: true,
      validator: validator,
      borderColor: borderColor,
      fillColor: fillColor,
      fontSize: fontSize,
      onTap: enabled ? () => _openPicker(context) : null,
      prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
      suffixIcon: const Icon(Icons.search, size: 20),
    );
  }
}

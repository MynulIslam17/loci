import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/acitvity_validator.dart';
import 'package:loci/shared/widgets/location/location_models.dart';
import 'package:loci/shared/widgets/location/location_picker_field.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_field_icon.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class ExploreActivityLocationFields extends StatelessWidget {
  const ExploreActivityLocationFields({
    super.key,
    required this.locationController,
    required this.urlController,
    required this.onLocationPicked,
    this.locationHint = 'Search address or place',
  });

  final TextEditingController locationController;

  /// The repurposed `url` field — now an optional website.
  final TextEditingController urlController;

  /// Fires when the user picks a place (carries the resolved coordinates).
  final ValueChanged<PickedLocation> onLocationPicked;

  final String locationHint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        LocationPickerField(
          controller: locationController,
          onPicked: onLocationPicked,
          hintText: locationHint,
          isRequired: true,
          borderColor: colorScheme.outline,
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Please pick a location from search';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: urlController,
          title: 'Website',
          isRequired: false,
          hintText: 'https://yourbusiness.com',
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.url,
          prefixIcon: exploreActivityFieldIcon(context, Icons.link),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: ActivityValidator.validateOptionalWebsite,
        ),
      ],
    );
  }
}

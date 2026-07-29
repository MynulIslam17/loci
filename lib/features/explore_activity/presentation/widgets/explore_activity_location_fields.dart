import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_field_icon.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class ExploreActivityLocationFields extends StatelessWidget {
  const ExploreActivityLocationFields({
    super.key,
    required this.locationController,
    required this.urlController,
    this.locationHint = 'Address or place name',
  });

  final TextEditingController locationController;
  final TextEditingController urlController;

  /// Flow-specific placeholder so the hint matches what people are entering.
  final String locationHint;

  /// Validates that [value] is a well-formed http(s) link. The server extracts
  /// coordinates from this URL, so anything that isn't a real link is rejected.
  static String? _validateMapLink(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Map link is required';

    final uri = Uri.tryParse(text);
    final isValid = uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
    if (!isValid) {
      return 'Enter a valid link starting with https://';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        CustomTextField(
          controller: locationController,
          title: 'Location',
          hintText: locationHint,
          textInputAction: TextInputAction.next,
          prefixIcon: exploreActivityFieldIcon(
            context,
            Icons.location_on_outlined,
          ),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Location is required';
            if (text.length < 3) {
              return 'Enter a more specific location';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: urlController,
          title: 'Map link',
          hintText: 'https://maps.app.goo.gl/…',
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.url,
          prefixIcon: exploreActivityFieldIcon(context, Icons.link),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: _validateMapLink,
        ),
      ],
    );
  }
}

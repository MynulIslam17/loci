import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/acitvity_validator.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_field_icon.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_map_preview.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';
import 'package:loci/features/places/data/models/place_models.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/picked_location_field.dart';

/// Location picker + optional website for activity create/edit forms.
class ExploreActivityLocationInputs extends StatelessWidget {
  const ExploreActivityLocationInputs({
    super.key,
    required this.locationController,
    required this.urlController,
    required this.onLocationPicked,
    this.locationHint = 'Search address or place',
  });

  final TextEditingController locationController;
  final TextEditingController urlController;
  final ValueChanged<PickedLocation> onLocationPicked;
  final String locationHint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        PickedLocationField(
          controller: locationController,
          onPicked: onLocationPicked,
          hintText: locationHint,
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

/// Location section with map preview — used on edit event/route screens.
class ExploreActivityLocationSection extends StatelessWidget {
  const ExploreActivityLocationSection({
    super.key,
    required this.locationController,
    required this.urlController,
    required this.onLocationPicked,
    this.sectionTitle = 'Location',
    this.sectionSubtitle,
    this.locationHint = 'Search address or place',
    this.mapHeight = 160,
    this.highlightTitle = false,
  });

  final TextEditingController locationController;
  final TextEditingController urlController;
  final ValueChanged<PickedLocation> onLocationPicked;
  final String sectionTitle;
  final String? sectionSubtitle;
  final String locationHint;
  final double mapHeight;
  final bool highlightTitle;

  @override
  Widget build(BuildContext context) {
    return ExploreActivitySection(
      title: sectionTitle,
      subtitle: sectionSubtitle,
      highlightTitle: highlightTitle,
      child: Column(
        children: [
          ExploreActivityLocationInputs(
            locationController: locationController,
            urlController: urlController,
            onLocationPicked: onLocationPicked,
            locationHint: locationHint,
          ),
          const SizedBox(height: 16),
          ExploreActivityMapPreview(height: mapHeight),
        ],
      ),
    );
  }
}

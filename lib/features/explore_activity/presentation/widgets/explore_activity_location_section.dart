import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/location/location_models.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_location_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_map_preview.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';

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
          ExploreActivityLocationFields(
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

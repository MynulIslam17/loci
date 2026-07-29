import 'package:flutter/material.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_location_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_map_preview.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';

class ExploreActivityLocationSection extends StatelessWidget {
  const ExploreActivityLocationSection({
    super.key,
    required this.locationController,
    required this.urlController,
    this.sectionTitle = 'Location',
    this.sectionSubtitle,
    this.locationHint = 'Address or place name',
    this.mapHeight = 160,
  });

  final TextEditingController locationController;
  final TextEditingController urlController;
  final String sectionTitle;
  final String? sectionSubtitle;
  final String locationHint;
  final double mapHeight;

  @override
  Widget build(BuildContext context) {
    return ExploreActivitySection(
      title: sectionTitle,
      subtitle: sectionSubtitle,
      child: Column(
        children: [
          ExploreActivityLocationFields(
            locationController: locationController,
            urlController: urlController,
            locationHint: locationHint,
          ),
          const SizedBox(height: 16),
          ExploreActivityMapPreview(height: mapHeight),
        ],
      ),
    );
  }
}

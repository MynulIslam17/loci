import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/authenticated_map_image.dart';

/// Map preview widget for Explore Activity screens using [AuthenticatedMapImage].
class ExploreActivityMapPreview extends StatelessWidget {
  const ExploreActivityMapPreview({
    super.key,
    this.mapImage,
    this.latitude,
    this.longitude,
    this.locationLabel,
    this.height = 160,
    this.borderRadius = 12.0,
  });

  final String? mapImage;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AuthenticatedMapImage(
      imageUrl: mapImage,
      latitude: latitude,
      longitude: longitude,
      locationLabel: locationLabel,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/authenticated_map_image.dart';

/// Relevant map preview widget for Event feature using [AuthenticatedMapImage].
class EventMapPreview extends StatelessWidget {
  const EventMapPreview({
    super.key,
    required this.mapImage,
    this.lat,
    this.lng,
    this.locationLabel,
    this.height = 180,
    this.borderRadius = 12.0,
  });

  final String? mapImage;
  final double? lat;
  final double? lng;
  final String? locationLabel;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AuthenticatedMapImage(
      imageUrl: mapImage,
      latitude: lat,
      longitude: lng,
      locationLabel: locationLabel,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

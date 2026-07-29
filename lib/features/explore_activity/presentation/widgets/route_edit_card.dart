import 'package:flutter/material.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_compact_meta.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_list_card.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_visibility_badge.dart';

class RouteEditCard extends StatelessWidget {
  const RouteEditCard({
    super.key,
    required this.title,
    required this.description,
    required this.location,
    required this.openingTime,
    required this.availabilityType,
    required this.isPublic,
    required this.imageUrl,
    required this.onEdit,
    required this.onView,
  });

  final String title;
  final String description;
  final String location;
  final String openingTime;
  final String availabilityType;
  final bool isPublic;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return ExploreActivityListCard(
      imageUrl: imageUrl,
      title: title,
      description: description,
      onEdit: onEdit,
      onView: onView,
      titleTrailing: ExploreActivityVisibilityBadge(isPublic: isPublic),
      meta: [
        ExploreActivityCompactMeta(
          icon: Icons.location_on_outlined,
          label: location,
        ),
        ExploreActivityCompactMeta(
          icon: Icons.access_time,
          label: openingTime,
        ),
        ExploreActivityCompactMeta(
          icon: Icons.event_available_outlined,
          label: availabilityType,
        ),
      ],
    );
  }
}

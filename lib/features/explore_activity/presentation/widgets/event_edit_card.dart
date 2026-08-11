import 'package:flutter/material.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_compact_meta.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_list_card.dart';

class EventEditCard extends StatelessWidget {
  const EventEditCard({
    super.key,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.attendance,
    required this.imageUrl,
    this.organizerName,
    this.onEditInfo,
    this.onViewDetails,
  });

  final String title;
  final String description;
  final String dateTime;
  final String location;
  final String attendance;
  final String imageUrl;
  final String? organizerName;
  final VoidCallback? onEditInfo;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return ExploreActivityListCard(
      imageUrl: imageUrl,
      title: title,
      description: description,
      onEdit: onEditInfo,
      onView: onViewDetails,
      organizerLine:
          organizerName != null && organizerName!.isNotEmpty
              ? 'by $organizerName'
              : null,
      meta: [
        ExploreActivityCompactMeta(
          icon: Icons.calendar_today_outlined,
          label: dateTime,
        ),
        ExploreActivityCompactMeta(
          icon: Icons.location_on_outlined,
          label: location,
        ),
        ExploreActivityCompactMeta(
          icon: Icons.people_outline,
          label: attendance,
        ),
      ],
    );
  }
}

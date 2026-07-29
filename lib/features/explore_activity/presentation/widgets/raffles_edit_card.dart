import 'package:flutter/material.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_compact_meta.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_list_card.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_raffle_prize_chip.dart';

class RaffleEditCard extends StatelessWidget {
  const RaffleEditCard({
    super.key,
    required this.title,
    required this.description,
    required this.dateRange,
    required this.prizeText,
    required this.imageUrl,
    required this.organizerName,
    required this.onEdit,
    required this.onView,
  });

  final String title;
  final String description;
  final String dateRange;
  final String prizeText;
  final String imageUrl;
  final String organizerName;
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
      contentPadding: const EdgeInsets.all(16),
      highlight: ExploreActivityRafflePrizeChip(label: prizeText),
      meta: [
        ExploreActivityCompactMeta(
          icon: Icons.calendar_today_outlined,
          label: 'Ends $dateRange',
        ),
      ],
      organizerLine: organizerName.isNotEmpty ? 'by $organizerName' : null,
    );
  }
}

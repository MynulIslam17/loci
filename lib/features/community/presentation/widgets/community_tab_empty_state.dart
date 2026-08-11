import 'package:flutter/material.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/shared/widgets/empty_state.dart';

class CommunityTabEmptyState extends StatelessWidget {
  const CommunityTabEmptyState({super.key, required this.type});

  final AnnouncementType type;

  @override
  Widget build(BuildContext context) {
    final config = _configFor(type);
    return EmptyState(
      icon: config.icon,
      title: config.title,
      subtitle: config.subtitle,
      iconSize: 44,
    );
  }

  static _EmptyConfig _configFor(AnnouncementType type) {
    return switch (type) {
      AnnouncementType.question => const _EmptyConfig(
        icon: Icons.forum_outlined,
        title: 'No questions yet',
        subtitle: 'Post a question above to start the conversation.',
      ),
      AnnouncementType.offer => const _EmptyConfig(
        icon: Icons.local_offer_outlined,
        title: 'No offers yet',
        subtitle: 'Community deals and coupons will show up here.',
      ),
      AnnouncementType.notice => const _EmptyConfig(
        icon: Icons.campaign_outlined,
        title: 'No notices yet',
        subtitle: 'Important updates from moderators will appear here.',
      ),
      AnnouncementType.activity => const _EmptyConfig(
        icon: Icons.event_outlined,
        title: 'No activities yet',
        subtitle: 'Events, routes, and raffles shared here will show up.',
      ),
    };
  }
}

class _EmptyConfig {
  const _EmptyConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/empty_state.dart';

/// Full-height empty state for explore-activity tab slivers.
class ExploreActivityEmptySliver extends StatelessWidget {
  const ExploreActivityEmptySliver({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: EmptyState(
          icon: icon,
          title: title,
          subtitle: subtitle,
          iconSize: 56,
        ),
      ),
    );
  }
}

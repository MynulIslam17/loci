import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Shimmer placeholder that mirrors the [EventDetails] layout while the event
/// is loading — top banner, header, info rows + check-in button, map card,
/// owner card and the RSVP button.
class EventDetailsSkeleton extends StatelessWidget {
  const EventDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- top banner ---
          const SkeletonBox(width: double.infinity, height: 200, radius: 10),
          const SizedBox(height: 16),

          // --- header (title + description) ---
          AppSkeleton.box(width: 220, height: 18),
          const SizedBox(height: 10),
          AppSkeleton.box(width: double.infinity, height: 10),
          const SizedBox(height: 6),
          AppSkeleton.box(width: 260, height: 10),
          const SizedBox(height: 16),

          // --- info rows + check-in button ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: const [
                    _IconRowSkeleton(),
                    SizedBox(height: 8),
                    _IconRowSkeleton(),
                    SizedBox(height: 8),
                    _IconRowSkeleton(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const SkeletonBox(width: 96, height: 40, radius: 6),
            ],
          ),
          const SizedBox(height: 16),

          // --- map card ---
          Card(
            color: context.colorScheme.surfaceContainerHigh,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: SkeletonBox(width: double.infinity, height: 160, radius: 8),
            ),
          ),
          const SizedBox(height: 16),

          // --- owner ---
          AppSkeleton.box(width: 80, height: 14),
          const SizedBox(height: 10),
          Card(
            color: context.colorScheme.surfaceContainerHigh,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  SkeletonBox(width: 48, height: 48, radius: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 120, height: 14),
                        SizedBox(height: 8),
                        SkeletonBox(width: double.infinity, height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // --- RSVP button ---
          const SkeletonBox(width: double.infinity, height: 48, radius: 12),
        ],
      ),
    );
  }
}

class _IconRowSkeleton extends StatelessWidget {
  const _IconRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        SkeletonBox(width: 18, height: 18, radius: 4),
        SizedBox(width: 8),
        Expanded(child: SkeletonBox(width: double.infinity, height: 10)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';

class SubscriptionShimmer extends StatelessWidget {
  const SubscriptionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        _SubscriptionShimmerCard(),
        SizedBox(height: 16),
        _SubscriptionShimmerCard(),
        SizedBox(height: 16),
        _SubscriptionShimmerCard(),
        SizedBox(height: 16),
        _SubscriptionShimmerCard(),
      ],
    );
  }
}

class _SubscriptionShimmerCard extends StatelessWidget {
  const _SubscriptionShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeleton.box(width: 120, height: 16),
            const SizedBox(height: 12),
            AppSkeleton.box(width: 80, height: 24),
            const SizedBox(height: 12),
            AppSkeleton.box(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            AppSkeleton.box(width: double.infinity, height: 12),
            const SizedBox(height: 20),
            AppSkeleton.box(width: double.infinity, height: 45),
          ],
        ),
      ),
    );
  }
}

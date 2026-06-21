import 'package:flutter/material.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';

/// Shimmer placeholder matching the collapsed business card on
/// [SearchMyBusiness] (padded image inside a card).
class MyBusinessCardShimmer extends StatelessWidget {
  const MyBusinessCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        color: scheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AppSkeleton.box(
            width: double.infinity,
            height: 190,
            radius: 8,
          ),
        ),
      ),
    );
  }
}

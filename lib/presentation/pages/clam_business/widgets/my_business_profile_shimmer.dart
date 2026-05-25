import 'package:flutter/material.dart';
import 'package:loci/presentation/pages/clam_business/widgets/review_card_shimmer.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';

/// Full-page shimmer placeholder that mirrors the layout of [MyBusinessProfile].
/// Shown while the business data is loading.
class MyBusinessProfileShimmer extends StatelessWidget {
  const MyBusinessProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),

          // ═══════════════════════ PROFILE HEADER ═══════════════════════

          // Logo circle
          AppSkeleton.box(width: 116, height: 116, radius: 58),

          const SizedBox(height: 18),

          // Business name
          AppSkeleton.box(height: 18, width: 180),
          const SizedBox(height: 10),

          // Address
          AppSkeleton.box(height: 12, width: 220),
          const SizedBox(height: 8),

          // Phone
          AppSkeleton.box(height: 12, width: 130),
          const SizedBox(height: 8),

          // Category
          AppSkeleton.box(height: 12, width: 100),
          const SizedBox(height: 14),

          // Star row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AppSkeleton.box(width: 16, height: 16, radius: 3),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Two chips (Community | QR)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSkeleton.box(width: 100, height: 34, radius: 17),
              const SizedBox(width: 12),
              AppSkeleton.box(width: 80, height: 34, radius: 17),
            ],
          ),

          const SizedBox(height: 14),

          // Change Subscription button
          AppSkeleton.box(width: 200, height: 40, radius: 20),

          const SizedBox(height: 24),

          // ═══════════════════════ DESCRIPTION CARD ═══════════════════════
          Card(
            color: scheme.surfaceContainerHigh,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  AppSkeleton.box(height: 12, width: double.infinity),
                  const SizedBox(height: 8),
                  AppSkeleton.box(height: 12, width: double.infinity),
                  const SizedBox(height: 8),
                  AppSkeleton.box(height: 12, width: 200),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ═══════════════════════ PHOTOS SECTION ═══════════════════════
          _buildSectionHeaderShimmer(),
          const SizedBox(height: 12),

          // 2-column photo grid (4 cells)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: 4,
            itemBuilder: (_, __) =>
                AppSkeleton.box(height: double.infinity, width: double.infinity, radius: 8),
          ),

          const SizedBox(height: 24),

          // ═══════════════════════ ADVERTISEMENTS ═══════════════════════
          _buildSectionHeaderShimmer(),
          const SizedBox(height: 12),

          // Ad placeholder card
          Card(
            color: scheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton.box(height: 14, width: 160),
                  const SizedBox(height: 12),
                  AppSkeleton.box(height: 40, width: double.infinity),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // "Explore Activities" button
          AppSkeleton.box(height: 48, width: double.infinity, radius: 12),

          const SizedBox(height: 24),

          // ═══════════════════════ HERO ADS ═══════════════════════
          _buildSectionHeaderShimmer(),
          const SizedBox(height: 12),

          // Hero image placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AppSkeleton.box(height: 200, width: double.infinity, radius: 16),
          ),

          const SizedBox(height: 8),

          // Ad info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppSkeleton.box(height: 11, width: 160),
              AppSkeleton.box(height: 11, width: 100),
            ],
          ),

          const SizedBox(height: 12),

          // "Create New Ads" button
          AppSkeleton.box(height: 48, width: double.infinity, radius: 12),

          const SizedBox(height: 24),

          // ═══════════════════════ REVIEWS SECTION ═══════════════════════
          // Section header row (title + "View all" placeholder)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppSkeleton.box(height: 18, width: 90),
              AppSkeleton.box(height: 14, width: 55),
            ],
          ),

          const SizedBox(height: 12),

          // 2 review card placeholders
          ReviewCardShimmer(itemCount: 2),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // ── Small helper: section header skeleton (title only) ─────────────────────
  Widget _buildSectionHeaderShimmer() {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppSkeleton.box(height: 18, width: 110),
    );
  }
}

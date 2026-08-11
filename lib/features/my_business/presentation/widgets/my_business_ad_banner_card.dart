import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/my_business/data/models/my_ad_model.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// Business ad card: readable metadata on top (theme-aware), banner image below.
class MyBusinessAdBannerCard extends StatelessWidget {
  const MyBusinessAdBannerCard({
    super.key,
    required this.ad,
    this.creditsRemaining,
  });

  static const double bannerImageHeight = 118;

  /// Approximate card height for carousel layout (includes text scaling).
  static double estimatedHeight(
    BuildContext context,
    MyAdModel ad, {
    bool showCredits = false,
  }) {
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;

    var height = 10.0 + 8.0; // header padding
    height += 24 * textScale; // title row
    if (ad.businessName.isNotEmpty &&
        ad.title.isNotEmpty &&
        ad.businessName != ad.title) {
      height += 2 + 16 * textScale;
    }
    height += 6 + 20 * textScale; // schedule / location row
    if (showCredits) height += 2;
    height += 10 + bannerImageHeight + 10; // framed banner
    return height.ceilToDouble() + 4;
  }

  final MyAdModel ad;
  final int? creditsRemaining;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: brightness == Brightness.dark ? 0.28 : 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          ad.title.isNotEmpty ? ad.title : ad.businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurface,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _AdStatusChip(status: ad.status),
                    ],
                  ),
                  if (ad.businessName.isNotEmpty &&
                      ad.title.isNotEmpty &&
                      ad.businessName != ad.title) ...[
                    const SizedBox(height: 2),
                    Text(
                      ad.businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (ad.location.isNotEmpty) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 2,
                          child: Text(
                            ad.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.textXs(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Icon(
                        Icons.schedule_outlined,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _scheduleLabel(ad),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.textXs(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (creditsRemaining != null)
                        Text(
                          '$creditsRemaining cr.',
                          style: AppTextStyle.textXs(
                            color: colorScheme.primary,
                            weight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.75),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: CustomCachedImage(
                    width: double.infinity,
                    height: bannerImageHeight,
                    imageUrl: ad.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _scheduleLabel(MyAdModel ad) {
    if (ad.isPending) return 'Pending review';

    final runDate = ad.startDate ?? ad.endDate;
    if (runDate != null) {
      return DateFormat('MMM d, yyyy').format(runDate.toLocal());
    }
    return 'Scheduled';
  }
}

class _AdStatusChip extends StatelessWidget {
  const _AdStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final normalized = status.toLowerCase();

    final (label, bg, fg) = switch (normalized) {
      'pending' => (
          'Pending',
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
        ),
      'active' => (
          'Active',
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
        ),
      _ => (
          status.isEmpty ? 'Ad' : status,
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyle.textXs(color: fg, weight: FontWeight.w600),
      ),
    );
  }
}

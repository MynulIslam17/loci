import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/event/presentation/widgets/event_card.dart';
import 'package:loci/features/raffles/data/models/raffle_list_model.dart';
import 'package:loci/shared/widgets/business_avatar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'date_range_helper.dart';

class RaffleCard extends StatelessWidget {
  final RaffleModel raffle;
  final VoidCallback onTap;

  const RaffleCard({super.key, required this.raffle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateRange = dateRangeHelper(raffle.startDate, raffle.endDate);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: colorScheme.primary.withValues(alpha: 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Compact Hero Image with Overlaid Badges ──────────────────
              Stack(
                children: [
                  CustomCachedImage(
                    imageUrl: raffle.banner,
                    height: 135,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: 0,
                  ),
                  // Bottom gradient for text readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.35),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Top-Left Entries / Max Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.confirmation_num_outlined,
                            size: 12,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            raffle.maxSupply > 0
                                ? "${raffle.maxSupply} Max"
                                : "Raffle",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-Right Entered Badge
                  if (raffle.isParticipating)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                            SizedBox(width: 3),
                            Text(
                              "Entered",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // ── 2. Content Body ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Organizer Row
                    if (raffle.organizerName.isNotEmpty) ...[
                      Row(
                        children: [
                          BusinessAvatar(
                            imageUrl: raffle.organizerLogo,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              raffle.organizerName,
                              style: AppTextStyle.textXs(
                                color: colorScheme.onSurfaceVariant,
                                weight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],

                    // Title
                    Text(
                      raffle.title,
                      style: AppTextStyle.textMd(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Prize Row — Supports at least 2 lines of text
                    if (raffle.bundleName.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.55),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (raffle.rafflePrizeImage != null &&
                                raffle.rafflePrizeImage!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CustomCachedImage(
                                  imageUrl: raffle.rafflePrizeImage!,
                                  width: 26,
                                  height: 26,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.card_giftcard_rounded,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PRIZE',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    raffle.bundleName,
                                    style: AppTextStyle.textXs(
                                      weight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Date Row
                    if (dateRange.isNotEmpty) ...[
                      IconTextRow(
                        icon: Icons.calendar_today_outlined,
                        text: dateRange,
                        iconColor: colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: CustomButton(
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        text: "View Raffle",
                        textStyle: AppTextStyle.textSm(weight: FontWeight.w600),
                        onPressed: onTap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

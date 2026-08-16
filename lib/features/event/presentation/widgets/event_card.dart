import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/business_avatar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String date;
  final String location;
  final String attendance;
  final String organizer;
  final VoidCallback onRSVP;
  final VoidCallback? onTapCard;
  final bool isLoading;
  final String rsvpButtonText;

  // Optional enhanced properties for richer modern UI
  final String? rawDate;
  final String? organizerAvatar;
  final int? goingCount;
  final int? maxAttendees;
  final bool? isPublic;
  final RsvpStatus? myRsvpStatus;

  const EventCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.attendance,
    required this.organizer,
    required this.onRSVP,
    this.onTapCard,
    this.isLoading = false,
    required this.rsvpButtonText,
    this.rawDate,
    this.organizerAvatar,
    this.goingCount,
    this.maxAttendees,
    this.isPublic,
    this.myRsvpStatus,
  });

  /// Extracts month abbreviation (e.g. "JUL") and day ("24")
  (String, String)? _extractMonthAndDay() {
    // 1. Try parsing from rawDate if available
    if (rawDate != null && rawDate!.isNotEmpty) {
      final parsed = DateTime.tryParse(rawDate!);
      if (parsed != null) {
        const months = [
          'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
          'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
        ];
        return (months[parsed.month - 1], parsed.day.toString());
      }
    }

    // 2. Try parsing from formatted date string (e.g. "Jul 20, 2026")
    final match = RegExp(r'([A-Za-z]{3,})\s+(\d{1,2})').firstMatch(date);
    if (match != null) {
      final monthStr = match.group(1)!.toUpperCase().substring(0, 3);
      final dayStr = match.group(2)!;
      return (monthStr, dayStr);
    }

    // 3. Fallback to ISO tryParse on date
    final fallbackDt = DateTime.tryParse(date);
    if (fallbackDt != null) {
      const months = [
        'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
      ];
      return (months[fallbackDt.month - 1], fallbackDt.day.toString());
    }

    return null;
  }

  bool get _isGoing =>
      rsvpButtonText.toLowerCase().contains('going') ||
      myRsvpStatus == RsvpStatus.going;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateParts = _extractMonthAndDay();

    final computedMaxAttendees = maxAttendees ?? _parseMaxFromAttendance();
    final computedGoingCount = goingCount ?? _parseGoingFromAttendance();
    final hasCapacityInfo = computedMaxAttendees > 0;
    final capacityRatio = hasCapacityInfo
        ? (computedGoingCount / computedMaxAttendees).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withValues(alpha: isDark ? 0.3 : 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTapCard,
          splashColor: colors.primary.withValues(alpha: 0.08),
          highlightColor: colors.primary.withValues(alpha: 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Compact Hero Image with Overlaid Badges ──────────────────
              Stack(
                children: [
                  CustomCachedImage(
                    width: double.infinity,
                    height: 135,
                    imageUrl: imageUrl,
                    borderRadius: 0,
                  ),
                  // Subtle bottom gradient for image readability
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

                  // Top-Left Calendar Date Badge
                  if (dateParts != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _GlassDateBadge(
                        month: dateParts.$1,
                        day: dateParts.$2,
                      ),
                    ),

                  // Top-Right Status / RSVP Badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _isGoing
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  "Going",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : (isPublic == true
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Text(
                                  "Public",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),
                  ),
                ],
              ),

              // ── 2. Content Body ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Organizer Header Row
                    if (organizer.isNotEmpty) ...[
                      Row(
                        children: [
                          BusinessAvatar(imageUrl: organizerAvatar, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              organizer,
                              style: AppTextStyle.textXs(
                                color: colors.onSurfaceVariant,
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

                    // Event Title
                    Text(
                      title,
                      style: AppTextStyle.textMd(
                        color: colors.onSurface,
                        weight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: AppTextStyle.textXs(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Info Rows (Date & Location) - Overflow safe with Expanded
                    if (date.isNotEmpty) ...[
                      IconTextRow(
                        icon: Icons.calendar_today_outlined,
                        text: date,
                        iconColor: colors.primary,
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (location.isNotEmpty) ...[
                      IconTextRow(
                        icon: Icons.location_on_outlined,
                        text: location,
                        iconColor: colors.primary,
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Attendance & Capacity Section
                    if (hasCapacityInfo || attendance.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      if (hasCapacityInfo) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.people_alt_outlined,
                                    size: 13,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      "$computedGoingCount attending",
                                      style: AppTextStyle.textXs(
                                        color: colors.onSurfaceVariant,
                                        weight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$computedMaxAttendees max",
                              style: AppTextStyle.textXs(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: capacityRatio,
                            minHeight: 4,
                            backgroundColor:
                                colors.outline.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              capacityRatio >= 0.9
                                  ? Colors.amber.shade700
                                  : colors.primary,
                            ),
                          ),
                        ),
                      ] else ...[
                        IconTextRow(
                          icon: Icons.people_outline,
                          text: attendance,
                          iconColor: colors.primary,
                        ),
                      ],
                    ],

                    const SizedBox(height: 10),

                    // ── 3. RSVP Action Button ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: _isGoing
                          ? OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: Color(0xFF10B981),
                              ),
                              label: const Text(
                                "Attending",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF10B981),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.45),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: const Color(0xFF10B981)
                                    .withValues(alpha: 0.08),
                              ),
                            )
                          : CustomButton(
                              isLoading: isLoading,
                              text: rsvpButtonText.isEmpty
                                  ? "RSVP Now"
                                  : rsvpButtonText,
                              textStyle: AppTextStyle.textSm(
                                weight: FontWeight.w600,
                              ),
                              onPressed: onRSVP,
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

  int _parseGoingFromAttendance() {
    final match = RegExp(r'(\d+)').firstMatch(attendance);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  int _parseMaxFromAttendance() {
    final match = RegExp(r'(\d+)\s*(?:max|\/)').firstMatch(attendance);
    if (match != null) {
      final secondMatch =
          RegExp(r'\/\s*(\d+)').firstMatch(attendance) ??
          RegExp(r'(\d+)\s*max').firstMatch(attendance);
      if (secondMatch != null) {
        return int.tryParse(secondMatch.group(1)!) ?? 0;
      }
    }
    return 0;
  }
}

/// Floating glass calendar badge for event cards
class _GlassDateBadge extends StatelessWidget {
  final String month;
  final String day;

  const _GlassDateBadge({required this.month, required this.day});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            month,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: colors.primary,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            day,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class IconTextRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;

  const IconTextRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor ?? context.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.textXs(
              color: textColor ?? context.colorScheme.onSurface,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}



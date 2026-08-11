import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/utils/date_parser.dart';

/// A selectable activity (event / route / raffle) returned by the
/// `all-activity` search endpoint.
///
/// Response items are activity-type announcements: [id] is the referenced
/// event/route/raffle `_id` (the `activityId`), while the display fields
/// (title, banner, subtitle) live inside the nested `event` / `route` /
/// `raffle` object.
class ActivityModel {
  final String id;
  final String title;
  final ActivityRefType refType;
  final String bannerUrl;

  /// A short, type-specific one-liner (date + location / opening time / range)
  /// shown under the title in the picker.
  final String subtitle;

  ActivityModel({
    required this.id,
    required this.title,
    required this.refType,
    required this.bannerUrl,
    required this.subtitle,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final refType = ActivityRefType.fromString(
      json['activityRefType'] as String?,
    );
    final nested = json[refType.name] as Map<String, dynamic>? ?? const {};

    return ActivityModel(
      id: json['activityId'] as String? ?? '',
      title: nested['title'] as String? ?? 'Untitled',
      refType: refType,
      bannerUrl: nested['banner'] as String? ?? '',
      subtitle: _buildSubtitle(refType, nested),
    );
  }

  static String _buildSubtitle(
    ActivityRefType type,
    Map<String, dynamic> nested,
  ) {
    switch (type) {
      case ActivityRefType.event:
        return _joinParts([
          nested['location'] as String?,
          DateParserHelper.isoToDisplay(nested['eventDate'] as String?),
        ]);
      case ActivityRefType.route:
        final opening = nested['openingTime'] as String?;
        return _joinParts([
          nested['location'] as String?,
          (opening != null && opening.isNotEmpty) ? 'Opens $opening' : null,
        ]);
      case ActivityRefType.raffle:
        final start = DateParserHelper.parseDate(
          nested['startDate'] as String?,
        );
        final end = DateParserHelper.parseDate(nested['endDate'] as String?);
        if (start != null && end != null) {
          return '${DateParserHelper.shortDate(start)} – '
              '${DateParserHelper.shortDate(end)}';
        }
        return nested['raffleBundleName'] as String? ?? '';
      case ActivityRefType.unknown:
        return '';
    }
  }

  static String _joinParts(List<String?> parts) {
    return parts
        .where((p) => p != null && p.isNotEmpty && p != 'N/A')
        .join('  ·  ');
  }
}

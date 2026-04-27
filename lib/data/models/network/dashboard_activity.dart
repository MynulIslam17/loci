// ─────────────────────────────────────────
// dashboard_activity.dart
// ─────────────────────────────────────────

import 'package:loci/data/models/network/raferral_item.dart';

import '../../../core/enums/network_type.dart';
import '../common/paginatation_model.dart';
import 'checkin_item.dart';
import 'connection_item.dart';
import 'metting_item.dart';


class DashboardActivity {
  final NetworkType type;
  final List<dynamic> data;
  final PaginationMeta meta;

  DashboardActivity({
    required this.type,
    required this.data,
    required this.meta,
  });

  factory DashboardActivity.fromJson(Map<String, dynamic> json) {
    final type = networkTypeFromString(json['type']);
    final rawList = json['data'] as List? ?? [];

    List<dynamic> parsedData = [];

    switch (type) {
      case NetworkType.checkins:
        parsedData = rawList
            .map((e) => CheckInModel.fromJson(e))
            .toList();
        break;

      case NetworkType.connections:
        parsedData = rawList
            .map((e) => ConnectionModel.fromJson(e))
            .toList();
        break;

      case NetworkType.meetings:
        parsedData = rawList
            .map((e) => MeetingModel.fromJson(e))
            .toList();
        break;

      case NetworkType.referrals:
        parsedData = rawList
            .map((e) => ReferralModel.fromJson(e))
            .toList();
        break;

      default:
        parsedData = rawList;
    }

    return DashboardActivity(
      type: type,
      data: parsedData,
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}
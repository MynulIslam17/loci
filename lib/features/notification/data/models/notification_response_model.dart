import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/notification/data/models/notification_model.dart';

class NotificationResponseModel {
  final bool success;
  final String message;
  final List<NotificationModel> data;
  final PaginationMeta meta;

  NotificationResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: _parseNotifications(json['data']),
      meta: PaginationMeta.fromJson(_parseMeta(json)),
    );
  }

  static List<NotificationModel> _parseNotifications(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (raw is Map) {
      final nested = raw['notifications'] ?? raw['items'] ?? raw['data'];
      if (nested != null) return _parseNotifications(nested);
    }

    return const [];
  }

  static Map<String, dynamic> _parseMeta(Map<String, dynamic> json) {
    final topLevel = json['meta'];
    if (topLevel is Map) {
      return Map<String, dynamic>.from(topLevel);
    }

    final data = json['data'];
    if (data is Map) {
      final nested = data['meta'] ?? data['pagination'];
      if (nested is Map) return Map<String, dynamic>.from(nested);
    }

    return const {};
  }
}

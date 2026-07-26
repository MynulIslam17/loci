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
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => NotificationModel.fromJson(e))
              .toList() ??
          [],
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

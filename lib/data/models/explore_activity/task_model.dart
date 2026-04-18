
import '../common/paginatation_model.dart';


class ActivityListResponseModel {
  final bool success;
  final String message;
  final List<TaskModel> activities;
  final PaginationMeta meta;

  ActivityListResponseModel({
    required this.success,
    required this.message,
    required this.activities,
    required this.meta,
  });

  factory ActivityListResponseModel.fromJson(Map<String, dynamic> json) {
    return ActivityListResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      activities: (json['data'] as List? ?? [])
          .map((e) => TaskModel.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}



class TaskModel {
  final String id;
  final String activityType;
  final String title;
  final String status;
  final String banner;
  final String details;

  TaskModel({
    required this.id,
    required this.activityType,
    required this.title,
    required this.status,
    required this.banner,
    required this.details,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'] ?? '',
      activityType: json['activityType'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      banner: json['banner'] ?? '',
      details: json['details'] ?? ''
    );
  }
}
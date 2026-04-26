// ─────────────────────────────────────────
// dashboard_counts.dart
// ─────────────────────────────────────────
import '../models/common/paginatation_model.dart';

// class DashboardCounts {
//   final int connections;
//   final int upcomingMeetings;
//   final int referralsSent;
//   final int totalCheckIns;
//
//   DashboardCounts({
//     required this.connections,
//     required this.upcomingMeetings,
//     required this.referralsSent,
//     required this.totalCheckIns,
//   });
//
//   factory DashboardCounts.fromJson(Map<String, dynamic> json) {
//     return DashboardCounts(
//       connections:      json['connections']      ?? 0,
//       upcomingMeetings: json['upcomingMeetings'] ?? 0,
//       referralsSent:    json['referralsSent']    ?? 0,
//       totalCheckIns:    json['totalCheckIns']    ?? 0,
//     );
//   }
// }


// // ─────────────────────────────────────────
// // check_in_item.dart
// // ─────────────────────────────────────────
// class CheckInLeadData {
//   final String name;
//   final String email;
//   final String avatar;
//
//   CheckInLeadData({
//     required this.name,
//     required this.email,
//     required this.avatar,
//   });
//
//   factory CheckInLeadData.fromJson(Map<String, dynamic> json) {
//     return CheckInLeadData(
//       name:   json['name']   ?? '',
//       email:  json['email']  ?? '',
//       avatar: json['avatar'] ?? '',
//     );
//   }
// }

// class CheckInItem {
//   final String id;
//   final String entityType;
//   final String entityId;
//   final String entityName;
//   final String scannedAt;   // raw ISO string
//   final String createdAt;
//   final String updatedAt;
//   final CheckInLeadData leadData;
//
//   CheckInItem({
//     required this.id,
//     required this.entityType,
//     required this.entityId,
//     required this.entityName,
//     required this.scannedAt,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.leadData,
//   });
//
//   factory CheckInItem.fromJson(Map<String, dynamic> json) {
//     return CheckInItem(
//       id:         json['_id']        ?? '',
//       entityType: json['entityType'] ?? '',
//       entityId:   json['entityId']   ?? '',
//       entityName: json['entityName'] ?? '',
//       scannedAt:  json['scannedAt']  ?? '',
//       createdAt:  json['createdAt']  ?? '',
//       updatedAt:  json['updatedAt']  ?? '',
//       leadData:   CheckInLeadData.fromJson(json['leadData'] ?? {}),
//     );
//   }
// }


// // ─────────────────────────────────────────
// // connection_item.dart
// // ─────────────────────────────────────────
// class ConnectionItem {
//   final String id;
//   final String userId;
//   final String name;
//   final String email;
//   final String phone;
//   final String avatar;
//   final String organization;
//   final String connectedAt;  // raw ISO string
//
//   ConnectionItem({
//     required this.id,
//     required this.userId,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.avatar,
//     required this.organization,
//     required this.connectedAt,
//   });
//
//   factory ConnectionItem.fromJson(Map<String, dynamic> json) {
//     return ConnectionItem(
//       id:           json['id']           ?? '',
//       userId:       json['userId']       ?? '',
//       name:         json['name']         ?? '',
//       email:        json['email']        ?? '',
//       phone:        json['phone']        ?? '',
//       avatar:       json['avatar']       ?? '',
//       organization: json['organization'] ?? '',
//       connectedAt:  json['connectedAt']  ?? '',
//     );
//   }
// }


// // ─────────────────────────────────────────
// // dashboard_activity.dart
// // ─────────────────────────────────────────
// enum ActivityType { checkins, connections, unknown }
//
// class DashboardActivity<T> {
//   final ActivityType type;
//   final List<T>      data;
//   final PaginationMeta meta;
//
//   DashboardActivity({
//     required this.type,
//     required this.data,
//     required this.meta,
//   });
//
//   factory DashboardActivity.fromJson(
//       Map<String, dynamic> json,
//       T Function(Map<String, dynamic>) fromJson,
//       ) {
//     final typeStr = json['type'] as String? ?? '';
//     final type = switch (typeStr) {
//       'checkins'    => ActivityType.checkins,
//       'connections' => ActivityType.connections,
//       _             => ActivityType.unknown,
//     };
//
//     final rawList = json['data'] as List<dynamic>? ?? [];
//
//     return DashboardActivity<T>(
//       type: type,
//       data: rawList.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
//       meta: PaginationMeta.fromJson(json['meta'] ?? {}),
//     );
//   }
// }


// // ─────────────────────────────────────────
// // dashboard_response.dart
// // ─────────────────────────────────────────
// class DashboardResponse<T> {
//   final bool   success;
//   final String message;
//   final DashboardCounts    counts;
//   final DashboardActivity<T> activity;
//
//   DashboardResponse({
//     required this.success,
//     required this.message,
//     required this.counts,
//     required this.activity,
//   });
//
//   factory DashboardResponse.fromJson(
//       Map<String, dynamic> json,
//       T Function(Map<String, dynamic>) itemFromJson,
//       ) {
//     final data = json['data'] as Map<String, dynamic>;
//     return DashboardResponse<T>(
//       success:  json['success'] ?? false,
//       message:  json['message'] ?? '',
//       counts:   DashboardCounts.fromJson(data['counts']   ?? {}),
//       activity: DashboardActivity<T>.fromJson(data['activity'] ?? {}, itemFromJson),
//     );
//   }
// }
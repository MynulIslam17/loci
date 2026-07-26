import 'package:loci/core/enums/meeting_status.dart';
import 'package:loci/shared/models/pagination_model.dart';

// ─────────────────────────────────────────────
// SHARED — RECIPIENT (just name + email)
// ─────────────────────────────────────────────
class MeetingRecipient {
  final String name;
  final String email;

  MeetingRecipient({required this.name, required this.email});

  factory MeetingRecipient.fromJson(Map<String, dynamic> json) {
    return MeetingRecipient(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────
// INCOMING ONLY — REQUESTER (full user object)
// ─────────────────────────────────────────────
class MeetingRequester {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String company;

  MeetingRequester({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.company,
  });

  factory MeetingRequester.fromJson(Map<String, dynamic> json) {
    return MeetingRequester(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      company: json['company'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────
// SENT MEETING (/meetings/my)
// requester is just the current user's id
// ─────────────────────────────────────────────
class SentMeetingModel {
  final String id;
  final String requesterId;
  final MeetingRecipient recipient;
  final String meetingDate;
  final String meetingTime;
  final String location;
  final String message;
  final MeetingStatus status;
  final String createdAt;
  final String updatedAt;

  SentMeetingModel({
    required this.id,
    required this.requesterId,
    required this.recipient,
    required this.meetingDate,
    required this.meetingTime,
    required this.location,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SentMeetingModel.fromJson(Map<String, dynamic> json) {
    return SentMeetingModel(
      id: json['_id'] ?? '',
      requesterId: json['requester'] ?? '',
      recipient: MeetingRecipient.fromJson(json['recipient'] ?? {}),
      meetingDate: json['meetingDate'] ?? '',
      meetingTime: json['meetingTime'] ?? '',
      location: json['location'] ?? '',
      message: json['message'] ?? '',
      status: MeetingStatus.fromString(json['status']),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class SentMeetingsResponse {
  final bool success;
  final String message;
  final List<SentMeetingModel> data;
  final PaginationMeta meta;

  SentMeetingsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory SentMeetingsResponse.fromJson(Map<String, dynamic> json) {
    return SentMeetingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SentMeetingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

// ─────────────────────────────────────────────
// INCOMING MEETING (/meetings/incoming)
// requester is the full user object
// ─────────────────────────────────────────────
class IncomingMeetingModel {
  final String id;
  final MeetingRequester requester;
  final MeetingRecipient recipient;
  final String meetingDate;
  final String meetingTime;
  final String location;
  final String message;
  final MeetingStatus status;
  final String createdAt;
  final String updatedAt;

  IncomingMeetingModel({
    required this.id,
    required this.requester,
    required this.recipient,
    required this.meetingDate,
    required this.meetingTime,
    required this.location,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncomingMeetingModel.fromJson(Map<String, dynamic> json) {
    return IncomingMeetingModel(
      id: json['_id'] ?? '',
      requester: MeetingRequester.fromJson(json['requester'] ?? {}),
      recipient: MeetingRecipient.fromJson(json['recipient'] ?? {}),
      meetingDate: json['meetingDate'] ?? '',
      meetingTime: json['meetingTime'] ?? '',
      location: json['location'] ?? '',
      message: json['message'] ?? '',
      status: MeetingStatus.fromString(json['status']),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class IncomingMeetingsResponse {
  final bool success;
  final String message;
  final List<IncomingMeetingModel> data;
  final PaginationMeta meta;

  IncomingMeetingsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory IncomingMeetingsResponse.fromJson(Map<String, dynamic> json) {
    return IncomingMeetingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => IncomingMeetingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

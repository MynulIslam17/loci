import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/data/models/common/paginatation_model.dart';

import '../../../core/enums/rsvp_status.dart';

class EventListResponseModel {
  final String message;
  final List<EventModel> events;
  final PaginationMeta meta;

  EventListResponseModel({
    required this.message,
    required this.events,
    required this.meta,
  });

  factory EventListResponseModel.fromJson(Map<String, dynamic> json) {
    return EventListResponseModel(
      message: json['message'] ?? '',
      events: (json['data'] as List? ?? [])
          .map((e) => EventModel.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class EventModel {
  final String id;
  final String coverImage;
  final String title;
  final String description;
  final String date;
  final String? activityType;
  final String location;
  final bool isPublic;
  final int goingCount;
  final int maxAttendees;
  final String organizerName;
  final String? organizerAvatar;
  final RsvpStatus myRsvpStatus;

  EventModel({
    required this.id,
    required this.coverImage,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.goingCount,
    required this.maxAttendees,
    required this.organizerName,
    this.activityType,
    this.organizerAvatar,
    required this.isPublic,
    required this.myRsvpStatus,
  });



  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? '',
      coverImage: json['banner'] ?? '',
      title: json['title'] ?? '',
      description: json['details'] ?? '',
      date: json['eventDate'] != null
          ? DateParserHelper.eventDateTime(
              DateTime.parse(json['eventDate']).toLocal(),
            )
          : '',
      location: json['location'] ?? '',
      goingCount: json['rsvpCount'] ?? 0,
      maxAttendees: json['maxParticipants'] ?? 0,
      activityType: json['activityType'],
      organizerName: json['organizerBusiness']?['name'] ?? '',
      organizerAvatar: json['organizerBusiness']?['logo'],
      isPublic: json['isPublic'] ?? false,
      myRsvpStatus: RsvpStatus.fromString(json['myRsvpStatus']),
    );
  }

  // for update the model
  EventModel copyWith({
    String? id,
    String? coverImage,
    String? title,
    String? description,
    String? date,
    String? location,
    String? activityType,
    bool? isPublic,
    int? goingCount,
    int? maxAttendees,
    String? organizerName,
    String? organizerAvatar,
    RsvpStatus? myRsvpStatus,
  }) {
    return EventModel(
      id: id ?? this.id,
      coverImage: coverImage ?? this.coverImage,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      activityType: activityType ?? this.activityType,
      isPublic: isPublic ?? this.isPublic,
      goingCount: goingCount ?? this.goingCount,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      organizerName: organizerName ?? this.organizerName,
      organizerAvatar: organizerAvatar ?? this.organizerAvatar,
      myRsvpStatus: myRsvpStatus ?? this.myRsvpStatus,
    );
  }
}

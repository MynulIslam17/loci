import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/shared/models/pagination_model.dart';

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
  final String eventTime;
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
    required this.eventTime,
    required this.location,
    required this.goingCount,
    required this.maxAttendees,
    required this.organizerName,
    this.activityType,
    this.organizerAvatar,
    required this.isPublic,
    required this.myRsvpStatus,
  });

  /// Human-friendly date for display, e.g. "Jul 20, 2026 · 06:30".
  /// [date] is a raw ISO string from the API — never show it directly.
  String get dateLabel {
    final parsed = DateTime.tryParse(date);
    final datePart = parsed != null
        ? DateParserHelper.toFriendlyDate(parsed)
        : '';
    final timePart = eventTime.trim();
    if (datePart.isEmpty) return timePart;
    if (timePart.isEmpty) return datePart;
    return '$datePart · $timePart';
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? '',
      coverImage: json['banner'] ?? '',
      title: json['title'] ?? '',
      description: json['details'] ?? '',
      date: json['eventDate'] ?? '',
      eventTime: json['eventTime'] ?? '',
      location: json['location'] ?? '',
      goingCount:
          json['rsvpCount'] ??
          (json['rsvpCounts'] as Map<String, dynamic>?)?['going'] ??
          0,
      maxAttendees: json['maxParticipants'] ?? 0,
      activityType: json['activityType'],
      organizerName: json['organizerBusiness']?['name'] ?? '',
      organizerAvatar: json['organizerBusiness']?['logo'],
      isPublic: json['isPublic'] ?? false,
      myRsvpStatus: RsvpStatus.fromString(json['myRsvpStatus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'coverImage': coverImage,
      'title': title,
      'description': description,
      'date': date,
      'eventTime': eventTime,
      'location': location,
      'activityType': activityType,
      'isPublic': isPublic,
      'goingCount': goingCount,
      'maxParticipants': maxAttendees,
      'organizerBusiness': {
        'name': organizerName,
        'logo': organizerAvatar,
      },
      'myRsvpStatus': myRsvpStatus.name,
    };
  }

  // for update the model
  EventModel copyWith({
    String? id,
    String? coverImage,
    String? title,
    String? description,
    String? date,
    String? eventTime,
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
      eventTime: eventTime ?? this.eventTime,
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

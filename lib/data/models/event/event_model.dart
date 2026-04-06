import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/data/models/common/paginatation_model.dart';


class EventListResponseModel {
  final String message;
  final List<EventModel> events;
  final PaginationMeta meta;

  EventListResponseModel({
    required this.message,
    required this.events,
    required this.meta

  });

  factory EventListResponseModel.fromJson(Map<String, dynamic> json) {
    return EventListResponseModel(
      /// Parse events list
       message: json['message'] ?? '',
      events: (json['data'] as List)
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
  final String location;
  final int goingCount;
  final int maxAttendees;
  final String organizerName;
  final String? organizerAvatar;

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
    this.organizerAvatar,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    int goingCount = 0;
    if (json['rsvpList'] != null && json['rsvpList'] is List) {
      goingCount = (json['rsvpList'] as List)
          .where((e) => e['status'] == 'going')
          .length;
    }

    return EventModel(
      id: json['_id'] ?? '',
      coverImage: json['coverImage'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['startDate'] != null
          ? DateParserHelper.eventDateTime(
        DateTime.parse(json['startDate']).toLocal(),
      )
          : '',
      location: json['location']?['address'] ?? '',
      goingCount: goingCount,
      maxAttendees: json['maxAttendees'] ?? 0,
      organizerName: json['organizer']?['name'] ?? '',
      organizerAvatar: json['organizer']?['avatar'],
    );
  }


}
import 'package:loci/core/utils/date_parser.dart';


class EventListResponseModel {
  final List<EventModel> events;

  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  EventListResponseModel({
    required this.events,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory EventListResponseModel.fromJson(Map<String, dynamic> json) {
    return EventListResponseModel(
      /// Parse events list
      events: (json['data'] as List)
          .map((e) => EventModel.fromJson(e))
          .toList(),

      /// Parse meta
      total: json['meta']?['total'] ?? 0,
      page: json['meta']?['page'] ?? 1,
      limit: json['meta']?['limit'] ?? 10,
      totalPages: json['meta']?['totalPages'] ?? 1,
      hasNextPage: json['meta']?['hasNextPage'] ?? false,
      hasPrevPage: json['meta']?['hasPrevPage'] ?? false,
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
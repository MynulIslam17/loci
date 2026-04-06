import 'package:loci/core/utils/date_parser.dart';

class EventDetailsModel {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final String startDate;
  final String endDate;
  final String locationAddress;
  final List<double> coordinates;
  final int maxAttendees;
  final List<Rsvp> rsvpList;
  final String qrCode;
  final Organizer organizer;
  final Business business;

  EventDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.startDate,
    required this.endDate,
    required this.locationAddress,
    required this.coordinates,
    required this.maxAttendees,
    required this.rsvpList,
    required this.qrCode,
    required this.organizer,
    required this.business,
  });



  factory EventDetailsModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final businessJson = json['business'] ?? {};
    final organizerJson = json['organizer'] ?? {};

    return EventDetailsModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['coverImage'] ?? '',
      startDate: DateParserHelper.eventDateTime(
        DateTime.parse(json['startDate']).toLocal()
      ),
      endDate: json['endDate'] ?? '',
      locationAddress: location['address'] ?? '',
      coordinates: List<double>.from(location['coordinates'] ?? [0.0, 0.0]),
      maxAttendees: json['maxAttendees'] ?? 0,
      rsvpList: (json['rsvpList'] as List<dynamic>? ?? [])
          .map((e) => Rsvp.fromJson(e))
          .toList(),
      qrCode: json['qrCode'] ?? '',
      organizer: Organizer.fromJson(organizerJson),
      business: Business.fromJson(businessJson),
    );
  }
}

class Rsvp {
  final String userId;
  final String status;
  final String rsvpAt;

  Rsvp({required this.userId, required this.status, required this.rsvpAt});

  factory Rsvp.fromJson(Map<String, dynamic> json) {
    return Rsvp(
      userId: json['user'] ?? '',
      status: json['status'] ?? '',
      rsvpAt: json['rsvpAt'] ?? '',
    );
  }
}

class Organizer {
  final String id;
  final String name;
  final String avatar;


  Organizer({required this.id, required this.name, required this.avatar});

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}

class Business {
  final String id;
  final String name;
  final String logo;
  final String phone;
  final String address;
  final String description;

  Business({
    required this.id,
    required this.name,
    required this.logo,
    required this.phone,
    required this.address,
    required this.description,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'] ?? {};
    String formattedAddress =
        "${addressJson['street'] ?? ''}, ${addressJson['city'] ?? ''}, ${addressJson['state'] ?? ''} ${addressJson['zip'] ?? ''}";
    return Business(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      phone: json['phone'] ?? '',
      address: formattedAddress,
      description:json["description"],
    );
  }
}
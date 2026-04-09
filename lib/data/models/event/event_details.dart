
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/data/models/event/event_model.dart';

class EventDetailsModel {
  final EventModel eventModel;

  final double lat;
  final double lng;
  final int maxAttendees;
  final int rsvpCount;
  final List<Rsvp> rsvpList;
  final String checkInCode;
  final bool isPublic;
  final String myRsvpStatus;
  final OrganizerBusiness organizerBusiness;

  EventDetailsModel({
    required this.eventModel,
    required this.lat,
    required this.lng,
    required this.maxAttendees,
    required this.rsvpCount,
    required this.rsvpList,
    required this.checkInCode,
    required this.isPublic,
    required this.myRsvpStatus,
    required this.organizerBusiness,
  });

  factory EventDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final coordinates = data['mapCoordinates'] ?? {};

    return EventDetailsModel(
      // pass data instead of json
      eventModel: EventModel.fromJson(data),

      lat: (coordinates['lat'] ?? 0).toDouble(),
      lng: (coordinates['lng'] ?? 0).toDouble(),

      maxAttendees: int.tryParse(data['maxParticipants'].toString()) ?? 0,

      rsvpCount:
          int.tryParse(data['rsvpCount'].toString()) ??
          (data['rsvpList'] as List?)?.length ??
          0,

      rsvpList: (data['rsvpList'] as List? ?? [])
          .map((e) => Rsvp.fromJson(e))
          .toList(),

      checkInCode: data['checkInCode'] ?? '',
      isPublic: data['isPublic'] ?? false,
      myRsvpStatus: data['myRsvpStatus'] ?? 'not_responded',

      organizerBusiness: OrganizerBusiness.fromJson(
        data['organizerBusiness'] ?? {},
      ),
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
      userId: json['user']?.toString() ?? '',
      status: json['status'] ?? '',
      rsvpAt: json['rsvpAt'] != null
          ? DateParserHelper.eventDateTime(
              DateTime.tryParse(json['rsvpAt']) ?? DateTime.now(),
            )
          : '',
    );
  }
}

class OrganizerBusiness {
  final String id;
  final String name;
  final String? logo;
  final String address;

  OrganizerBusiness({
    required this.id,
    required this.name,
    this.logo,
    required this.address,
  });

  factory OrganizerBusiness.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'] ?? {};

    final formattedAddress = [
      addressJson['street'],
      addressJson['city'],
      addressJson['state'],
      addressJson['zip'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    return OrganizerBusiness(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      address: formattedAddress,
    );
  }
}

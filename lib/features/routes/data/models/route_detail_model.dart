import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/features/routes/data/models/route_list_model.dart';

class RouteDetails {
  final RouteModel routeModel;
  final Coordinates coordinates;
  final OrganizerBusiness organizerBusiness;
  final String checkInCode;
  final String? mapUrl;
  final String? mapImage;
  final String qrCode;
  final int checkInCount;
  final CheckInStatus myCheckInStatus;
  final String status;

  RouteDetails({
    required this.routeModel,
    required this.coordinates,
    required this.organizerBusiness,
    required this.checkInCode,
    required this.myCheckInStatus,
    required this.checkInCount,
    required this.qrCode,
    required this.status,
    this.mapUrl,
    this.mapImage,
  });

  factory RouteDetails.fromJson(Map<String, dynamic> json) {
    return RouteDetails(
      routeModel: RouteModel.fromJson(json),
      coordinates: Coordinates.fromJson(json['mapCoordinates'] ?? {}),
      organizerBusiness: OrganizerBusiness.fromJson(
        json['organizerBusiness'] ?? {},
      ),
      checkInCode: json['checkInCode'] ?? '',
      qrCode: json['qrCode'] ?? "",
      mapUrl: json['url'],
      mapImage: json['mapImage'],
      checkInCount: (json["checkInCount"] as num?)?.toInt() ?? 0,
      myCheckInStatus: CheckInStatus.fromString(json["myCheckInStatus"] ?? ""),
      status: json['status']?.toString() ?? '',
    );
  }

  RouteDetails copyWith({
    RouteModel? routeModel,
    Coordinates? coordinates,
    OrganizerBusiness? organizerBusiness,
    String? checkInCode,
    CheckInStatus? myCheckInStatus,
    String? mapUrl,
    String? mapImage,
  }) {
    return RouteDetails(
      routeModel: routeModel ?? this.routeModel,
      coordinates: coordinates ?? this.coordinates,
      organizerBusiness: organizerBusiness ?? this.organizerBusiness,
      checkInCode: checkInCode ?? this.checkInCode,
      myCheckInStatus: myCheckInStatus ?? this.myCheckInStatus,
      checkInCount: checkInCount,
      qrCode: qrCode,
      status: status,
      mapUrl: mapUrl ?? this.mapUrl,
      mapImage: mapImage ?? this.mapImage,
    );
  }
}

// Coordinates model
class Coordinates {
  final double lat;
  final double lng;

  Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : 0.0,
      lng: (json['lng'] is num) ? (json['lng'] as num).toDouble() : 0.0,
    );
  }
}

// OrganizerBusiness model
class OrganizerBusiness {
  final String orgId;
  final String name;
  final String? logo;
  final String? description;
  final String? location;

  OrganizerBusiness({
    required this.name,
    this.logo,
    required this.orgId,
    this.description,
    this.location,
  });

  factory OrganizerBusiness.fromJson(Map<String, dynamic> json) {
    return OrganizerBusiness(
      orgId: json["_id"] ?? '',
      description: json["description"] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      location: json['location'],
    );
  }
}

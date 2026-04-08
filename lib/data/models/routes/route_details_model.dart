
// RouteDetails model
import 'package:loci/data/models/routes/routes_model.dart';

class RouteDetails {
  final RouteModel routeModel;
  final Coordinates coordinates;
  final OrganizerBusiness organizerBusiness;
  final String checkInCode;

  RouteDetails({
    required this.routeModel,
    required this.coordinates,
    required this.organizerBusiness,
    required this.checkInCode,
  });

  factory RouteDetails.fromJson(Map<String, dynamic> json) {
    return RouteDetails(
      routeModel: RouteModel.fromJson(json),
      coordinates: Coordinates.fromJson(json['mapCoordinates'] ?? {}),
      organizerBusiness: OrganizerBusiness.fromJson(json['organizerBusiness'] ?? {}),
      checkInCode: json['checkInCode'] ?? '',
    );
  }
}

// Coordinates model
class Coordinates {
  final double lat;
  final double lng;

  Coordinates({
    required this.lat,
    required this.lng,
  });

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

  OrganizerBusiness({
    required this.name,
    this.logo,
    required this.orgId,
    this.description,
  });

  factory OrganizerBusiness.fromJson(Map<String, dynamic> json) {
    return OrganizerBusiness(
      orgId: json["_id"] ?? '',
      description: json["description"] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
    );
  }
}


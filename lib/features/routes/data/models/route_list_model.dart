import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/features/routes/data/models/route_detail_model.dart';
import 'package:loci/shared/models/pagination_model.dart';

class RouteResponseModel {
  final String message;
  final List<RouteModel> routes;
  final PaginationMeta meta;

  RouteResponseModel({
    required this.message,
    required this.routes,
    required this.meta,
  });

  factory RouteResponseModel.fromJson(Map<String, dynamic> json) {
    return RouteResponseModel(
      message: json['message'] ?? '',
      routes: (json['data'] as List? ?? [])
          .map((e) => RouteModel.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

//-----RouteModel------------------------
class RouteModel {
  final String routeId;
  final String title;
  final String banner;
  final String details;
  final String openingTime;
  final String location;
  final String activityType;
  final String availabilityType;
  final bool isRoutePublic;
  final String url;
  final OrganizerBusiness organizerBusiness;
  final String status;
  final String? checkInCode;
  final String? qrCode;
  final int checkInCount;
  final CheckInStatus myCheckInStatus;
  final String? mapImage;
  final Coordinates? mapCoordinates;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RouteModel({
    required this.title,
    required this.banner,
    required this.details,
    required this.openingTime,
    required this.location,
    required this.activityType,
    required this.availabilityType,
    required this.routeId,
    required this.isRoutePublic,
    required this.url,
    required this.organizerBusiness,
    required this.status,
    required this.checkInCount,
    required this.myCheckInStatus,
    this.checkInCode,
    this.qrCode,
    this.mapImage,
    this.mapCoordinates,
    this.createdAt,
    this.updatedAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      routeId: json['_id'] ?? '',
      title: json['title'] ?? '',
      banner: json['banner'] ?? '',
      details: json['details'] ?? '',
      openingTime: json['openingTime'] ?? '',
      location: json['location'] ?? '',
      activityType: json['activityType'] ?? '',
      availabilityType: json['availabilityType'] ?? '',
      isRoutePublic: json['isPublic'] ?? false,
      url: json['url'] ?? '',
      organizerBusiness: OrganizerBusiness.fromJson(
        json['organizerBusiness'] ?? {},
      ),
      status: json['status'] ?? '',
      checkInCode: json['checkInCode'],
      qrCode: json['qrCode'],
      checkInCount: (json['checkInCount'] as num?)?.toInt() ?? 0,
      myCheckInStatus: CheckInStatus.fromString(json['myCheckInStatus'] ?? ''),
      mapImage: json['mapImage'],
      mapCoordinates: json['mapCoordinates'] != null
          ? Coordinates.fromJson(json['mapCoordinates'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}

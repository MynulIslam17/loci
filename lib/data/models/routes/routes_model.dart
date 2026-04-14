
import 'package:loci/data/models/common/paginatation_model.dart';

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

    );
  }
}







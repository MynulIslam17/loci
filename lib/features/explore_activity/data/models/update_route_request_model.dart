import 'dart:io';

import 'package:loci/core/enums/route_type.dart';

class RouteUpdateRequest {
  final String routeId;

  final String? title;
  final String? details;
  final String? location;
  final double? lat;
  final double? lng;
  final String? url;
  final String? openingTime;
  final RouteType? availabilityType;
  final bool? isPublic;
  final File? bannerFile;

  RouteUpdateRequest({
    required this.routeId,
    this.title,
    this.details,
    this.location,
    this.lat,
    this.lng,
    this.url,
    this.openingTime,
    this.availabilityType,
    this.isPublic,
    this.bannerFile,
  });

  /// Converts non-null text fields to a Map for Multipart requests.
  /// This ensures only changed data is sent to the server.
  Map<String, String> toFields() {
    final map = <String, String>{};

    if (title != null) map['title'] = title!;
    if (details != null) map['details'] = details!;
    if (location != null) map['location'] = location!;
    // Coordinates go as bracketed multipart fields; send both or neither.
    if (lat != null && lng != null) {
      map['mapCoordinates[lat]'] = lat.toString();
      map['mapCoordinates[lng]'] = lng.toString();
    }
    if (url != null) map['url'] = url!;
    if (openingTime != null) map['openingTime'] = openingTime!;
    if (isPublic != null) map['isPublic'] = isPublic.toString();

    if (availabilityType != null) {
      map['availabilityType'] = availabilityType!.apiValue;
    }

    return map;
  }

  /// Returns the file map if a new banner has been selected.
  Map<String, File>? toFiles() {
    if (bannerFile == null) return null;
    return {'banner': bannerFile!};
  }
}

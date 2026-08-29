import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/event/data/models/event_list_model.dart';

class EventDetailsModel {
  final EventModel eventModel;
  final double lat;
  final double lng;

  final int rsvpCount;
  final int checkInCount;
  final String? mapUrl;
  final String? mapImage;

  final List<Rsvp> rsvpList;
  final String checkInCode;
  final String qrCode;
  final bool isPublic;
  final CheckInStatus myCheckInStatus;

  final OrganizerBusiness organizerBusiness;
  final String status;

  EventDetailsModel({
    required this.eventModel,
    required this.lat,
    required this.lng,
    required this.rsvpCount,
    required this.checkInCount,
    required this.rsvpList,
    required this.checkInCode,
    required this.isPublic,
    required this.organizerBusiness,
    required this.myCheckInStatus,
    required this.qrCode,
    required this.status,
    this.mapUrl,
    this.mapImage,
  });

  factory EventDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    // Resolve coordinates from all possible backend shapes
    double resolvedLat = 0.0;
    double resolvedLng = 0.0;

    final rawCoords = data['mapCoordinates'] ??
        data['coordinates'] ??
        data['locationCoordinates'];

    if (rawCoords is Map) {
      resolvedLat = _coord(rawCoords['lat'] ?? rawCoords['latitude']);
      resolvedLng = _coord(rawCoords['lng'] ?? rawCoords['longitude']);
    } else if (rawCoords is List && rawCoords.length >= 2) {
      // GeoJSON Point format: [longitude, latitude]
      resolvedLng = _coord(rawCoords[0]);
      resolvedLat = _coord(rawCoords[1]);
    }

    // Check location object if present
    if (resolvedLat == 0.0 && resolvedLng == 0.0) {
      final loc = data['location'];
      if (loc is Map) {
        resolvedLat = _coord(loc['lat'] ?? loc['latitude']);
        resolvedLng = _coord(loc['lng'] ?? loc['longitude']);
        if (resolvedLat == 0.0 && resolvedLng == 0.0 && loc['coordinates'] is List) {
          final list = loc['coordinates'] as List;
          if (list.length >= 2) {
            resolvedLng = _coord(list[0]);
            resolvedLat = _coord(list[1]);
          }
        }
      }
    }

    // Direct keys on data root
    if (resolvedLat == 0.0 && resolvedLng == 0.0) {
      resolvedLat = _coord(data['lat'] ?? data['latitude']);
      resolvedLng = _coord(data['lng'] ?? data['longitude']);
    }

    // Fallback: Extract from mapImage URL (e.g. Google Static Map query parameters)
    final mapImageUrl = data['mapImage']?.toString() ?? data['url']?.toString();
    if (resolvedLat == 0.0 && resolvedLng == 0.0 && mapImageUrl != null) {
      final extracted = _extractCoordinatesFromUrl(mapImageUrl);
      if (extracted != null) {
        resolvedLat = extracted.$1;
        resolvedLng = extracted.$2;
      }
    }

    return EventDetailsModel(
      // pass data instead of json
      eventModel: EventModel.fromJson(data),

      lat: resolvedLat,
      lng: resolvedLng,

      rsvpCount:
          int.tryParse(data['rsvpCount'].toString()) ??
          (data['rsvpList'] as List?)?.length ??
          0,
      checkInCount: int.tryParse(data["checkInCount"].toString()) ?? 0,

      rsvpList: (data['rsvpList'] as List? ?? [])
          .map((e) => Rsvp.fromJson(e))
          .toList(),
      mapUrl: data['url'] ?? '',
      mapImage: mapImageUrl,

      checkInCode: data['checkInCode'] ?? '',
      qrCode: data["qrCode"] ?? '',
      myCheckInStatus: CheckInStatus.fromString(data['myCheckInStatus']),
      isPublic: data['isPublic'] ?? false,
      organizerBusiness: OrganizerBusiness.fromJson(
        data['organizerBusiness'] ?? {},
      ),
      status: data['status']?.toString() ?? '',
    );
  }

  // for update the model
  EventDetailsModel copyWith({
    EventModel? eventModel,
    int? rsvpCount,
    int? checkInCount,
    CheckInStatus? myCheckInStatus,
    String? mapUrl,
    String? mapImage,
  }) {
    return EventDetailsModel(
      eventModel: eventModel ?? this.eventModel,
      lat: lat,
      lng: lng,
      rsvpCount: rsvpCount ?? this.rsvpCount,
      checkInCount: checkInCount ?? this.checkInCount,
      rsvpList: rsvpList,
      checkInCode: checkInCode,
      isPublic: isPublic,
      myCheckInStatus: myCheckInStatus ?? this.myCheckInStatus,
      organizerBusiness: organizerBusiness,
      qrCode: qrCode,
      status: status,
      mapUrl: mapUrl ?? this.mapUrl,
      mapImage: mapImage ?? this.mapImage,
    );
  }

  static double _coord(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Extracts coordinates from static map URLs (e.g. center=23.79,90.40 or markers=23.79,90.40)
  static (double, double)? _extractCoordinatesFromUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    try {
      final uri = Uri.tryParse(url.trim());
      if (uri != null) {
        final center = uri.queryParameters['center'];
        if (center != null && center.contains(',')) {
          final parts = center.split(',');
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null && (lat != 0 || lng != 0)) {
            return (lat, lng);
          }
        }

        final markers = uri.queryParameters['markers'] ?? uri.queryParameters['marker'];
        if (markers != null) {
          final regex = RegExp(r'(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)');
          final match = regex.firstMatch(markers);
          if (match != null) {
            final lat = double.tryParse(match.group(1)!);
            final lng = double.tryParse(match.group(2)!);
            if (lat != null && lng != null && (lat != 0 || lng != 0)) {
              return (lat, lng);
            }
          }
        }
      }
    } catch (_) {}
    return null;
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
  final String description;

  OrganizerBusiness({
    required this.id,
    required this.name,
    this.logo,
    required this.address,
    required this.description,
  });

  factory OrganizerBusiness.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'] ?? {};

    final formattedAddress = [
      addressJson['street'],
      addressJson['city'],
      addressJson['state'],
      addressJson['zip'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    final locationText = json['location']?.toString().trim() ?? '';

    return OrganizerBusiness(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      description: json['description']?.toString() ?? '',
      address: formattedAddress.isNotEmpty ? formattedAddress : locationText,
    );
  }
}

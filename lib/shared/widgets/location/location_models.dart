/// A single autocomplete suggestion from `GET /places/autocomplete`.
/// Deliberately carries no coordinates — those come from the details call.
class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  final String placeId;

  /// Bold primary line (e.g. "742 W Randolph St").
  final String mainText;

  /// Grey secondary line (e.g. "Chicago, IL, USA").
  final String secondaryText;

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['placeId']?.toString() ?? '',
      mainText: json['mainText']?.toString() ?? '',
      secondaryText: json['secondaryText']?.toString() ?? '',
    );
  }
}

/// Resolved place from `GET /places/{placeId}/details`.
class PlaceDetails {
  const PlaceDetails({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String name;
  final String address;
  final double lat;
  final double lng;

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>? ?? const {};
    return PlaceDetails(
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      lat: (coords['lat'] as num?)?.toDouble() ?? 0,
      lng: (coords['lng'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// What the picker hands back to a form: the display address plus coordinates.
class PickedLocation {
  const PickedLocation({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  @override
  String toString() => 'PickedLocation($address, $lat, $lng)';
}

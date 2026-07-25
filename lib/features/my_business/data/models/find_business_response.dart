class Business {
  final String source;
  final String placeId;
  final String? businessId;
  final String name;
  final String location;
  final String? description;
  final String phone;
  final String website;
  final Coordinates coordinates;
  final String? category;
  final String? logo;
  final String? claimStatus;
  final List<String> types;
  final String? suggestedCategory;

  Business({
    required this.source,
    required this.placeId,
    this.businessId,
    required this.name,
    required this.location,
    this.description,
    required this.phone,
    required this.website,
    required this.coordinates,
    this.category,
    this.logo,
    this.claimStatus,
    required this.types,
    this.suggestedCategory,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      source: json['source'] ?? '',
      placeId: json['placeId'] ?? '',
      businessId: json['businessId'] as String?,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] as String?,
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      coordinates: json['coordinates'] is Map<String, dynamic>
          ? Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
          : const Coordinates(lat: 0, lng: 0),
      category: json['category'] as String?,
      logo: json['logo'] as String?,
      claimStatus: json['claimStatus'] as String?,
      types:
          (json['types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      suggestedCategory: json['suggestedCategory'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'source': source,
    'placeId': placeId,
    'businessId': businessId,
    'name': name,
    'location': location,
    'description': description,
    'phone': phone,
    'website': website,
    'coordinates': coordinates.toJson(),
    'category': category,
    'logo': logo,
    'claimStatus': claimStatus,
    'types': types,
    'suggestedCategory': suggestedCategory,
  };
}

class Coordinates {
  final double lat;
  final double lng;

  const Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

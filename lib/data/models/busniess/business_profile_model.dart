class BusinessModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String phone;
  final String logo;
  final double rating;
  final int reviewCount;
  final List<String> photos;
  final bool isActive;
  final AddressModel address;
  final OwnerModel owner;
  final CommunityModel community;

  BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.phone,
    required this.logo,
    required this.rating,
    required this.photos,
    required this.reviewCount,
    required this.isActive,
    required this.address,
    required this.owner,
    required this.community,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      logo: json['logo'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isActive: json['isActive'] ?? false,
      address: AddressModel.fromJson(json['address'] ?? {}),
      owner: OwnerModel.fromJson(json['owner'] ?? {}),
      community: CommunityModel.fromJson(json['communityId'] ?? {}),
      photos: List<String>.from(json['photos'] ?? []),
    );
  }
}

class AddressModel {
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;

  AddressModel({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zip: json['zip'] ?? '',
      country: json['country'] ?? '',
    );
  }
}



class OwnerModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String? phone;

  OwnerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    this.phone,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      phone: json['phone'],
    );
  }
}


class CommunityModel {
  final String id;
  final String name;
  final String qrCode;
  final int memberCount;

  CommunityModel({
    required this.id,
    required this.name,
    required this.qrCode,
    required this.memberCount,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      qrCode: json['qrCode'] ?? '',
      memberCount: json['memberCount'] ?? 0,
    );
  }
}
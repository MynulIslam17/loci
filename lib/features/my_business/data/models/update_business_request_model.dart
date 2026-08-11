import 'package:loci/features/my_business/data/models/business_profile_model.dart';

class UpdateBusinessRequest {
  final String? name;
  final String? category;
  final String? phone;
  final String? location;
  final String? description;

  UpdateBusinessRequest({
    this.name,
    this.category,
    this.phone,
    this.location,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) "name": name,
      if (category != null) "category": category,
      if (phone != null) "phone": phone,
      if (location != null) "location": location,
      if (description != null) "description": description,
    };
  }

  /// PATCH body containing only fields that differ from [current].
  Map<String, dynamic> diffFrom(BusinessProfileModel current) {
    final map = <String, dynamic>{};
    if (name != null && name!.trim() != current.name) {
      map['name'] = name!.trim();
    }
    if (category != null && category!.trim() != current.category) {
      map['category'] = category!.trim();
    }
    if (phone != null && phone!.trim() != current.phone) {
      map['phone'] = phone!.trim();
    }
    if (location != null && location!.trim() != current.location) {
      map['location'] = location!.trim();
    }
    if (description != null && description!.trim() != current.description) {
      map['description'] = description!.trim();
    }
    return map;
  }
}

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
}
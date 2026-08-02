class BusinessActivityModel {
  final String id;
  final String businessName;
  final String category;
  final String? lastVisited;
  final String businessLogo;

  BusinessActivityModel({
    required this.id,
    required this.businessName,
    required this.category,
    this.lastVisited,
    required this.businessLogo,
  });

  factory BusinessActivityModel.fromJson(Map<String, dynamic> json) {
    return BusinessActivityModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      businessName: json['businessName'] ?? '',
      category: json['category'] ?? '',
      lastVisited: json['lastVisited']?.toString(),
      businessLogo: json['businessLogo'] ?? '',
    );
  }

  DateTime? get date {
    final value = lastVisited;
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

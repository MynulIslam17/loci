class BusinessActivityModel {
  final String businessName;
  final String category;
  final String lastVisited;

  BusinessActivityModel({
    required this.businessName,
    required this.category,
    required this.lastVisited,
  });

  factory BusinessActivityModel.fromJson(Map<String, dynamic> json) {
    return BusinessActivityModel(
      businessName: json['businessName'] ?? '',
      category: json['category'] ?? '',
      lastVisited: json['lastVisited'] ?? '',
    );
  }
}
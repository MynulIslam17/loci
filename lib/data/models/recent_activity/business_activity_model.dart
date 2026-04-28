class BusinessActivityModel {
  final String businessName;
  final String category;
  final String lastVisited;
  final String businessLogo;

  BusinessActivityModel({
    required this.businessName,
    required this.category,
    required this.lastVisited,
    required this.businessLogo,
  });

  factory BusinessActivityModel.fromJson(Map<String, dynamic> json) {
    return BusinessActivityModel(
      businessName: json['businessName'] ?? '',
      category: json['category'] ?? '',
      lastVisited: json['lastVisited'] ?? '',
      businessLogo: json['businessLogo'] ?? '',
    );
  }



  DateTime? get date {
    if (lastVisited.isEmpty) return null;
    return DateTime.tryParse(lastVisited);
  }

}
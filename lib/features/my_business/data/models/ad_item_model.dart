class AdItemModel {
  final String id;
  final String title;
  final String businessName;
  final String location;
  final String imageUrl;
  final String linkUrl;
  final bool isFallback;

  AdItemModel({
    required this.id,
    required this.title,
    required this.businessName,
    required this.location,
    required this.imageUrl,
    required this.linkUrl,
    required this.isFallback,
  });

  factory AdItemModel.fromJson(Map<String, dynamic> json) {
    return AdItemModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      businessName: (json['businessName'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      linkUrl: (json['linkUrl'] ?? '').toString(),
      isFallback: json['isFallback'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'businessName': businessName,
    'location': location,
    'imageUrl': imageUrl,
    'linkUrl': linkUrl,
    'isFallback': isFallback,
  };
}

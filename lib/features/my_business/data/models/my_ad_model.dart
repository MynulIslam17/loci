class MyAdModel {
  final String id;
  final String title;
  final String businessName;
  final String location;
  final String imageUrl;
  final String? linkUrl;
  final String status;
  final String schedule;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MyAdModel({
    required this.id,
    required this.title,
    required this.businessName,
    required this.location,
    required this.imageUrl,
    this.linkUrl,
    required this.status,
    required this.schedule,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isActive => status.toLowerCase() == 'active';

  factory MyAdModel.fromJson(Map<String, dynamic> json) {
    return MyAdModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      businessName: (json['businessName'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      linkUrl: json['linkUrl']?.toString(),
      status: (json['status'] ?? '').toString(),
      schedule: (json['schedule'] ?? '').toString(),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

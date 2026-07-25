class NotificationModel {
  final String id;
  final String recipient;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool actionRequired;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.recipient,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.actionRequired,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      recipient: json['recipient'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      actionRequired: json['actionRequired'] ?? false,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'recipient': recipient,
    'type': type,
    'title': title,
    'body': body,
    'data': data,
    'actionRequired': actionRequired,
    'isRead': isRead,
    'createdAt': createdAt,
  };
}

import 'package:loci/core/enums/notification_type.dart';

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
      id: _readId(json['_id'] ?? json['id']),
      recipient: _readId(json['recipient']),
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      data: _readPayload(json['data']),
      actionRequired: json['actionRequired'] == true,
      isRead: json['isRead'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  static String _readId(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value.toString();
  }

  static Map<String, dynamic> _readPayload(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
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

extension NotificationModelX on NotificationModel {
  NotificationType get notificationType => NotificationType.fromString(type);

  String? get entityId {
    final value = data['entityId'];
    return value is String && value.isNotEmpty ? value : null;
  }

  String? get businessId {
    final value = data['businessId'];
    return value is String && value.isNotEmpty ? value : null;
  }

  String? get communityId {
    final value = data['communityId'];
    return value is String && value.isNotEmpty ? value : null;
  }

  bool get showsInlineActions =>
      notificationType.hasInlineActions && actionRequired;

  bool get isTappable =>
      !showsInlineActions && notificationType.opensDetailScreen;
}



class CheckInModel {
  final String id;
  final String entityType;
  final String entityId;
  final String scannedAt;
  final LeadData leadData;
  final String entityName;

  CheckInModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.scannedAt,
    required this.leadData,
    required this.entityName,
  });

  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    return CheckInModel(
      id: json['_id'] ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId'] ?? '',
      scannedAt: json['scannedAt'] ?? '',
      leadData: LeadData.fromJson(json['leadData'] ?? {}),
      entityName: json['entityName'] ?? '',
    );
  }



  // ================= SIMPLE TIME AGO =================
  String get timeAgo {
    if (scannedAt.isEmpty) return '';

    final date = DateTime.tryParse(scannedAt);
    if (date == null) return '';

    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} day ago';

    return '${(diff.inDays / 7).floor()} week ago';
  }


}

//─────────────────────────────────────────
// check_in_item.dart
// ─────────────────────────────────────────
class LeadData {
  final String name;
  final String email;
  final String avatar;

  LeadData({
    required this.name,
    required this.email,
    required this.avatar,
  });

  factory LeadData.fromJson(Map<String, dynamic> json) {
    return LeadData(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}
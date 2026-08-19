import 'package:loci/core/utils/date_parser.dart';

class RsvpAttendeeModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String status;
  final String respondedAt;

  const RsvpAttendeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.status,
    required this.respondedAt,
  });

  factory RsvpAttendeeModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};

    return RsvpAttendeeModel(
      id: userMap['_id']?.toString() ?? json['_id']?.toString() ?? '',
      name: userMap['name']?.toString() ?? 'Attendee',
      email: userMap['email']?.toString() ?? '',
      avatar: userMap['avatar']?.toString() ?? '',
      status: json['status']?.toString() ?? 'going',
      respondedAt: json['respondedAt']?.toString() ??
          json['rsvpAt']?.toString() ??
          '',
    );
  }

  String get formattedDate {
    if (respondedAt.isEmpty) return '';
    final dt = DateTime.tryParse(respondedAt);
    if (dt == null) return respondedAt;
    return DateParserHelper.toFriendlyDate(dt.toLocal());
  }
}

class CheckInAttendeeModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String phone;
  final String company;
  final String scannedAt;

  const CheckInAttendeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.phone,
    required this.company,
    required this.scannedAt,
  });

  factory CheckInAttendeeModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};
    final leadData = json['leadData'];
    final leadMap =
        leadData is Map<String, dynamic> ? leadData : <String, dynamic>{};

    final leadName = leadMap['name']?.toString().trim();
    final userName = userMap['name']?.toString().trim();
    final effectiveName = (leadName != null && leadName.isNotEmpty)
        ? leadName
        : ((userName != null && userName.isNotEmpty) ? userName : 'Attendee');

    final leadEmail = leadMap['email']?.toString().trim();
    final userEmail = userMap['email']?.toString().trim();
    final effectiveEmail = (leadEmail != null && leadEmail.isNotEmpty)
        ? leadEmail
        : (userEmail ?? '');

    final leadAvatar = leadMap['avatar']?.toString().trim();
    final userAvatar = userMap['avatar']?.toString().trim();
    final effectiveAvatar = (leadAvatar != null && leadAvatar.isNotEmpty)
        ? leadAvatar
        : (userAvatar ?? '');

    return CheckInAttendeeModel(
      id: json['_id']?.toString() ?? userMap['_id']?.toString() ?? '',
      name: effectiveName,
      email: effectiveEmail,
      avatar: effectiveAvatar,
      phone: userMap['phone']?.toString() ?? leadMap['phone']?.toString() ?? '',
      company: userMap['company']?.toString() ??
          leadMap['company']?.toString() ??
          '',
      scannedAt: json['scannedAt']?.toString() ??
          json['checkedInAt']?.toString() ??
          json['createdAt']?.toString() ??
          '',
    );
  }

  String get formattedDate {
    if (scannedAt.isEmpty) return '';
    final dt = DateTime.tryParse(scannedAt);
    if (dt == null) return scannedAt;
    return DateParserHelper.toFriendlyDate(dt.toLocal());
  }
}

class RaffleParticipantAttendeeModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String phone;
  final String company;
  final String? voucherCode;
  final int completedTasks;
  final int totalTasks;
  final int completionPercentage;
  final bool isCompleted;
  final String joinedAt;

  const RaffleParticipantAttendeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.phone,
    required this.company,
    this.voucherCode,
    required this.completedTasks,
    required this.totalTasks,
    required this.completionPercentage,
    required this.isCompleted,
    required this.joinedAt,
  });

  factory RaffleParticipantAttendeeModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};
    final progress = json['progress'] is Map<String, dynamic>
        ? json['progress'] as Map<String, dynamic>
        : <String, dynamic>{};

    final userName = userMap['name']?.toString().trim();
    final effectiveName =
        (userName != null && userName.isNotEmpty) ? userName : 'Participant';

    final userEmail = userMap['email']?.toString().trim() ?? '';
    final userAvatar = userMap['avatar']?.toString().trim() ?? '';
    final userPhone = userMap['phone']?.toString().trim() ?? '';
    final userCompany = userMap['company']?.toString().trim() ?? '';

    final completedTasks =
        (progress['completedTasks'] as num?)?.toInt() ?? 0;
    final totalTasks = (progress['totalTasks'] as num?)?.toInt() ?? 0;
    final completionPct =
        (progress['completionPercentage'] as num?)?.toInt() ??
            (totalTasks > 0 ? ((completedTasks / totalTasks) * 100).toInt() : 0);

    final voucher = json['voucherCode']?.toString() ??
        progress['voucherCode']?.toString();

    final isDone = json['isCompleted'] == true ||
        progress['isCompleted'] == true ||
        (voucher != null && voucher.isNotEmpty) ||
        (totalTasks > 0 && completedTasks >= totalTasks);

    return RaffleParticipantAttendeeModel(
      id: json['_id']?.toString() ?? userMap['_id']?.toString() ?? '',
      name: effectiveName,
      email: userEmail,
      avatar: userAvatar,
      phone: userPhone,
      company: userCompany,
      voucherCode: voucher,
      completedTasks: completedTasks,
      totalTasks: totalTasks,
      completionPercentage: completionPct,
      isCompleted: isDone,
      joinedAt: json['joinedAt']?.toString() ??
          json['createdAt']?.toString() ??
          '',
    );
  }

  String get formattedDate {
    if (joinedAt.isEmpty) return '';
    final dt = DateTime.tryParse(joinedAt);
    if (dt == null) return joinedAt;
    return DateParserHelper.toFriendlyDate(dt.toLocal());
  }
}

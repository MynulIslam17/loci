import 'package:loci/core/enums/referral_enum.dart';
import 'package:loci/shared/models/pagination_model.dart';

// ─────────────────────────────────────────────
// ROOT RESPONSE
// ─────────────────────────────────────────────
class ReferralResponse {
  final bool success;
  final String message;
  final List<ReferralModel> data;
  final PaginationMeta meta;

  ReferralResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((e) => ReferralModel.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta']),
    );
  }
}

// ─────────────────────────────────────────────
// REFERRAL MODEL
// ─────────────────────────────────────────────
class ReferralModel {
  final String id;
  final ReferralPerson recipient;
  final ReferralPerson businessOwner;
  final ReferralPerson referredBy;
  final ReferralStatus status;
  final String message;
  final String createdAt;
  final String updatedAt;

  ReferralModel({
    required this.id,
    required this.recipient,
    required this.businessOwner,
    required this.referredBy,
    required this.status,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] ?? '',
      recipient: ReferralPerson.fromJson(json['recipient'] ?? {}),
      businessOwner: ReferralPerson.fromJson(json['businessOwner'] ?? {}),
      referredBy: ReferralPerson.fromJson(json['referredBy'] ?? {}),
      status: ReferralStatus.fromString(json['status']),
      message: json['message'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient': recipient.toJson(),
      'businessOwner': businessOwner.toJson(),
      'referredBy': referredBy.toJson(),
      'status': status.toJson,
      'message': message,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// ─────────────────────────────────────────────
// REFERRAL PERSON
// ─────────────────────────────────────────────
class ReferralPerson {
  final String fullName;
  final String email;
  final String companyName;

  ReferralPerson({
    required this.fullName,
    required this.email,
    required this.companyName,
  });

  factory ReferralPerson.fromJson(Map<String, dynamic> json) {
    return ReferralPerson(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      companyName: json['companyName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'fullName': fullName, 'email': email, 'companyName': companyName};
  }
}

import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/enums/activity_type.dart';

import '../../../core/enums/announcement_type.dart';
import '../busniess/my_business_list_model.dart';
import '../event/event_model.dart';
import '../raffles/raffles_model.dart';
import '../routes/routes_model.dart';




// class AnnouncementModel {
//   final String id;
//   final AnnouncementType announcementType;
//   final String communityId;
//
//   final BusinessModel? business;
//   final CreatedUser? createdBy;
//
//   final String createdAt;
//   final String updatedAt;
//   final String details;
//
//   final ActivityRefType? activityRefType;
//   final String? activityId;
//
//   final EventModel? event;
//   final RouteModel? route;
//   final RaffleModel? raffle;
//
//   final String? image;
//   final int? likeCount;
//   final int? commentCount;
//
//   AnnouncementModel({
//     required this.id,
//     required this.announcementType,
//     required this.communityId,
//     this.business,
//     this.createdBy,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.details,
//     this.activityRefType,
//     this.activityId,
//     this.event,
//     this.route,
//     this.raffle,
//     this.image,
//     this.likeCount,
//     this.commentCount,
//   });
//
//   factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
//     return AnnouncementModel(
//       id: json['_id'] ?? '',
//       announcementType: AnnouncementType.fromString(json['type']),
//       communityId: json['communityId'] ?? '',
//       business: json['business'] != null
//           ? BusinessModel.fromJson(json['business'])
//           : null,
//       createdBy: json['createdBy'] != null
//           ? CreatedUser.fromJson(json['createdBy'])
//           : null,
//       createdAt: json['createdAt'] ?? '',
//       updatedAt: json['updatedAt'] ?? '',
//       details: json['details'] ?? '',
//       activityRefType: ActivityRefType.fromString(json['activityRefType']),
//       activityId: json['activityId'],
//       event: json['event'] != null
//           ? EventModel.fromJson(json['event'])
//           : null,
//       route: json['route'] != null
//           ? RouteModel.fromJson(json['route'])
//           : null,
//       raffle: json['raffle'] != null
//           ? RaffleModel.fromJson(json['raffle'])
//           : null,
//       image: json['image'],
//       likeCount: json['likeCount'],
//       commentCount: json['commentCount'],
//     );
//   }
//
//
//   AnnouncementModel copyWith({
//     String? id,
//     AnnouncementType? announcementType,
//     String? communityId,
//     BusinessModel? business,
//     CreatedUser? createdBy,
//     String? createdAt,
//     String? updatedAt,
//     String? details,
//     ActivityRefType? activityRefType,
//     String? activityId,
//     EventModel? event,
//     RouteModel? route,
//     RaffleModel? raffle,
//     String? image,
//     int? likeCount,
//     int? commentCount,
//   }) {
//     return AnnouncementModel(
//       id: id ?? this.id,
//       announcementType: announcementType ?? this.announcementType,
//       communityId: communityId ?? this.communityId,
//       business: business ?? this.business,
//       createdBy: createdBy ?? this.createdBy,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       details: details ?? this.details,
//       activityRefType: activityRefType ?? this.activityRefType,
//       activityId: activityId ?? this.activityId,
//       event: event ?? this.event,
//       route: route ?? this.route,
//       raffle: raffle ?? this.raffle,
//       image: image ?? this.image,
//       likeCount: likeCount ?? this.likeCount,
//       commentCount: commentCount ?? this.commentCount,
//     );
//   }
//
//
// }

// class CreatedUser {
//   final String id;
//   final String name;
//   final String avatar;
//
//   CreatedUser({
//     required this.id,
//     required this.name,
//     required this.avatar,
//   });
//
//   factory CreatedUser.fromJson(Map<String, dynamic> json) {
//     return CreatedUser(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       avatar: json['avatar'] ?? '',
//     );
//   }
// }

import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/enums/activity_type.dart';

import '../../../core/enums/announcement_type.dart';
import '../busniess/my_business_list_model.dart';
import '../event/event_model.dart';
import '../raffles/raffles_model.dart';
import '../routes/routes_model.dart';

class AnnouncementModel {
  final String id;
  final AnnouncementType announcementType;
  final String communityId;

  final BusinessModel? business;
  final CreatedUser? createdBy;

  final String createdAt;
  final String updatedAt;
  final String details;

  final ActivityRefType? activityRefType;
  final String? activityId;

  final EventModel? event;
  final RouteModel? route;
  final RaffleModel? raffle;

  final String? image;
  final int? likeCount;
  final int? commentCount;

  // Poll fields (only for question type)
  final String? pollQuestion;
  final List<PollOption>? pollOptions;
  final int? maxVotesPerUser;
  final String? endsAt;
  final int? totalVotes;

  AnnouncementModel({
    required this.id,
    required this.announcementType,
    required this.communityId,
    this.business,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
    this.activityRefType,
    this.activityId,
    this.event,
    this.route,
    this.raffle,
    this.image,
    this.likeCount,
    this.commentCount,
    this.pollQuestion,
    this.pollOptions,
    this.maxVotesPerUser,
    this.endsAt,
    this.totalVotes,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['_id'] ?? '',
      announcementType: AnnouncementType.fromString(json['type']),
      communityId: json['communityId'] ?? '',
      business: json['business'] != null
          ? BusinessModel.fromJson(json['business'])
          : null,
      createdBy: json['createdBy'] != null
          ? CreatedUser.fromJson(json['createdBy'])
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      details: json['details'] ?? '',
      activityRefType: ActivityRefType.fromString(json['activityRefType']),
      activityId: json['activityId'],
      event: json['event'] != null
          ? EventModel.fromJson(json['event'])
          : null,
      route: json['route'] != null
          ? RouteModel.fromJson(json['route'])
          : null,
      raffle: json['raffle'] != null
          ? RaffleModel.fromJson(json['raffle'])
          : null,
      image: json['image'],
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      pollQuestion: json['pollQuestion'],
      pollOptions: json['pollOptions'] != null
          ? (json['pollOptions'] as List<dynamic>)
          .map((e) => PollOption.fromJson(e))
          .toList()
          : null,
      maxVotesPerUser: json['maxVotesPerUser'],
      endsAt: json['endsAt'],
      totalVotes: json['totalVotes'],
    );
  }

  AnnouncementModel copyWith({
    String? id,
    AnnouncementType? announcementType,
    String? communityId,
    BusinessModel? business,
    CreatedUser? createdBy,
    String? createdAt,
    String? updatedAt,
    String? details,
    ActivityRefType? activityRefType,
    String? activityId,
    EventModel? event,
    RouteModel? route,
    RaffleModel? raffle,
    String? image,
    int? likeCount,
    int? commentCount,
    String? pollQuestion,
    List<PollOption>? pollOptions,
    int? maxVotesPerUser,
    String? endsAt,
    int? totalVotes,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      announcementType: announcementType ?? this.announcementType,
      communityId: communityId ?? this.communityId,
      business: business ?? this.business,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      details: details ?? this.details,
      activityRefType: activityRefType ?? this.activityRefType,
      activityId: activityId ?? this.activityId,
      event: event ?? this.event,
      route: route ?? this.route,
      raffle: raffle ?? this.raffle,
      image: image ?? this.image,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      pollQuestion: pollQuestion ?? this.pollQuestion,
      pollOptions: pollOptions ?? this.pollOptions,
      maxVotesPerUser: maxVotesPerUser ?? this.maxVotesPerUser,
      endsAt: endsAt ?? this.endsAt,
      totalVotes: totalVotes ?? this.totalVotes,
    );
  }
}

// -------------------------------------------------
// POLL OPTION MODEL
// -------------------------------------------------
class PollOption {
  final String id;
  final String text;
  final String? image;
  final int voteCount;

  PollOption({
    required this.id,
    required this.text,
    this.image,
    required this.voteCount,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      image: json['image'],
      voteCount: json['voteCount'] ?? 0,
    );
  }

  PollOption copyWith({
    String? id,
    String? text,
    String? image,
    int? voteCount,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      image: image ?? this.image,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}

// -------------------------------------------------
// CREATED USER MODEL
// -------------------------------------------------
class CreatedUser {
  final String id;
  final String name;
  final String avatar;

  CreatedUser({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory CreatedUser.fromJson(Map<String, dynamic> json) {
    return CreatedUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}

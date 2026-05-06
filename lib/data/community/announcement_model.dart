import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/enums/activity_type.dart';

import '../../core/enums/announcement_type.dart';
import '../models/busniess/my_business_list_model.dart';
import '../models/event/event_model.dart';
import '../models/raffles/raffles_model.dart';
import '../models/routes/routes_model.dart';


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
    );
  }
}

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
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/enums/question_type.dart';
import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/event/data/models/event_list_model.dart';
import 'package:loci/features/raffles/data/models/raffle_list_model.dart';
import 'package:loci/features/routes/data/models/route_list_model.dart';

class AnnouncementModel {
  final String id;
  final AnnouncementType announcementType;
  final QuestionType qType;
  final String communityId;
  final bool isLiked;

  final BusinessModel? business;
  final CreatedUser? createdBy;

  final String createdAt;
  final String updatedAt;
  final String details;
  final String? pollCategory;

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

  /// True when the post was published as the community business (owner/moderator),
  /// not when [business] merely describes the community.
  final bool postedAsBusiness;

  AnnouncementModel({
    required this.id,
    required this.announcementType,
    required this.qType,
    required this.communityId,
    this.business,
    this.createdBy,
    this.pollCategory,
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
    required this.isLiked,
    this.postedAsBusiness = false,
  });

  /// Primary body text for feed / question cards.
  String get feedBodyText {
    if (announcementType == AnnouncementType.question) {
      final q = pollQuestion?.trim();
      if (q != null && q.isNotEmpty) return q;
      return details;
    }
    return details;
  }

  /// True when this announcement should use the home-style poll card
  /// (mention field + vote UI), even if the API omitted `qtype`.
  bool get isPollPost =>
      qType == QuestionType.poll ||
      (announcementType == AnnouncementType.question &&
          pollOptions != null &&
          pollOptions!.isNotEmpty);

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final type = AnnouncementType.fromString(json['type']);
    final rawQType = (json['qtype'] ??
        json['qType'] ??
        json['q_type'] ??
        (json['type'] == 'poll' ? 'poll' : null)) as String?;
    final optionsRaw = json['options'] ?? json['pollOptions'];
    final hasPollOptions = optionsRaw is List && optionsRaw.isNotEmpty;
    // Some API payloads omit qtype on poll posts that already have options —
    // without this, the mention field / poll UX never appears (unlike home).
    final qType = QuestionType.fromString(rawQType) == QuestionType.poll ||
            (type == AnnouncementType.question &&
                hasPollOptions &&
                (rawQType == null || rawQType.toString().isEmpty))
        ? QuestionType.poll
        : QuestionType.fromString(rawQType);

    return AnnouncementModel(
      id: json['_id'] ?? json['id'] ?? '',
      isLiked: json["isLiked"] ?? false,
      announcementType: type,
      qType: qType,
      communityId: json['communityId'] ?? '',
      pollCategory: (json['pollCategory'] ?? json['category']) as String?,
      business: json['business'] != null
          ? BusinessModel.fromJson(json['business'])
          : null,
      createdBy: json['createdBy'] != null
          ? CreatedUser.fromJson(json['createdBy'])
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      details: _detailsFromJson(json, type),
      postedAsBusiness: _postedAsBusinessFromJson(json),
      activityRefType: ActivityRefType.fromString(json['activityRefType']),
      activityId: json['activityId'],
      event: json['event'] != null ? EventModel.fromJson(json['event']) : null,
      route: json['route'] != null ? RouteModel.fromJson(json['route']) : null,
      raffle: json['raffle'] != null
          ? RaffleModel.fromJson(json['raffle'])
          : null,
      image: json['image'],
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      pollQuestion: type == AnnouncementType.question
          ? (json['pollQuestion'] ??
                  json['content'] ??
                  json['question'] ??
                  json['details'])
              as String?
          : null,
      pollOptions: optionsRaw != null
          ? (optionsRaw as List<dynamic>)
                .map(
                  (e) => PollOption.fromJson(
                    e is Map<String, dynamic> ? e : {},
                  ),
                )
                .toList()
          : null,
      maxVotesPerUser: json['maxVotesPerUser'],
      endsAt: json['endsAt'],
      totalVotes: json['totalVotes'],
    );
  }

  static String _detailsFromJson(
    Map<String, dynamic> json,
    AnnouncementType type,
  ) {
    switch (type) {
      case AnnouncementType.activity:
        return json['description']?.toString() ?? '';
      case AnnouncementType.question:
        return json['details']?.toString() ?? '';
      case AnnouncementType.offer:
      case AnnouncementType.notice:
        return json['details']?.toString() ?? '';
    }
  }

  /// Owner posts show this community's business; member posts show [createdBy].
  bool displaysAsCommunityBusiness({String? communityOwnerUserId}) {
    if (postedAsBusiness && business != null && business!.name.isNotEmpty) {
      return true;
    }
    final creatorId = createdBy?.id;
    if (communityOwnerUserId != null &&
        communityOwnerUserId.isNotEmpty &&
        creatorId != null &&
        creatorId == communityOwnerUserId) {
      return business != null && business!.name.isNotEmpty;
    }
    return false;
  }

  /// Whether the author chose to publish as the community business (owner).
  /// Nested [business] is community context and must not imply this flag alone.
  static bool _postedAsBusinessFromJson(Map<String, dynamic> json) {
    final postedAs = json['postedAs']?.toString().toLowerCase();
    if (postedAs == 'business') return true;
    if (postedAs == 'user' || postedAs == 'member') return false;

    if (json['postedAsBusiness'] == true || json['isBusinessPost'] == true) {
      return true;
    }

    // Owner create sends businessId; member posts usually omit it on the document.
    final rootBusinessId = json['businessId']?.toString();
    if (rootBusinessId == null || rootBusinessId.isEmpty) return false;

    final business = json['business'];
    if (business is Map<String, dynamic>) {
      final nestedId = business['_id']?.toString();
      if (nestedId != null && nestedId.isNotEmpty) {
        return rootBusinessId == nestedId;
      }
    }
    return true;
  }

  AnnouncementModel copyWith({
    String? id,
    AnnouncementType? announcementType,
    QuestionType? qType,
    String? communityId,
    BusinessModel? business,
    CreatedUser? createdBy,
    String? createdAt,
    String? updatedAt,
    String? details,
    String? pollCategory,
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
    bool? isLiked,
    bool? postedAsBusiness,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      announcementType: announcementType ?? this.announcementType,
      qType: qType ?? this.qType,
      communityId: communityId ?? this.communityId,
      business: business ?? this.business,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      pollCategory: pollCategory ?? this.pollCategory,
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
      isLiked: isLiked ?? this.isLiked,
      postedAsBusiness: postedAsBusiness ?? this.postedAsBusiness,
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
  final double percentage;
  final List<Voter> voters;

  PollOption({
    required this.id,
    required this.text,
    this.image,
    required this.voteCount,
    this.percentage = 0,
    this.voters = const [],
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['optionId']?.toString() ?? json['_id']?.toString() ?? json['id']?.toString() ?? '',
      text: (json['text'] ?? json['question'] ?? json['option'] ?? '').toString(),
      image: (json['image'] ?? json['imageUrl'])?.toString(),
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      percentage: ((json['percentage'] as num?) ?? 0).toDouble(),
      voters:
          (json['voters'] as List<dynamic>?)
              ?.map((v) => Voter.fromJson(v is Map<String, dynamic> ? v : {}))
              .toList() ??
          [],
    );
  }

  PollOption copyWith({
    String? id,
    String? text,
    String? image,
    int? voteCount,
    double? percentage,
    List<Voter>? voters,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      image: image ?? this.image,
      voteCount: voteCount ?? this.voteCount,
      percentage: percentage ?? this.percentage,
      voters: voters ?? this.voters,
    );
  }
}

// -------------------------------------------------
// VOTER MODEL
// -------------------------------------------------
class Voter {
  final String userId;
  final String name;
  final String avatar;

  Voter({required this.userId, required this.name, required this.avatar});

  factory Voter.fromJson(Map<String, dynamic> json) => Voter(
    userId: json['userId'] ?? '',
    name: json['name'] ?? '',
    avatar: json['avatar'] ?? '',
  );
}

// -------------------------------------------------
// CREATED USER MODEL
// -------------------------------------------------
class CreatedUser {
  final String id;
  final String name;
  final String avatar;

  CreatedUser({required this.id, required this.name, required this.avatar});

  factory CreatedUser.fromJson(Map<String, dynamic> json) {
    return CreatedUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}

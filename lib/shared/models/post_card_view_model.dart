import 'package:loci/core/enums/question_type.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/features/community/data/models/announcement_author_display.dart';
import 'package:loci/features/community/data/models/announcement_model.dart';
import 'package:loci/features/home/data/models/question_model.dart';

// ── Standalone plain-data types ───────────────────────────────────────────────

class PostVoter {
  final String userId;
  final String name;
  final String avatar;

  const PostVoter({
    required this.userId,
    required this.name,
    required this.avatar,
  });
}

class PostPollOption {
  final String id;
  final String text;
  final String? image;
  final int voteCount;
  final double percentage;
  final List<PostVoter> voters;

  const PostPollOption({
    required this.id,
    required this.text,
    this.image,
    required this.voteCount,
    required this.percentage,
    this.voters = const [],
  });
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class PostCardViewModel {
  final String postId;
  final String authorId;
  final String userName;
  final String userImage;
  final String date;
  final String category;
  final String text;
  final String likes;
  final String comments;
  final bool isLiked;
  final bool isPoll;
  final bool isModerator;
  final String? businessId;
  final int totalVotes;
  final List<PostPollOption>? pollOptions;

  const PostCardViewModel({
    required this.postId,
    this.authorId = '',
    required this.userName,
    required this.userImage,
    required this.date,
    required this.category,
    required this.text,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isPoll,
    this.isModerator = false,
    this.businessId,
    required this.totalVotes,
    this.pollOptions,
  });

  /// Avatar to show on the card. Prefer the live session avatar for "my" posts
  /// so a profile-pic change updates the feed without a pull-to-refresh.
  String resolvedUserImage({
    String? currentUserId,
    String? currentUserImage,
  }) {
    if (currentUserId != null &&
        currentUserId.isNotEmpty &&
        authorId == currentUserId &&
        currentUserImage != null &&
        currentUserImage.isNotEmpty) {
      return currentUserImage;
    }
    return userImage;
  }
  /// Options to show in the collapsed card preview (the full set lives behind
  /// "See all").
  ///
  /// The old preview simply took the first [max] options in author order, so a
  /// poll where the votes sat on option #3 would preview two empty 0% bars and
  /// hide the meaningful result behind "See all". Instead we lead with the
  /// highest-voted options, and always keep the current user's own choice
  /// visible even when it isn't winning.
  List<PostPollOption> previewOptions({int max = 2, String? currentUserId}) {
    final options = pollOptions;
    if (options == null || options.isEmpty) return const [];
    if (options.length <= max) return options;

    // No votes yet → ranking is meaningless, so preserve the author's order.
    if (totalVotes <= 0) return options.take(max).toList();

    // Highest votes first; original order breaks ties (a stable ordering).
    final ranked = options.asMap().entries.toList()
      ..sort((a, b) {
        final byVotes = b.value.voteCount.compareTo(a.value.voteCount);
        return byVotes != 0 ? byVotes : a.key.compareTo(b.key);
      });
    final preview = ranked.take(max).map((e) => e.value).toList();

    // Guarantee the user sees the option they voted for, even if it's trailing.
    if (currentUserId != null && currentUserId.isNotEmpty) {
      for (final option in options) {
        final votedByUser = option.voters.any((v) => v.userId == currentUserId);
        if (votedByUser && !preview.any((p) => p.id == option.id)) {
          preview[preview.length - 1] = option;
          break;
        }
      }
    }
    return preview;
  }

  factory PostCardViewModel.from(
    AnnouncementModel ann, {
    String? communityOwnerUserId,
  }) {
    final author = AnnouncementAuthorDisplay.from(
      ann,
      communityOwnerUserId: communityOwnerUserId,
    );
    return PostCardViewModel(
      postId: ann.id,
      authorId: author.authorUserId,
      userName: author.displayName,
      userImage: author.avatarUrl,
      date: formatDateTime(ann.createdAt),
      category: ann.pollCategory ?? '',
      text: ann.feedBodyText,
      likes: (ann.likeCount ?? 0).toString(),
      comments: (ann.commentCount ?? 0).toString(),
      isLiked: ann.isLiked,
      isPoll: ann.isPollPost,
      isModerator: author.isModerator,
      businessId: author.businessId,
      totalVotes: ann.totalVotes ?? 0,
      pollOptions: ann.pollOptions
          ?.map(
            (o) => PostPollOption(
              id: o.id,
              text: o.text,
              image: o.image,
              voteCount: o.voteCount,
              percentage: o.percentage,
              voters: o.voters
                  .map(
                    (v) => PostVoter(
                      userId: v.userId,
                      name: v.name,
                      avatar: v.avatar,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  factory PostCardViewModel.fromQuestion(QuestionModel q) {
    return PostCardViewModel(
      postId: q.id,
      authorId: q.author.id,
      userName: q.author.name,
      userImage: q.author.avatar,
      date: formatDateTime(q.createdAt),
      category: q.category,
      text: q.content,
      likes: q.likeCount.toString(),
      comments: q.commentCount.toString(),
      isPoll: q.type == QuestionType.poll,
      isLiked: q.isLiked,
      totalVotes: q.totalVotes,
      pollOptions: q.options.isEmpty
          ? null
          : q.options
                .map(
                  (o) => PostPollOption(
                    id: o.optionId,
                    text: o.text,
                    image: o.image,
                    voteCount: o.voteCount,
                    percentage: o.percentage.toDouble(),
                    voters: o.voters
                        .map(
                          (v) => PostVoter(
                            userId: v.userId,
                            name: v.name,
                            avatar: v.avatar,
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
    );
  }
}

import 'package:loci/core/enums/question_type.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/data/models/community/announcement_model.dart';
import 'package:loci/data/models/home/question_model.dart';

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
  final String userName;
  final String userImage;
  final String date;
  final String category;
  final String text;
  final String likes;
  final String comments;
  final bool isLiked;
  final bool isPoll;
  final int totalVotes;
  final List<PostPollOption>? pollOptions;

  const PostCardViewModel({
    required this.postId,
    required this.userName,
    required this.userImage,
    required this.date,
    required this.category,
    required this.text,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isPoll,
    required this.totalVotes,
    this.pollOptions,
  });

  factory PostCardViewModel.from(AnnouncementModel ann) {
    return PostCardViewModel(
      postId: ann.id,
      userName: ann.business?.name ?? ann.createdBy?.name ?? '',
      userImage: ann.business?.logo ?? ann.createdBy?.avatar ?? '',
      date: formatDateTime(ann.createdAt),
      category: ann.pollCategory ?? '',
      text: ann.pollQuestion ?? ann.details,
      likes: (ann.likeCount ?? 0).toString(),
      comments: (ann.commentCount ?? 0).toString(),
      isLiked: ann.isLiked,
      isPoll: ann.qType == QuestionType.poll,
      totalVotes: ann.totalVotes ?? 0,
      pollOptions: ann.pollOptions
          ?.map((o) => PostPollOption(
                id: o.id,
                text: o.text,
                image: o.image,
                voteCount: o.voteCount,
                percentage: o.percentage,
                voters: o.voters
                    .map((v) => PostVoter(
                          userId: v.userId,
                          name: v.name,
                          avatar: v.avatar,
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }

  factory PostCardViewModel.fromQuestion(QuestionModel q) {
    return PostCardViewModel(
      postId: q.id,
      userName: q.author.name,
      userImage: q.author.avatar,
      date: formatDateTime(q.createdAt),
      category: q.category,
      text: q.content,
      likes: q.likeCount.toString(),
      comments: q.answers.length.toString(),
      isPoll: q.type == QuestionType.poll,
      isLiked: q.isLiked,
      totalVotes: q.totalVotes,
      pollOptions: q.options.isEmpty
          ? null
          : q.options
          .map((o) => PostPollOption(
        id: o.optionId,
        text: o.text,
        image: o.image,
        voteCount: o.voteCount,
        percentage: o.percentage.toDouble(),
        voters: o.voters
            .map((v) => PostVoter(
          userId: v.userId,
          name: v.name,
          avatar: v.avatar,
        ))
            .toList(),
      ))
          .toList(),
    );
  }
}

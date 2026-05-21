import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/data/models/community/announcement_model.dart';

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
  final int totalVotes;
  final List<PollOption>? pollOptions;

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
    required this.totalVotes,
    this.pollOptions,
  });

  factory PostCardViewModel.from(AnnouncementModel ann) {
    return PostCardViewModel(
      postId: ann.id,
      userName: ann.business?.name ?? ann.createdBy?.name ?? '',
      userImage: ann.business?.logo ?? ann.createdBy?.avatar ?? '',
      date: formatDateTime(ann.createdAt),
      category: ann.pollCategory ?? "",
      text: ann.pollQuestion ?? ann.details,
      likes: (ann.likeCount ?? 0).toString(),
      comments: (ann.commentCount ?? 0).toString(),
      isLiked: ann.isLiked,
      totalVotes: ann.totalVotes ?? 0,
      pollOptions: ann.pollOptions,
    );
  }
}

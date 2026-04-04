import 'package:loci/data/models/poll.dart';
import 'package:loci/data/models/post_model.dart';

import '../../../gen/assets.gen.dart';

import '../../../presentation/widgets/common/post_comment_section.dart';

/// Polls
final List<PollOption> mockPolls = [
  PollOption(
    title: "Pizzaburg",
    percent: 0.8,
    imagePath: Assets.images.user2.path,
    trailingText: "80%",
      voteCount: 400

  ),
  PollOption(
    title: "Chillox",
    percent: 0.4,
    imagePath: Assets.images.user1.path,
    trailingText: "40%",
      voteCount: 200
  ),
  PollOption(
    title: "aaaa",
    percent: 0.4,
    imagePath: Assets.images.user1.path,
    trailingText: "40%",
      voteCount: 44
  ),
];

/// Comments
final List<CommentData> mockComments = List.generate(
  12,
      (index) => CommentData(
    userName: "Alexandra Broke",
    commentText: "This was one of the most epic experiences I got involved in!",
    userImage: Assets.images.user2.path,
    likes: "200",
    replies: "2",
  ),
);



final List<PostModel> mockPosts = [
  PostModel(
    id: "post0",
    userName: "Azaan Mahmud",
    userImage: Assets.images.user1.path,
    date: "12-01-26",
    category: "Food",
    text: "Any food that you liked recently? " * 3,
    likes: "200",
    commentsCount: "45",
  ),
  PostModel(
    id: "post1",
    userName: "Sadia Rahman",
    userImage: Assets.images.user3.path,
    date: "12-02-26",
    category: "Drinks",
    text: "I tried a new smoothie today! So good.",
    likes: "150",
    commentsCount: "20",
  ),
];
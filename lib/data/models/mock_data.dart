import 'package:loci/data/models/community/announcement_model.dart';
import 'package:loci/data/models/post_model.dart';

import '../../../gen/assets.gen.dart';

/// Polls
final List<PollOption> mockPolls = [
  PollOption(
    id: '1',
    text: "Pizzaburg",
    image: Assets.images.user2.path,
    voteCount: 400,
  ),
  PollOption(
    id: '2',
    text: "Chillox",
    image: Assets.images.user1.path,
    voteCount: 200,
  ),
  PollOption(
    id: '3',
    text: "aaaa",
    image: Assets.images.user1.path,
    voteCount: 44,
  ),
];

/// Comments
// final List<CommentData> mockComments = List.generate(
//   12,
//       (index) => CommentData(
//     userName: "Alexandra Broke",
//     commentText: "This was one of the most epic experiences I got involved in!",
//     userImage: Assets.images.user2.path,
//     likes: 200,
//     replies: 20,
//   ),
// );



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
    text: "I tried raffles new smoothie today! So good.",
    likes: "150",
    commentsCount: "20",
  ),
];
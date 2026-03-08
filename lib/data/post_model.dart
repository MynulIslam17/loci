import 'package:loci/data/poll.dart';

class PostModel {
  final String id;
  final String userName;
  final String userImage;
  final String date;
  final String category;
  final String text;
  final String likes;
  final String commentsCount;


  PostModel({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.date,
    required this.category,
    required this.text,
    required this.likes,
    required this.commentsCount,

  });
}
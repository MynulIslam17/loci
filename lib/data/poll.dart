 //--- this filed include mode class for poll and comment

class PollOption {
  final String title;
  final double percent;
  final String imagePath;
  final String trailingText;
   int  voteCount;

  PollOption({required this.title, required this.percent, required this.imagePath, required this.trailingText,required this.voteCount});
}

class CommentData {
  final String userName;
  final String commentText;
  final String userImage;
  final String likes;
  final String replies;

  CommentData({required this.userName, required this.commentText, required this.userImage, required this.likes, required this.replies});
}
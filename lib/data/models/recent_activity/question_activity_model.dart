class QuestionActivityModel {
  final String name;
  final String category;
  final String avatar;
  final DateTime date;
  final String time;
  final String question;
  final int likes;
  final int comments;

  QuestionActivityModel({
    required this.name,
    required this.category,
    required this.date,
    required this.avatar,
    required this.time,
    required this.question,
    required this.likes,
    required this.comments,
  });

  factory QuestionActivityModel.fromJson(Map<String, dynamic> json) {
    return QuestionActivityModel(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      avatar: json['avatar'] ?? '',
      question: json['question'] ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
    );
  }
}
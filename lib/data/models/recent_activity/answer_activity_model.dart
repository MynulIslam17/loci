class AnsweredActivityModel {
  final String question;
  final String answer;
  final String time;
  final String questionAuthorAvatar;

  AnsweredActivityModel({
    required this.question,
    required this.answer,
    required this.time,
    required this.questionAuthorAvatar,
  });

  factory AnsweredActivityModel.fromJson(Map<String, dynamic> json) {
    return AnsweredActivityModel(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      time: json['time'] ?? '',
      questionAuthorAvatar: json['questionAuthorAvatar'],
    );
  }
}
class AnsweredActivityModel {
  final String question;
  final String answer;
  final String time;

  AnsweredActivityModel({
    required this.question,
    required this.answer,
    required this.time,
  });

  factory AnsweredActivityModel.fromJson(Map<String, dynamic> json) {
    return AnsweredActivityModel(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
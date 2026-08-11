enum QuestionType {
  question,
  poll;

  /// FROM API → APP
  static QuestionType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'question':
        return QuestionType.question;
      case 'poll':
        return QuestionType.poll;
      default:
        return QuestionType.question;
    }
  }

  /// UI LABEL
  String get label {
    switch (this) {
      case QuestionType.question:
        return 'Question';
      case QuestionType.poll:
        return 'Poll';
    }
  }

  /// TO API (APP → SERVER)
  String get toJson {
    switch (this) {
      case QuestionType.question:
        return 'question';
      case QuestionType.poll:
        return 'poll';
    }
  }
}
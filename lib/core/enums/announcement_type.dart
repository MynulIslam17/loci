enum AnnouncementType {
  question,
  offer,
  notice,
  activity;

  /// FROM API → APP
  static AnnouncementType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'question':
        return AnnouncementType.question;
      case 'offer':
        return AnnouncementType.offer;
      case 'notice':
        return AnnouncementType.notice;
      case 'activity':
        return AnnouncementType.activity;
      default:
        return AnnouncementType.activity;
    }
  }

  /// UI LABEL
  String get label {
    switch (this) {
      case AnnouncementType.question:
        return 'Question';
      case AnnouncementType.offer:
        return 'Offer';
      case AnnouncementType.notice:
        return 'Notice';
      case AnnouncementType.activity:
        return 'Activity';
    }
  }

  /// TO API (APP → SERVER)
  String get toJson {
    switch (this) {
      case AnnouncementType.question:
        return 'question';
      case AnnouncementType.offer:
        return 'offer';
      case AnnouncementType.notice:
        return 'notice';
      case AnnouncementType.activity:
        return 'activity';
    }
  }
}
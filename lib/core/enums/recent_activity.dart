enum RecentActivityType {
  questions,
  answered,
  reviews,
  business;

  /// FROM STRING (API → APP)
  static RecentActivityType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'questions':
        return RecentActivityType.questions;
      case 'answered':
        return RecentActivityType.answered;
      case 'reviews':
        return RecentActivityType.reviews;
      case 'business':
      case 'businesses':
        return RecentActivityType.business;
      default:
        return RecentActivityType.questions;
    }
  }

  /// UI LABEL
  String get label {
    switch (this) {
      case RecentActivityType.questions:
        return 'Questions';
      case RecentActivityType.answered:
        return 'Answered';
      case RecentActivityType.reviews:
        return 'Reviews';
      case RecentActivityType.business:
        return 'Business';
    }
  }

  /// TO API
  String get toJson {
    switch (this) {
      case RecentActivityType.questions:
        return 'questions';
      case RecentActivityType.answered:
        return 'answered';
      case RecentActivityType.reviews:
        return 'reviews';
      case RecentActivityType.business:
        return 'business';
    }
  }
}
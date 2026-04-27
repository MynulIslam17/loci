// recent_activity_type.dart

enum RecentActivityType {
  questions,
  answered,
  reviews,
  businesses;

  static RecentActivityType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'questions':
        return RecentActivityType.questions;
      case 'answered':
        return RecentActivityType.answered;
      case 'reviews':
        return RecentActivityType.reviews;
      case 'businesses':
        return RecentActivityType.businesses;
      default:
        return RecentActivityType.questions;
    }
  }

  String get label {
    switch (this) {
      case RecentActivityType.questions:
        return 'Questions';
      case RecentActivityType.answered:
        return 'Answered';
      case RecentActivityType.reviews:
        return 'Reviews';
      case RecentActivityType.businesses:
        return 'Businesses';
    }
  }

  String get toJson {
    switch (this) {
      case RecentActivityType.questions:
        return 'questions';
      case RecentActivityType.answered:
        return 'answered';
      case RecentActivityType.reviews:
        return 'reviews';
      case RecentActivityType.businesses:
        return 'businesses';
    }
  }
}
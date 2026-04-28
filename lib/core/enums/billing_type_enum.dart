enum BillingType {
  monthly,
  oneTime;

  /// FROM STRING (API → APP)
  static BillingType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'monthly':
        return BillingType.monthly;
      case 'one_time':
        return BillingType.oneTime;
      default:
        return BillingType.monthly;
    }
  }

  /// UI LABEL
  String get label {
    switch (this) {
      case BillingType.monthly:
        return 'Monthly';
      case BillingType.oneTime:
        return 'One Time';
    }
  }

  /// TO API
  String get toJson {
    switch (this) {
      case BillingType.monthly:
        return 'monthly';
      case BillingType.oneTime:
        return 'one_time';
    }
  }
}
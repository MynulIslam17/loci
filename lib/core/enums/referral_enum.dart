enum ReferralStatus {
  sent,
  pending,
  confirmed,
  rejected;

  /// FROM STRING (API → APP)
  static ReferralStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'sent':
        return ReferralStatus.sent;
      case 'pending':
        return ReferralStatus.pending;
      case 'confirmed':
        return ReferralStatus.confirmed;
      case 'rejected':
        return ReferralStatus.rejected;
      default:
        return ReferralStatus.pending;
    }
  }

  /// UI LABEL
  String get label {
    switch (this) {
      case ReferralStatus.sent:
        return 'Sent';
      case ReferralStatus.pending:
        return 'Pending';
      case ReferralStatus.confirmed:
        return 'Confirmed';
      case ReferralStatus.rejected:
        return 'Rejected';
    }
  }

  /// TO API
  String get toJson {
    switch (this) {
      case ReferralStatus.sent:
        return 'sent';
      case ReferralStatus.pending:
        return 'pending';
      case ReferralStatus.confirmed:
        return 'confirmed';
      case ReferralStatus.rejected:
        return 'rejected';
    }
  }
}
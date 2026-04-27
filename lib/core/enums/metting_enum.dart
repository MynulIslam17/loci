enum MeetingStatus {
  pending,
  confirmed,
  rejected;

  /// FROM STRING (API → APP)
  static MeetingStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return MeetingStatus.pending;
      case 'confirmed':
        return MeetingStatus.confirmed;
      case 'rejected':
        return MeetingStatus.rejected;
      default:
        return MeetingStatus.pending;
    }
  }

  /// UI LABEL
  String get label {
    switch (this) {
      case MeetingStatus.pending:
        return 'Pending';
      case MeetingStatus.confirmed:
        return 'Confirmed';
      case MeetingStatus.rejected:
        return 'Rejected';
    }
  }

  /// TO API
  String get toJson {
    switch (this) {
      case MeetingStatus.pending:
        return 'pending';
      case MeetingStatus.confirmed:
        return 'confirmed';
      case MeetingStatus.rejected:
        return 'rejected';
    }
  }
}
enum CheckInStatus {

  notCheckedIn,
  checkedIn;

  // String to enum
  static CheckInStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'not_checked_in':
        return CheckInStatus.notCheckedIn;
      case 'checked_in':
        return CheckInStatus.checkedIn;
      default:
        return CheckInStatus.notCheckedIn;
    }
  }


  //Label for UI

  String get label {
    switch (this) {
      case CheckInStatus.notCheckedIn: return 'Check In';
      case CheckInStatus.checkedIn: return 'Checked In';
    }
  }


  //  To sending api
  String get toJson {
    switch (this) {
      case CheckInStatus.notCheckedIn:
        return 'not_checked_in';
      case CheckInStatus.checkedIn:
        return 'checked_in';
    }
  }



}
enum RsvpStatus {
  going,
  notResponded;

  // String to enum
  static RsvpStatus fromString(String? value) {
    switch (value) {
      case 'going':         return RsvpStatus.going;
       case 'not_responded':
      default:              return RsvpStatus.notResponded;
    }
  }

  // Label for UI
  String get label {
    switch (this) {
      case RsvpStatus.going:        return 'Going';
      case RsvpStatus.notResponded: return 'RSVP';
    }
  }

  //  to sending api
  String get toJson {
    switch (this) {
      case RsvpStatus.going:        return 'going';
      case RsvpStatus.notResponded: return 'not_responded';
    }
  }



}
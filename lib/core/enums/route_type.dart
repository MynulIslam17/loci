enum RouteType {
  reservation,
  walkIn,
  reservationAndWalkIn,
  privateBooking;

  /// UI text (show in dropdown)
  String get label {
    switch (this) {
      case RouteType.reservation:
        return 'Reservation';
      case RouteType.walkIn:
        return 'Walk-in';
      case RouteType.reservationAndWalkIn:
        return 'Reservation + Walk-in';
      case RouteType.privateBooking:
        return 'Private Booking';
    }
  }

  /// API value (send to backend)
  String get apiValue {
    switch (this) {
      case RouteType.reservation:
        return 'reservation';
      case RouteType.walkIn:
        return 'walk_in';
      case RouteType.reservationAndWalkIn:
        return 'reservation_and_walk_in';
      case RouteType.privateBooking:
        return 'private_booking';
    }
  }


  static RouteType fromString(String? value) {
    switch (value) {
      case 'reservation': return RouteType.reservation;
      case 'walk_in': return RouteType.walkIn;
      case 'reservation_and_walk_in': return RouteType.reservationAndWalkIn;
      case 'private_booking': return RouteType.privateBooking;
      default: return RouteType.walkIn;
    }
  }

}
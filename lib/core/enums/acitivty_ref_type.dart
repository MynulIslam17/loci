enum ActivityRefType {
  event,
  route,
  raffle,
  unknown;

  static ActivityRefType fromString(String? value) {
    final slug = value?.toLowerCase().trim() ?? '';
    switch (slug) {
      case 'event':
        return ActivityRefType.event;
      case 'route':
      case 'routes':
        return ActivityRefType.route;
      case 'raffle':
      case 'raffles':
        return ActivityRefType.raffle;
      default:
        return ActivityRefType.unknown;
    }
  }
}
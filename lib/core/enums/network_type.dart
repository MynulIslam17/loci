enum NetworkType {
  checkins,
  connections,
  meetings,
  referrals, 
  unknown,
}

NetworkType networkTypeFromString(String? type) {
  switch (type) {
    case 'checkins':
      return NetworkType.checkins;
    case 'connections':
      return NetworkType.connections;
    case 'meetings':
      return NetworkType.meetings;
    case 'referrals':
      return NetworkType.referrals;
    default:
      return NetworkType.unknown;
  }
}
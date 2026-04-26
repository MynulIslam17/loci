enum NetworkType { checkins, connections, unknown }

NetworkType networkTypeFromString(String? type) {
  switch (type) {
    case 'checkins':
      return NetworkType.checkins;
    case 'connections':
      return NetworkType.connections;
    default:
      return NetworkType.unknown;
  }
}
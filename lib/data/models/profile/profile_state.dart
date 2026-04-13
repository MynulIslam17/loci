// data/models/profile/profile_stats.dart
class ProfileStats {
  final int eventsCheckedIn;
  final int routesCheckedIn;
  final int rafflesWon;

  ProfileStats({
    required this.eventsCheckedIn,
    required this.routesCheckedIn,
    required this.rafflesWon,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      eventsCheckedIn: json['eventsCheckedIn'] ?? 0,
      routesCheckedIn: json['routesCheckedIn'] ?? 0,
      rafflesWon:      json['rafflesWon']      ?? 0,
    );
  }
}
class DashboardCounts {
  final int connections;
  final int upcomingMeetings;
  final int referralsSent;
  final int totalCheckIns;

  DashboardCounts({
    required this.connections,
    required this.upcomingMeetings,
    required this.referralsSent,
    required this.totalCheckIns,
  });

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      connections: json['connections'] ?? 0,
      upcomingMeetings: json['upcomingMeetings'] ?? 0,
      referralsSent: json['referralsSent'] ?? 0,
      totalCheckIns: json['totalCheckIns'] ?? 0,
    );
  }
}
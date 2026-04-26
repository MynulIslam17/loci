
import 'dashboard_activity.dart';
import 'dashboard_count.dart';

class DashboardData {
  final DashboardCounts counts;
  final DashboardActivity activity;

  DashboardData({
    required this.counts,
    required this.activity,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      counts: DashboardCounts.fromJson(json['counts'] ?? {}),
      activity: DashboardActivity.fromJson(json['activity'] ?? {}),
    );
  }
}
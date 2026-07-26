class ActivityModel {
  final String id;
  final String title;

  ActivityModel({required this.id, required this.title});

  // Response items are activity-type announcements.
  // activityId is the referenced event/route/raffle id.
  // Title lives in the nested event/route/raffle object.
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final refType = (json['activityRefType'] as String? ?? '').toLowerCase();
    final nested = json[refType] as Map<String, dynamic>?;
    return ActivityModel(
      id: json['activityId'] as String? ?? '',
      title: nested?['title'] as String? ?? '',
    );
  }
}

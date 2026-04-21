import 'package:loci/data/models/raffles/raffles_model.dart';

class RaffleDetailsModel {
  final RaffleModel raffleModel;
  final List<RaffleTaskModel> tasks;
  final bool isPublic;
  final String status;
  final SponsorModel sponsor;
  final int totalTasks;
  final String userRole;
  final bool isParticipating;
  final int participantCount;

  RaffleDetailsModel({
    required this.raffleModel,
    required this.tasks,
    required this.isPublic,
    required this.status,
    required this.sponsor,
    required this.totalTasks,
    required this.userRole,
    required this.isParticipating,
    required this.participantCount,
  });

  factory RaffleDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return RaffleDetailsModel(
      raffleModel: RaffleModel.fromJson(data),
      tasks: (data['tasks'] as List<dynamic>? ?? [])
          .map((e) => RaffleTaskModel.fromJson(e))
          .toList(),
      isPublic: data['isPublic'] ?? false,
      status: data['status'] ?? '',
      sponsor: SponsorModel.fromJson(data['sponsor'] ?? {}),
      totalTasks: data['totalTasks'] ?? 0,
      userRole: data['userRole'] ?? '',
      isParticipating: data['isParticipating'] ?? false,
      participantCount: data['participantCount'] ?? 0,
    );
  }

  RaffleDetailsModel copyWith({
    RaffleModel? raffleModel,
    List<RaffleTaskModel>? tasks,
    bool? isPublic,
    String? status,
    SponsorModel? sponsor,
    int? totalTasks,
    String? userRole,
    bool? isParticipating,
    int? participantCount,
  }) {
    return RaffleDetailsModel(
      raffleModel: raffleModel ?? this.raffleModel,
      tasks: tasks ?? this.tasks,
      isPublic: isPublic ?? this.isPublic,
      status: status ?? this.status,
      sponsor: sponsor ?? this.sponsor,
      totalTasks: totalTasks ?? this.totalTasks,
      userRole: userRole ?? this.userRole,
      isParticipating: isParticipating ?? this.isParticipating,
      participantCount: participantCount ?? this.participantCount,
    );
  }
}

// ─── Nested activity model used inside tasks ───────────────────────────────

class TaskActivityModel {
  final String id;
  final String banner;
  final String title;
  final String details;

  TaskActivityModel({
    required this.id,
    required this.banner,
    required this.title,
    required this.details,
  });

  factory TaskActivityModel.fromJson(Map<String, dynamic> json) {
    return TaskActivityModel(
      id: json['_id'] ?? '',
      banner: json['banner'] ?? '',
      title: json['title'] ?? '',
      details: json['details'] ?? '',
    );
  }

  TaskActivityModel copyWith({
    String? id,
    String? banner,
    String? title,
    String? details,
  }) {
    return TaskActivityModel(
      id: id ?? this.id,
      banner: banner ?? this.banner,
      title: title ?? this.title,
      details: details ?? this.details,
    );
  }
}

// ───  RaffleTaskModel ──────────────────────────────────────────────────

class RaffleTaskModel {
  final TaskActivityModel? routeActivity;
  final TaskActivityModel? eventActivity;
  final int order;
  final bool isCompleted;

  RaffleTaskModel({
    this.routeActivity,
    this.eventActivity,
    required this.order,
    required this.isCompleted,
  });

  factory RaffleTaskModel.fromJson(Map<String, dynamic> json) {
    return RaffleTaskModel(
      routeActivity: json['routeActivity'] != null
          ? TaskActivityModel.fromJson(json['routeActivity'])
          : null,
      eventActivity: json['eventActivity'] != null
          ? TaskActivityModel.fromJson(json['eventActivity'])
          : null,
      order: json['order'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  /// Helper — returns whichever activity is present
  TaskActivityModel? get activity => routeActivity ?? eventActivity;

  /// Whether this task is a route or event type
  bool get isRouteTask => routeActivity != null;
  bool get isEventTask => eventActivity != null;

  RaffleTaskModel copyWith({
    TaskActivityModel? routeActivity,
    TaskActivityModel? eventActivity,
    int? order,
    bool? isCompleted,
  }) {
    return RaffleTaskModel(
      routeActivity: routeActivity ?? this.routeActivity,
      eventActivity: eventActivity ?? this.eventActivity,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// ─── SponsorModel  ──────────────────────────────

class SponsorModel {
  final String id;
  final String name;
  final String logo;
  final String description;

  SponsorModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.description,
  });

  factory SponsorModel.fromJson(Map<String, dynamic> json) {
    return SponsorModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      description: json['description'] ?? '',
    );
  }

  SponsorModel copyWith({
    String? id,
    String? name,
    String? logo,
    String? description,
  }) {
    return SponsorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      description: description ?? this.description,
    );
  }
}
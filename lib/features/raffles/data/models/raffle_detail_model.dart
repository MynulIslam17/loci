import 'package:loci/features/raffles/data/models/raffle_list_model.dart';

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
  final String? voucherCode;

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
    this.voucherCode,
  });

  factory RaffleDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] : json;
    final myProgress = data['myProgress'] is Map ? data['myProgress'] : {};

    final isPart = data['isParticipating'] == true ||
        data['userRole'] == 'participant' ||
        (json['message']?.toString().toLowerCase().contains('joined') ?? false);

    return RaffleDetailsModel(
      raffleModel: RaffleModel.fromJson(data),
      tasks: (data['tasks'] as List<dynamic>? ?? [])
          .map((e) => RaffleTaskModel.fromJson(e))
          .toList(),
      isPublic: data['isPublic'] == true,
      status: data['status']?.toString() ?? '',
      sponsor: SponsorModel.fromJson(data['sponsor']),
      totalTasks: (data['totalTasks'] as num?)?.toInt() ??
          (data['tasks'] as List?)?.length ??
          0,
      userRole: data['userRole']?.toString() ?? '',
      isParticipating: isPart,
      participantCount: (data['participantCount'] as num?)?.toInt() ?? 0,
      voucherCode: data['voucherCode']?.toString() ??
          myProgress['voucherCode']?.toString(),
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
    String? voucherCode,
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
      voucherCode: voucherCode ?? this.voucherCode,
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

  factory TaskActivityModel.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return TaskActivityModel(
        id: rawJson?.toString() ?? '',
        banner: '',
        title: '',
        details: '',
      );
    }
    final json = Map<String, dynamic>.from(rawJson);
    return TaskActivityModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      banner: json['banner']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      details: json['details']?.toString() ??
          json['description']?.toString() ??
          '',
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

  factory RaffleTaskModel.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return RaffleTaskModel(order: 0, isCompleted: false);
    }
    final json = Map<String, dynamic>.from(rawJson);
    return RaffleTaskModel(
      routeActivity: _parseTaskActivity(json['routeActivity']),
      eventActivity: _parseTaskActivity(json['eventActivity']),
      order: (json['order'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] == true,
    );
  }

  static TaskActivityModel? _parseTaskActivity(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return TaskActivityModel(
        id: value,
        banner: '',
        title: '',
        details: '',
      );
    }
    if (value is Map) {
      return TaskActivityModel.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
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

  factory SponsorModel.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return SponsorModel(
        id: rawJson?.toString() ?? '',
        name: '',
        logo: '',
        description: '',
      );
    }
    final json = Map<String, dynamic>.from(rawJson);
    return SponsorModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
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

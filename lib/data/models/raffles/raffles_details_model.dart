import 'package:loci/data/models/raffles/raffles_model.dart';

class RaffleDetailsModel {
  final RaffleModel raffleModel;

  final List<RaffleTaskModel> tasks;
  final bool isPublic;
  final String status;

  final SponsorModel sponsor;

  final int totalTasks;



  RaffleDetailsModel({
    required this.raffleModel,
    required this.tasks,
    required this.isPublic,
    required this.status,
    required this.sponsor,
    required this.totalTasks,
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
    );
  }

  ///  COPY WITH
  RaffleDetailsModel copyWith({
    RaffleModel? raffleModel,
    List<RaffleTaskModel>? tasks,
    bool? isPublic,
    String? status,
    SponsorModel? sponsor,
    int? totalTasks,
  }) {
    return RaffleDetailsModel(
      raffleModel: raffleModel ?? this.raffleModel,
      tasks: tasks ?? this.tasks,
      isPublic: isPublic ?? this.isPublic,
      status: status ?? this.status,
      sponsor: sponsor ?? this.sponsor,
      totalTasks: totalTasks ?? this.totalTasks,
    );
  }
}

class RaffleTaskModel {
  final String? routeActivity;
  final String? eventActivity;
  final int order;

  RaffleTaskModel({
    this.routeActivity,
    this.eventActivity,
    required this.order,
  });

  factory RaffleTaskModel.fromJson(Map<String, dynamic> json) {
    return RaffleTaskModel(
      routeActivity: json['routeActivity'],
      eventActivity: json['eventActivity'],
      order: json['order'] ?? 0,
    );
  }

  ///  COPY WITH
  RaffleTaskModel copyWith({
    String? routeActivity,
    String? eventActivity,
    int? order,
  }) {
    return RaffleTaskModel(
      routeActivity: routeActivity ?? this.routeActivity,
      eventActivity: eventActivity ?? this.eventActivity,
      order: order ?? this.order,
    );
  }
}

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
      description: json["description"]
    );
  }

  ///  COPY WITH
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

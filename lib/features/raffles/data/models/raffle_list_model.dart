import 'package:loci/shared/models/pagination_model.dart';

class RaffleListResponseModel {
  final bool success;
  final String message;
  final List<RaffleModel> raffles;
  final PaginationMeta meta;

  RaffleListResponseModel({
    required this.success,
    required this.message,
    required this.raffles,
    required this.meta,
  });

  factory RaffleListResponseModel.fromJson(Map<String, dynamic> json) {
    return RaffleListResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      raffles: (json['data'] as List<dynamic>? ?? [])
          .map((e) => RaffleModel.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class RaffleModel {
  final String id;
  final String title;
  final String description;

  final String startDate;
  final String endDate;

  final int maxSupply;

  final String? rafflePrizeImage;
  final String bundleName;

  final String banner;

  final String organizerName;
  final String organizerLogo;

  final bool isParticipating;
  final int participantCount;
  final int completionPercentage;

  RaffleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.maxSupply,
    required this.rafflePrizeImage,
    required this.bundleName,
    required this.banner,
    required this.organizerName,
    required this.organizerLogo,
    this.isParticipating = false,
    this.participantCount = 0,
    this.completionPercentage = 0,
  });

  factory RaffleModel.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return RaffleModel(
        id: rawJson?.toString() ?? '',
        title: '',
        description: '',
        startDate: '',
        endDate: '',
        maxSupply: 0,
        rafflePrizeImage: null,
        bundleName: '',
        banner: '',
        organizerName: '',
        organizerLogo: '',
      );
    }
    final json = Map<String, dynamic>.from(rawJson);
    final sponsor = json['sponsor'];
    final myProgress = json['myProgress'] is Map ? json['myProgress'] : {};

    return RaffleModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? '',
      description: json['details']?.toString() ??
          json['description']?.toString() ??
          '',

      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',

      maxSupply: (json['maxSupply'] as num?)?.toInt() ?? 0,

      rafflePrizeImage: json['rafflePrizeImage']?.toString(),
      bundleName: json['raffleBundleName']?.toString() ?? '',

      banner: json['banner']?.toString() ?? '',

      organizerName: sponsor is Map ? (sponsor['name']?.toString() ?? '') : '',
      organizerLogo: sponsor is Map ? (sponsor['logo']?.toString() ?? '') : '',

      isParticipating: json['isParticipating'] == true ||
          json['userRole'] == 'participant',
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      completionPercentage:
          (myProgress['completionPercentage'] as num?)?.toInt() ?? 0,
    );
  }

  // ----for update model
  RaffleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? startDate,
    String? endDate,
    int? maxSupply,
    String? rafflePrizeImage,
    String? bundleName,
    String? banner,
    String? organizerName,
    String? organizerLogo,
    bool? isParticipating,
    int? participantCount,
    int? completionPercentage,
  }) {
    return RaffleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxSupply: maxSupply ?? this.maxSupply,
      rafflePrizeImage: rafflePrizeImage ?? this.rafflePrizeImage,
      bundleName: bundleName ?? this.bundleName,
      banner: banner ?? this.banner,
      organizerName: organizerName ?? this.organizerName,
      organizerLogo: organizerLogo ?? this.organizerLogo,
      isParticipating: isParticipating ?? this.isParticipating,
      participantCount: participantCount ?? this.participantCount,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}

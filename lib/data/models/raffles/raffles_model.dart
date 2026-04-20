

import '../common/paginatation_model.dart';



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

  final String rafflePrizeImage;
  final String bundleName;

  final String banner;

  final String organizerName;
  final String organizerLogo;


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

  });

  factory RaffleModel.fromJson(Map<String, dynamic> json) {
    final sponsor = json['sponsor'] ?? {};

    return RaffleModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['details'] ?? '',

      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',

      maxSupply: json['maxSupply'] ?? 0,

      rafflePrizeImage: json['rafflePrizeImage'] ?? '',
      bundleName: json['raffleBundleName'] ?? '',

      banner: json['banner'] ?? '',

      organizerName: sponsor['name'] ?? '',
      organizerLogo: sponsor['logo'] ?? '',

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
    String? prizeText,
    String? bundleName,
    String? banner,
    String? organizerName,
    String? organizerLogo,
  }) {
    return RaffleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxSupply: maxSupply ?? this.maxSupply,
      rafflePrizeImage: prizeText ?? this.rafflePrizeImage,
      bundleName: bundleName ?? this.bundleName,
      banner: banner ?? this.banner,
      organizerName: organizerName ?? this.organizerName,
      organizerLogo: organizerLogo ?? this.organizerLogo,
    );
  }


}
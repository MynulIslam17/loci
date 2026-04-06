
import 'package:loci/data/models/common/paginatation_model.dart';

class RouteResponseModel {
  final String message;
  final List<RouteModel> routes;
  final PaginationMeta meta;

  RouteResponseModel({
    required this.message,
    required this.routes,
    required this.meta,
  });

  factory RouteResponseModel.fromJson(Map<String, dynamic> json) {
    return RouteResponseModel(
      message: json['message'] ?? '',
      routes: (json['data'] as List<dynamic>?)
          ?.map((e) => RouteModel.fromJson(e))
          .toList() ?? [],
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}


class RouteModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String duration;
  final String difficulty;
  final String imageUrl;

  RouteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.duration,
    required this.difficulty,
    required this.imageUrl,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',

      // API dont have ii → fallback
      location: "Downtown District",

      duration: _formatDuration(json['duration']),
      difficulty: _capitalize(json['difficulty']),
      imageUrl: json['coverImage'] ?? '',
    );
  }

  // ---- Helpers ----
  static String _formatDuration(dynamic minutes) {
    if (minutes == null) return "0 h";
    double hour = (minutes / 60);
    return "${hour.toStringAsFixed(1)} h";
  }

  static String _capitalize(String? text) {
    if (text == null || text.isEmpty) return "";
    return text[0].toUpperCase() + text.substring(1);
  }
}






import 'package:loci/data/models/busniess/browse_business_model.dart';
import '../common/paginatation_model.dart';

class BrowseBusinessResponseModel {
  final bool success;
  final String message;
  final List<BrowseBusinessModel> data;
  final PaginationMeta meta;

  BrowseBusinessResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory BrowseBusinessResponseModel.fromJson(Map<String, dynamic> json) {
    return BrowseBusinessResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',

      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
          .map((e) => BrowseBusinessModel.fromJson(e))
          .toList()
          : [],

      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'])
          : PaginationMeta(
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      ),
    );
  }
}
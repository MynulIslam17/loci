import '../common/paginatation_model.dart';
import '../community/community_model.dart';


class CommunityResponseModel {
  final List<CommunityModel> joined;
  final List<CommunityModel> available;
  final PaginationMeta? meta;

  CommunityResponseModel({
    required this.joined,
    required this.available,
    this.meta,
  });

  factory CommunityResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    final joinedList = (data['joined'] as List? ?? [])
        .map((e) => CommunityModel.fromJson(e))
        .toList();

    final availableData = data['available'] ?? {};
    final availableList = (availableData['data'] as List? ?? [])
        .map((e) => CommunityModel.fromJson(e))
        .toList();

    final meta = availableData['meta'] != null
        ? PaginationMeta.fromJson(availableData['meta'])
        : null;

    return CommunityResponseModel(
      joined: joinedList,
      available: availableList,
      meta: meta,
    );
  }
}
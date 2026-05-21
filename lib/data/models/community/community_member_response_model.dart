import 'package:loci/data/models/common/paginatation_model.dart';
import 'package:loci/data/models/community/community_member_model.dart';

class CommunityMemberResponseModel {
  final List<CommunityMemberModel> data;
  final PaginationMeta meta;

  CommunityMemberResponseModel({
    required this.data,
    required this.meta,
  });

  factory CommunityMemberResponseModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberResponseModel(
      data: (json['data'] as List? ?? [])
          .map((e) => CommunityMemberModel.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

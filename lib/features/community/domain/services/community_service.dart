import 'dart:io';

import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/browse_business/data/models/browse_business_response_model.dart';
import 'package:loci/features/community/data/models/activity_search_response.dart';
import 'package:loci/features/community/data/models/announcement_model.dart';
import 'package:loci/features/community/data/models/announcement_response.dart';
import 'package:loci/features/community/data/models/comment_model.dart';
import 'package:loci/features/community/data/models/community_member_response_model.dart';
import 'package:loci/features/community/data/models/community_response_model.dart';
import 'package:loci/features/community/data/models/single_community_response.dart';
import 'package:loci/features/community/data/repositories/community_repository.dart';

/// Domain orchestration for community. Controllers call this — never NetworkCaller.
class CommunityService {
  final CommunityRepository _repository;

  CommunityService(this._repository);

  Future<CommunityResponseModel> getCommunities({
    required int page,
    required int limit,
  }) async {
    final body = await _repository.getCommunities(page: page, limit: limit);
    return CommunityResponseModel.fromJson(body);
  }

  Future<String> joinCommunity({required String qrCode}) async {
    final body = await _repository.joinCommunity(qrCode: qrCode);
    return body['message']?.toString() ?? 'Successfully joined community';
  }

  /// Fetches the freshly-signed QR token for a community (used to display a
  /// scannable "join" QR). Throws if the server returns no token.
  Future<String> getCommunityQr(String communityId) async {
    final body = await _repository.getCommunityQr(communityId);
    final data = body['data'];
    final qr = (data is Map<String, dynamic>) ? data['qrCode']?.toString() : null;
    if (qr == null || qr.isEmpty) {
      throw Exception('Community QR not available');
    }
    return qr;
  }

  Future<CommunityModel> getSingleCommunity(String communityId) async {
    final body = await _repository.getSingleCommunity(communityId);
    return SingleCommunityResponse.fromJson(body).data;
  }

  Future<AnnouncementResponse> getAnnouncements({
    required String communityId,
    required String type,
    required int page,
    required int limit,
    String? search,
  }) async {
    final body = await _repository.getAnnouncements(
      communityId: communityId,
      type: type,
      page: page,
      limit: limit,
      search: search,
    );
    return AnnouncementResponse.fromJson(body);
  }

  Future<void> toggleAnnouncementLike(String announcementId) {
    return _repository.toggleAnnouncementLike(announcementId);
  }

  Future<void> createAnnouncement({
    required Map<String, String> fields,
    File? image,
  }) async {
    await _repository.createAnnouncement(fields: fields, image: image);
  }

  Future<ActivitySearchResponse> searchActivities({
    required String communityId,
    required String type,
    String? search,
    required int page,
    required int limit,
  }) async {
    final body = await _repository.searchActivities(
      communityId: communityId,
      type: type,
      search: search,
      page: page,
      limit: limit,
    );
    return ActivitySearchResponse.fromJson(body);
  }

  Future<void> createPollQuestion({
    required String communityId,
    required String pollQuestion,
    required String pollCategory,
    required String qType,
    String? businessId,
  }) {
    return _repository.createPollQuestion(
      communityId: communityId,
      pollQuestion: pollQuestion,
      pollCategory: pollCategory,
      qType: qType,
      businessId: businessId,
    );
  }

  Future<AnnouncementModel> addPollOption({
    required String announcementId,
    required String text,
    String? imageUrl,
  }) async {
    final body = await _repository.addPollOption(
      announcementId: announcementId,
      text: text,
      imageUrl: imageUrl,
    );
    return AnnouncementModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<CommunityMemberResponseModel> getCommunityMembers({
    required String communityId,
    required int page,
    required int limit,
    String? searchTerm,
  }) async {
    final body = await _repository.getCommunityMembers(
      communityId: communityId,
      page: page,
      limit: limit,
      searchTerm: searchTerm,
    );
    return CommunityMemberResponseModel.fromJson(body);
  }

  /// Returns the backend's success message (e.g. "Community invitation sent").
  Future<String> addCommunityMember({
    required String communityId,
    required String email,
    String? note,
  }) async {
    final body = await _repository.addCommunityMember(
      communityId: communityId,
      email: email,
      note: note,
    );
    return body['message'] as String? ?? 'Invitation sent';
  }

  Future<String> exportCommunityMembers({required String communityId}) async {
    return _repository.exportCommunityMembers(communityId: communityId);
  }

  Future<void> removeMember({
    required String communityId,
    required String memberId,
  }) {
    return _repository.removeMember(
      communityId: communityId,
      memberId: memberId,
    );
  }

  Future<String> submitVote({
    required String announcementId,
    required String optionId,
  }) async {
    final body = await _repository.submitVote(
      announcementId: announcementId,
      optionId: optionId,
    );
    return body['message']?.toString() ?? 'Vote submitted successfully';
  }

  Future<BrowseBusinessResponseModel> searchBusinesses(String query, {int page = 1, int limit = 10}) async {
    final body = await _repository.searchBusinesses(query, page: page, limit: limit);
    return BrowseBusinessResponseModel.fromJson(body);
  }

  Future<CommentResponse> getAnnouncementComments({
    required String postId,
    required int page,
    required int limit,
  }) async {
    final body = await _repository.getAnnouncementComments(
      postId: postId,
      page: page,
      limit: limit,
    );
    return CommentResponse.fromJson(body);
  }

  Future<CommentModel> postAnnouncementComment({
    required String postId,
    required String content,
  }) async {
    final body = await _repository.postAnnouncementComment(
      postId: postId,
      content: content,
    );
    return CommentModel.fromJson(body['data'] as Map<String, dynamic>);
  }
}

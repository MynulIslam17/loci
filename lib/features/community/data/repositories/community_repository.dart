import 'dart:io';

import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Community data layer: remote HTTP via [NetworkCaller].
class CommunityRepository {
  final NetworkCaller _network;

  CommunityRepository(this._network);

  Future<Map<String, dynamic>> getCommunities({
    required int page,
    required int limit,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.community,
      queryParams: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load communities');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> joinCommunity({required String qrCode}) async {
    final res = await _network.postRequest(
      url: AppUrl.joinCommunity,
      body: {'qrCode': qrCode},
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to join community');
    }
    return res.body ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getCommunityQr(String communityId) async {
    final res = await _network.getRequest(
      url: AppUrl.communityQr(communityId),
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ??
            res.errorMessage ??
            'Failed to load community QR',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getSingleCommunity(String communityId) async {
    final res = await _network.getRequest(
      url: AppUrl.singleCommunity(communityId),
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load community',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getAnnouncements({
    required String communityId,
    required String type,
    required int page,
    required int limit,
    String? search,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.announcementList,
      queryParams: {
        'communityId': communityId,
        'type': type,
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ??
            res.errorMessage ??
            'Failed to load announcements',
      );
    }
    return res.body!;
  }

  Future<void> toggleAnnouncementLike(String announcementId) async {
    final res = await _network.postRequest(
      url: AppUrl.announcementLike(announcementId),
      body: {},
    );
    if (!res.isSuccess) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Something went wrong',
      );
    }
  }

  Future<Map<String, dynamic>> createAnnouncement({
    required Map<String, String> fields,
    File? image,
  }) async {
    if (image != null) {
      final res = await _network.multipartRequest(
        url: AppUrl.crateAnnouncement,
        method: 'POST',
        fields: fields,
        files: {'image': image},
      );
      if (!res.isSuccess) {
        throw Exception(res.errorMessage ?? 'Failed to create announcement');
      }
      return res.body ?? <String, dynamic>{};
    }

    final res = await _network.postRequest(
      url: AppUrl.crateAnnouncement,
      body: fields,
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to create announcement');
    }
    return res.body ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> searchActivities({
    required String communityId,
    required String type,
    String? search,
    required int page,
    required int limit,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.searchActivity,
      queryParams: {
        'communityId': communityId,
        'type': type,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'limit': limit,
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load activities',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> createPollQuestion({
    required String communityId,
    required String pollQuestion,
    required String pollCategory,
    required String qType,
    String? businessId,
  }) async {
    final body = <String, dynamic>{
      'type': 'question',
      'communityId': communityId,
      'pollQuestion': pollQuestion,
      'pollCategory': pollCategory,
      'qtype': qType,
      if (businessId != null && businessId.isNotEmpty) 'businessId': businessId,
    };
    final res = await _network.postRequest(
      url: AppUrl.crateAnnouncement,
      body: body,
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to create poll question');
    }
    return res.body ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> addPollOption({
    required String announcementId,
    required String text,
    String? imageUrl,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.addPollOption(announcementId),
      body: {
        'text': text,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to add poll option');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getCommunityMembers({
    required String communityId,
    required int page,
    required int limit,
    String? searchTerm,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.communityMember(communityId),
      queryParams: {
        'page': page,
        'limit': limit,
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load members',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> addCommunityMember({
    required String communityId,
    required String email,
    String? note,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.communityMember(communityId),
      body: {
        'email': email.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    if (!res.isSuccess) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to add member',
      );
    }
    return res.body ?? {};
  }

  Future<String> exportCommunityMembers({required String communityId}) async {
    return _network.getTextBody(url: AppUrl.exportCommunityMembers(communityId));
  }

  Future<void> removeMember({
    required String communityId,
    required String memberId,
  }) async {
    final res = await _network.deleteRequest(
      url: AppUrl.removeCommunityMember(communityId, memberId),
    );
    if (!res.isSuccess) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to remove member',
      );
    }
  }

  Future<Map<String, dynamic>> submitVote({
    required String announcementId,
    required String optionId,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.voteOnAnnouncementPoll(announcementId),
      body: {
        'optionIds': [optionId],
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to submit vote',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> searchBusinesses(String query, {int page = 1, int limit = 10}) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (query.trim().isNotEmpty) 'search': query.trim(),
    };
    final res = await _network.getRequest(
      url: AppUrl.browseBusinesses,
      queryParams: queryParams,
    );
    if (!res.isSuccess || res.body is! Map<String, dynamic>) {
      throw Exception(
        res.errorMessage ?? 'Could not search businesses. Please try again.',
      );
    }
    return res.body as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAnnouncementComments({
    required String postId,
    required int page,
    required int limit,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.announcementsComments(postId),
      queryParams: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load comments',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> postAnnouncementComment({
    required String postId,
    required String content,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.announcementsComments(postId),
      body: {'content': content},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to post comment',
      );
    }
    return res.body!;
  }
}

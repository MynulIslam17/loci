import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/community/data/models/announcement_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/announcement_type_cache.dart';
import 'package:loci/features/community/presentation/controllers/my_community_controller.dart';

class AnnouncementController extends GetxController {
  AnnouncementController(this._service);

  final CommunityService _service;

  final announcementMap = <String, AnnouncementModel>{}.obs;
  final votedOptionIds = <String, String>{}.obs;
  final currentType = AnnouncementType.question.obs;

  String? _communityId;
  int _feedLoadGeneration = 0;
  final communityOwnerUserId = RxnString();
  final _cacheByType = <AnnouncementType, AnnouncementTypeCache>{};
  final _tabRevision = <AnnouncementType, RxInt>{};
  final _searchDebounce = <AnnouncementType, Timer?>{};

  AnnouncementTypeCache _cacheFor(AnnouncementType type) {
    return _cacheByType.putIfAbsent(
      type,
      () => AnnouncementTypeCache(type),
    );
  }

  RxInt revisionFor(AnnouncementType type) {
    return _tabRevision.putIfAbsent(type, () => 0.obs);
  }

  void _bump(AnnouncementType type) {
    revisionFor(type).value++;
  }

  List<AnnouncementModel> announcementsFor(AnnouncementType type) {
    final cache = _cacheFor(type);
    return cache.ids
        .map((id) => announcementMap[id])
        .whereType<AnnouncementModel>()
        .toList();
  }

  bool isLoadingFor(AnnouncementType type) => _cacheFor(type).isLoading;

  bool isPaginationLoadingFor(AnnouncementType type) =>
      _cacheFor(type).isPaginationLoading;

  bool hasLoadedFor(AnnouncementType type) => _cacheFor(type).hasLoaded;

  String? errorFor(AnnouncementType type) => _cacheFor(type).errorMessage;

  bool hasMoreFor(AnnouncementType type) => _cacheFor(type).hasMore;

  String? get communityId => _communityId;

  String searchQueryFor(AnnouncementType type) => _cacheFor(type).searchQuery;

  void onSearchChanged(AnnouncementType type, String query) {
    _searchDebounce[type]?.cancel();
    _searchDebounce[type] = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      final cache = _cacheFor(type);
      if (cache.searchQuery == trimmed) return;
      cache.searchQuery = trimmed;
      fetchAnnouncements(type: type, isRefresh: true);
    });
  }

  void clearSearch(AnnouncementType type) {
    _searchDebounce[type]?.cancel();
    final cache = _cacheFor(type);
    if (cache.searchQuery.isEmpty) return;
    cache.searchQuery = '';
    fetchAnnouncements(type: type, isRefresh: true);
  }

  /// Backward-compatible helpers for active tab actions.
  bool get hasMore => hasMoreFor(currentType.value);

  List<AnnouncementModel> get announcements =>
      announcementsFor(currentType.value);

  Future<void> init(String communityId) async {
    final switching = _communityId != communityId;
    if (switching) {
      final hadPreviousCommunity = _communityId != null;
      if (hadPreviousCommunity) {
        _feedLoadGeneration++;
      }
      _communityId = communityId;
      communityOwnerUserId.value = null;
      _cacheByType.clear();
      _tabRevision.clear();
      announcementMap.clear();
      votedOptionIds.clear();
      currentType.value = AnnouncementType.question;
      final cache = _cacheFor(AnnouncementType.question);
      cache.isLoading = true;
      _bump(AnnouncementType.question);

      final generation =
          hadPreviousCommunity ? _feedLoadGeneration : null;
      await fetchAnnouncements(
        type: AnnouncementType.question,
        isRefresh: true,
        loadGeneration: generation,
      );
      return;
    }

    if (!hasLoadedFor(AnnouncementType.question)) {
      await fetchAnnouncements(
        type: AnnouncementType.question,
        isRefresh: true,
      );
    }
  }

  /// Business owner of this community (for author labels on announcements).
  void setCommunityOwnerUserId(String? userId) {
    if (communityOwnerUserId.value == userId) return;
    communityOwnerUserId.value = userId;
    for (final type in AnnouncementType.values) {
      _bump(type);
    }
  }

  void changeType(AnnouncementType type) {
    if (currentType.value == type) {
      ensureLoaded(type);
      return;
    }
    currentType.value = type;
    ensureLoaded(type);
  }

  /// Loads tab data the first time it is shown (or after cache clear).
  void ensureLoaded(AnnouncementType type) {
    if (_communityId == null || hasLoadedFor(type) || isLoadingFor(type)) {
      return;
    }
    final cache = _cacheFor(type);
    cache.isLoading = true;
    cache.errorMessage = null;
    _bump(type);
    fetchAnnouncements(type: type, isRefresh: true);
  }

  Future<void> fetchAnnouncements({
    required AnnouncementType type,
    bool isRefresh = false,
    int? loadGeneration,
  }) async {
    if (_communityId == null) return;

    final cache = _cacheFor(type);

    try {
      cache.isLoading = true;
      cache.errorMessage = null;

      if (isRefresh) {
        cache.currentPage = 1;
        cache.ids.clear();
      }

      _bump(type);

      final result = await _service.getAnnouncements(
        communityId: _communityId!,
        type: type.toJson,
        page: cache.currentPage,
        limit: 10,
        search: cache.searchQuery.isNotEmpty ? cache.searchQuery : null,
      );

      if (loadGeneration != null && loadGeneration != _feedLoadGeneration) {
        return;
      }

      _appendAnnouncements(result.data, cache);
      cache.meta = result.meta;
      cache.hasLoaded = true;
    } catch (e) {
      if (loadGeneration != null && loadGeneration != _feedLoadGeneration) {
        return;
      }
      cache.errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      cache.isLoading = false;
      if (loadGeneration == null || loadGeneration == _feedLoadGeneration) {
        _bump(type);
      }
    }
  }

  Future<void> fetchMoreAnnouncements({AnnouncementType? type}) async {
    final tab = type ?? currentType.value;
    final cache = _cacheFor(tab);

    if (!cache.hasMore ||
        cache.isPaginationLoading ||
        cache.isLoading ||
        _communityId == null) {
      return;
    }

    try {
      cache.isPaginationLoading = true;
      _bump(tab);
      cache.currentPage++;

      final result = await _service.getAnnouncements(
        communityId: _communityId!,
        type: tab.toJson,
        page: cache.currentPage,
        limit: 10,
        search: cache.searchQuery.isNotEmpty ? cache.searchQuery : null,
      );

      _appendAnnouncements(result.data, cache);
      cache.meta = result.meta;
    } catch (e) {
      cache.currentPage--;
      cache.errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      cache.isPaginationLoading = false;
      _bump(tab);
    }
  }

  Future<void> refreshAnnouncements([AnnouncementType? type]) async {
    await fetchAnnouncements(
      type: type ?? currentType.value,
      isRefresh: true,
    );
  }

  /// Pull-to-refresh: reload the active tab and community meta (members, QR, etc.).
  Future<void> refreshTabWithCommunityMeta(AnnouncementType type) async {
    final id = _communityId;
    MyCommunityController? myCommunity;
    if (Get.isRegistered<MyCommunityController>()) {
      myCommunity = Get.find<MyCommunityController>();
    }

    if (id == null || myCommunity == null) {
      await refreshAnnouncements(type);
      return;
    }

    await Future.wait([
      refreshAnnouncements(type),
      myCommunity.refreshCommunity(id),
    ]);

    final ownerId = myCommunity.community.value?.ownerUserId;
    if (ownerId != null && ownerId.isNotEmpty) {
      setCommunityOwnerUserId(ownerId);
    }
  }

  bool isLiked(String announcementId) =>
      announcementMap[announcementId]?.isLiked ?? false;

  String? votedOptionId(String announcementId) =>
      votedOptionIds[announcementId];

  void updatePollVote(
    String announcementId,
    String newOptionId, {
    required String userId,
    required String userName,
    required String userAvatar,
  }) {
    final post = announcementMap[announcementId];
    if (post == null) return;

    final previousOptionId = votedOptionIds[announcementId];
    final isChangingVote =
        previousOptionId != null && previousOptionId != newOptionId;
    final newVoter = Voter(userId: userId, name: userName, avatar: userAvatar);

    final newTotalVotes = isChangingVote
        ? (post.totalVotes ?? 0)
        : (post.totalVotes ?? 0) + 1;

    final updatedOptions = post.pollOptions?.map((opt) {
      int newVoteCount = opt.voteCount;
      List<Voter> newVoters = opt.voters;

      if (opt.id == newOptionId) {
        newVoteCount = opt.voteCount + 1;
        newVoters = [...opt.voters, newVoter];
      } else if (isChangingVote && opt.id == previousOptionId) {
        newVoteCount = (opt.voteCount - 1).clamp(0, opt.voteCount);
        newVoters = opt.voters.where((v) => v.userId != userId).toList();
      }

      final newPercentage = newTotalVotes > 0
          ? (newVoteCount / newTotalVotes) * 100
          : 0.0;

      return opt.copyWith(
        voteCount: newVoteCount,
        voters: newVoters,
        percentage: newPercentage,
      );
    }).toList();

    announcementMap[announcementId] = post.copyWith(
      pollOptions: updatedOptions,
      totalVotes: newTotalVotes,
    );
    votedOptionIds[announcementId] = newOptionId;
    announcementMap.refresh();
    _bumpAllTabsContaining(announcementId);
  }

  void toggleLikeLocally(String announcementId) {
    final post = announcementMap[announcementId];
    if (post == null) return;
    announcementMap[announcementId] = post.copyWith(
      isLiked: !post.isLiked,
      likeCount: post.isLiked
          ? ((post.likeCount ?? 1) - 1).clamp(0, post.likeCount ?? 0)
          : (post.likeCount ?? 0) + 1,
    );
    announcementMap.refresh();
    _bumpAllTabsContaining(announcementId);
  }

  void incrementCommentCount(String announcementId) {
    final post = announcementMap[announcementId];
    if (post == null) return;
    announcementMap[announcementId] = post.copyWith(
      commentCount: (post.commentCount ?? 0) + 1,
    );
    announcementMap.refresh();
    _bumpAllTabsContaining(announcementId);
  }

  void decrementCommentCount(String announcementId) {
    final post = announcementMap[announcementId];
    if (post == null) return;
    announcementMap[announcementId] = post.copyWith(
      commentCount: ((post.commentCount ?? 1) - 1)
          .clamp(0, double.maxFinite)
          .toInt(),
    );
    announcementMap.refresh();
    _bumpAllTabsContaining(announcementId);
  }

  void updatePollOption(String announcementId, PollOption option) {
    final post = announcementMap[announcementId];
    if (post == null) return;
    announcementMap[announcementId] = post.copyWith(
      pollOptions: [...(post.pollOptions ?? []), option],
    );
    announcementMap.refresh();
    _bumpAllTabsContaining(announcementId);
  }

  void updateEventRsvpStatus(String eventId, RsvpStatus status) {
    for (final cache in _cacheByType.values) {
      for (final id in cache.ids) {
        final post = announcementMap[id];
        if (post?.event?.id != eventId) continue;

        final updatedEvent = post!.event!.copyWith(
          myRsvpStatus: status,
          goingCount: status == RsvpStatus.going
              ? post.event!.goingCount + 1
              : post.event!.goingCount,
        );

        announcementMap[id] = post.copyWith(event: updatedEvent);
        announcementMap.refresh();
        _bump(cache.type);
        return;
      }
    }
  }

  void _appendAnnouncements(
    List<AnnouncementModel> items,
    AnnouncementTypeCache cache,
  ) {
    String? currentUserId;
    try {
      currentUserId = Get.find<AuthController>().userModel?.id;
    } catch (_) {}

    for (final item in items) {
      announcementMap[item.id] = item;
      if (!cache.ids.contains(item.id)) {
        cache.ids.add(item.id);
      }

      if (currentUserId != null && !votedOptionIds.containsKey(item.id)) {
        for (final opt in item.pollOptions ?? []) {
          if (opt.voters.any((v) => v.userId == currentUserId)) {
            votedOptionIds[item.id] = opt.id;
            break;
          }
        }
      }
    }
    announcementMap.refresh();
    _bump(cache.type);
  }

  void _bumpAllTabsContaining(String announcementId) {
    for (final entry in _cacheByType.entries) {
      if (entry.value.ids.contains(announcementId)) {
        _bump(entry.key);
      }
    }
  }
}

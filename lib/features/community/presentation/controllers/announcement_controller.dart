import 'package:get/get.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/community/data/models/announcement_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

class AnnouncementController extends GetxController {
  AnnouncementController(this._service);

  final CommunityService _service;

  // -------------------------------------------------
  // NORMALIZED STATE
  // -------------------------------------------------
  final announcementMap = <String, AnnouncementModel>{}.obs;
  final announcementIds = <String>[].obs;
  final votedOptionIds = <String, String>{}.obs;

  // -------------------------------------------------
  // OTHER STATE
  // -------------------------------------------------
  final isLoading = false.obs;
  final isPaginationLoading = false.obs;
  final errorMessage = RxnString();
  final meta = Rxn<PaginationMeta>();

  int _currentPage = 1;
  final currentType = AnnouncementType.question.obs;
  String? _communityId;

  // -------------------------------------------------
  // GETTERS
  // -------------------------------------------------
  bool get hasMore => meta.value?.hasNextPage ?? false;

  List<AnnouncementModel> get announcements => announcementIds
      .map((id) => announcementMap[id])
      .whereType<AnnouncementModel>()
      .toList();

  // -------------------------------------------------
  // INIT
  // -------------------------------------------------
  Future<void> init(String communityId) async {
    _communityId = communityId;
    await fetchAnnouncements(isRefresh: true);
  }

  // -------------------------------------------------
  // CHANGE TAB TYPE
  // -------------------------------------------------
  void changeType(AnnouncementType type) {
    if (currentType.value == type) return;
    currentType.value = type;
    fetchAnnouncements(isRefresh: true);
  }

  // -------------------------------------------------
  // FETCH FIRST PAGE
  // -------------------------------------------------
  Future<void> fetchAnnouncements({bool isRefresh = false}) async {
    if (_communityId == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      if (isRefresh) {
        _currentPage = 1;
        _resetList();
      }

      final result = await _service.getAnnouncements(
        communityId: _communityId!,
        type: currentType.value.toJson,
        page: _currentPage,
        limit: 3,
      );
      _appendAnnouncements(result.data);
      meta.value = result.meta;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------------------------------
  // PAGINATION
  // -------------------------------------------------
  Future<void> fetchMoreAnnouncements() async {
    if (!hasMore || isPaginationLoading.value || isLoading.value) return;

    try {
      isPaginationLoading.value = true;

      _currentPage++;

      final result = await _service.getAnnouncements(
        communityId: _communityId!,
        type: currentType.value.toJson,
        page: _currentPage,
        limit: 3,
      );
      _appendAnnouncements(result.data);
      meta.value = result.meta;
    } catch (e) {
      _currentPage--;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isPaginationLoading.value = false;
    }
  }

  // -------------------------------------------------
  // UPDATE HELPERS — all O(1)
  // -------------------------------------------------
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
  }

  void incrementCommentCount(String announcementId) {
    final post = announcementMap[announcementId];
    if (post == null) return;
    announcementMap[announcementId] = post.copyWith(
      commentCount: (post.commentCount ?? 0) + 1,
    );
    announcementMap.refresh();
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
  }

  void updatePollOption(String announcementId, PollOption option) {
    final post = announcementMap[announcementId];
    if (post == null) return;
    announcementMap[announcementId] = post.copyWith(
      pollOptions: [...(post.pollOptions ?? []), option],
    );
    announcementMap.refresh();
  }

  void updateEventRsvpStatus(String eventId, RsvpStatus status) {
    // find announcement that contains this event
    final announcementId = announcementIds.firstWhere(
      (id) => announcementMap[id]?.event?.id == eventId,
      orElse: () => '',
    );
    if (announcementId.isEmpty) return;

    final post = announcementMap[announcementId]!;
    final updatedEvent = post.event!.copyWith(
      myRsvpStatus: status,
      goingCount: status == RsvpStatus.going
          ? post.event!.goingCount + 1
          : post.event!.goingCount,
    );

    announcementMap[announcementId] = post.copyWith(event: updatedEvent);
    announcementMap.refresh();
  }

  // -------------------------------------------------
  // REFRESH
  // -------------------------------------------------
  Future<void> refreshAnnouncements() async {
    await fetchAnnouncements(isRefresh: true);
  }

  // -------------------------------------------------
  // PRIVATE HELPERS
  // -------------------------------------------------
  void _appendAnnouncements(List<AnnouncementModel> items) {
    String? currentUserId;
    try {
      currentUserId = Get.find<AuthController>().userModel?.id;
    } catch (_) {}

    for (final item in items) {
      announcementMap[item.id] = item;
      if (!announcementIds.contains(item.id)) announcementIds.add(item.id);

      // Seed which option the current user already voted on
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
  }

  void _resetList() {
    announcementIds.clear();
    announcementMap.clear();
  }
}

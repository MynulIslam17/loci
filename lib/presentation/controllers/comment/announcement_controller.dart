import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/common/paginatation_model.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';
import '../../../core/enums/announcement_type.dart';
import '../../../core/enums/rsvp_status.dart';
import '../../../data/models/community/announcement_model.dart';
import '../../../data/models/community/announcement_response.dart';

class AnnouncementController extends GetxController {

  // -------------------------------------------------
  // NORMALIZED STATE
  // -------------------------------------------------
  final Map<String, AnnouncementModel> _announcementMap = {};
  final List<String> _announcementIds = [];
  final Map<String, String> _votedOptionIds = {};


  // -------------------------------------------------
  // OTHER STATE
  // -------------------------------------------------
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  PaginationMeta? _meta;

  int _currentPage = 1;
  AnnouncementType _currentType = AnnouncementType.question;
  String? _communityId;

  // -------------------------------------------------
  // GETTERS
  // -------------------------------------------------
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  PaginationMeta? get meta => _meta;
  bool get hasMore => _meta?.hasNextPage ?? false;
  AnnouncementType get currentType => _currentType;

  List<AnnouncementModel> get announcements =>
      _announcementIds
          .map((id) => _announcementMap[id])
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
    if (_currentType == type) return;
    _currentType = type;
    fetchAnnouncements(isRefresh: true);
  }

  // -------------------------------------------------
  // FETCH FIRST PAGE
  // -------------------------------------------------
  Future<void> fetchAnnouncements({bool isRefresh = false}) async {
    if (_communityId == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;

      if (isRefresh) {
        _currentPage = 1;
        _resetList();
      }

      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.announcementList,
        queryParams: {
          "communityId": _communityId,
          "type": _currentType.toJson,
          "page": _currentPage,
          "limit": 3,
        },
      );

      if (response.isSuccess && response.body != null) {
        final result = AnnouncementResponse.fromJson(response.body!);
        _appendAnnouncements(result.data);
        _meta = result.meta;
      } else {
        _errorMessage =
            response.body?['message'] ?? "Failed to load announcements";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  // -------------------------------------------------
  // PAGINATION
  // -------------------------------------------------
  Future<void> fetchMoreAnnouncements() async {
    if (!hasMore || _isPaginationLoading || _isLoading) return;

    try {
      _isPaginationLoading = true;
      update();

      _currentPage++;

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.announcementList,
        queryParams: {
          "communityId": _communityId,
          "type": _currentType.toJson,
          "page": _currentPage,
          "limit": 3,
        },
      );

      if (response.isSuccess && response.body != null) {
        final result = AnnouncementResponse.fromJson(response.body!);
        _appendAnnouncements(result.data);
        _meta = result.meta;
      } else {
        _currentPage--; // rollback
        _errorMessage =
            response.body?['message'] ?? "Failed to load more";
      }
    } catch (e) {
      _currentPage--;
      _errorMessage = e.toString();
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }

  // -------------------------------------------------
  // UPDATE HELPERS — all O(1)
  // -------------------------------------------------
  bool isLiked(String announcementId) =>
      _announcementMap[announcementId]?.isLiked ?? false;

  String? votedOptionId(String announcementId) => _votedOptionIds[announcementId];

  void updatePollVote(
    String announcementId,
    String newOptionId, {
    required String userId,
    required String userName,
    required String userAvatar,
  }) {
    final post = _announcementMap[announcementId];
    if (post == null) return;

    final previousOptionId = _votedOptionIds[announcementId];
    final isChangingVote = previousOptionId != null && previousOptionId != newOptionId;
    final newVoter = Voter(userId: userId, name: userName, avatar: userAvatar);

    final updatedOptions = post.pollOptions?.map((opt) {
      if (opt.id == newOptionId) {
        return opt.copyWith(
          voteCount: opt.voteCount + 1,
          voters: [...opt.voters, newVoter],
        );
      }
      if (isChangingVote && opt.id == previousOptionId) {
        return opt.copyWith(
          voteCount: (opt.voteCount - 1).clamp(0, opt.voteCount),
          voters: opt.voters.where((v) => v.userId != userId).toList(),
        );
      }
      return opt;
    }).toList();

    _announcementMap[announcementId] = post.copyWith(
      pollOptions: updatedOptions,
      totalVotes: isChangingVote ? post.totalVotes : (post.totalVotes ?? 0) + 1,
    );
    _votedOptionIds[announcementId] = newOptionId;
    update();
  }

  void toggleLikeLocally(String announcementId) {
    final post = _announcementMap[announcementId];
    if (post == null) return;
    _announcementMap[announcementId] = post.copyWith(
      isLiked: !post.isLiked,
      likeCount: post.isLiked
          ? ((post.likeCount ?? 1) - 1).clamp(0, post.likeCount ?? 0)
          : (post.likeCount ?? 0) + 1,
    );
    update();
  }

  void incrementCommentCount(String announcementId) {
    final post = _announcementMap[announcementId];
    if (post == null) return;
    _announcementMap[announcementId] = post.copyWith(
      commentCount: (post.commentCount ?? 0) + 1,
    );
    update();
  }

  void decrementCommentCount(String announcementId) {
    final post = _announcementMap[announcementId];
    if (post == null) return;
    _announcementMap[announcementId] = post.copyWith(
      commentCount: ((post.commentCount ?? 1) - 1).clamp(0, double.maxFinite).toInt(),
    );
    update();
  }

  void updateEventRsvpStatus(String eventId, RsvpStatus status) {
    // find announcement that contains this event
    final announcementId = _announcementIds.firstWhere(
          (id) => _announcementMap[id]?.event?.id == eventId,
      orElse: () => '',
    );
    if (announcementId.isEmpty) return;

    final post = _announcementMap[announcementId]!;
    final updatedEvent = post.event!.copyWith(
      myRsvpStatus: status,
      goingCount: status == RsvpStatus.going
          ? post.event!.goingCount + 1
          : post.event!.goingCount,
    );

    _announcementMap[announcementId] = post.copyWith(event: updatedEvent);
    update();
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
    try { currentUserId = Get.find<AuthController>().userModel?.id; } catch (_) {}

    for (final item in items) {
      _announcementMap[item.id] = item;
      if (!_announcementIds.contains(item.id)) _announcementIds.add(item.id);

      // Seed which option the current user already voted on
      if (currentUserId != null && !_votedOptionIds.containsKey(item.id)) {
        for (final opt in item.pollOptions ?? []) {
          if (opt.voters.any((v) => v.userId == currentUserId)) {
            _votedOptionIds[item.id] = opt.id;
            break;
          }
        }
      }
    }
  }

  void _resetList() {
    _announcementIds.clear();
    _announcementMap.clear();
  }
}
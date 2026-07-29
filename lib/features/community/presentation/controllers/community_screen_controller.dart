import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/enums/community_role.dart';
import 'package:loci/core/enums/question_type.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/community/data/models/announcement_model.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/features/community/presentation/controllers/announcement_like_controller.dart';
import 'package:loci/features/community/presentation/controllers/my_community_controller.dart';
import 'package:loci/features/community/presentation/controllers/poll_question_controller.dart';
import 'package:loci/features/community/presentation/controllers/post_poll_option_controller.dart';
import 'package:loci/features/community/presentation/controllers/vote_controller.dart';
import 'package:loci/features/community/presentation/utils/community_comment_sheet.dart';
import 'package:loci/features/event/presentation/controllers/rsvp_controller.dart';
import 'package:loci/shared/models/post_card_view_model.dart';
import 'package:loci/shared/widgets/feed/poll_bottom_sheet.dart';

/// Orchestrates [CommunityScreen] actions.
///
/// Flow: screen widgets → this controller → feature controllers
/// → [CommunityService] → [CommunityRepository] → API.
class CommunityScreenController extends GetxController {
  static const tabTypes = AnnouncementType.values;
  static const int tabCount = 4;

  CommunityRole? role;
  String? communityId;
  String? communityName;

  /// Last tab index we reacted to, so the [TabController] listener (which fires
  /// every animation frame — continuously during a swipe) only does work when
  /// the selected tab actually changes.
  int _lastHandledTabIndex = 0;

  AnnouncementController get _announcements => Get.find();
  MyCommunityController get _community => Get.find();
  AnnouncementLikeController get _likes => Get.find();
  PollQuestionController get _questions => Get.find();
  PostPollOptionController get _pollOptions => Get.find();
  VoteController get _votes => Get.find();
  AuthController get _auth => Get.find();

  String get title {
    final name = communityName?.trim();
    return name != null && name.isNotEmpty ? name : 'Community';
  }

  void bind({
    CommunityRole? role,
    String? communityId,
    String? communityName,
  }) {
    this.role = role;
    this.communityId = communityId;
    this.communityName = communityName;

    final id = communityId;
    if (id == null || id.isEmpty) return;

    _community.prepareForLoad(id);
    _announcements.init(id);
    _loadAuthorContext(id);
  }

  /// Clears all searchable tabs (fields + API cache).
  void resetAllSearchFields(List<TextEditingController> fields) {
    assert(fields.length >= tabCount);
    for (var i = 0; i < tabCount; i++) {
      final type = tabTypes[i];
      if (type == AnnouncementType.question) continue;
      if (fields[i].text.isNotEmpty) {
        fields[i].clear();
      }
      _announcements.clearSearch(type);
    }
  }

  void handleTabChange(TabController tabs, List<TextEditingController> fields) {
    // Wait for a tap-driven animation to settle, and ignore the intermediate
    // frames of a swipe: only act once the selected tab has really changed.
    if (tabs.indexIsChanging) return;
    if (tabs.index == _lastHandledTabIndex) return;
    _lastHandledTabIndex = tabs.index;
    resetAllSearchFields(fields);
    _announcements.changeType(tabTypes[tabs.index]);
  }

  void onSearchChanged(TabController tabs, String value) {
    final type = tabTypes[tabs.index];
    if (type == AnnouncementType.question) return;
    _announcements.onSearchChanged(type, value);
  }

  void clearSearch(TabController tabs, TextEditingController searchField) {
    final type = tabTypes[tabs.index];
    if (type == AnnouncementType.question) return;
    searchField.clear();
    _announcements.clearSearch(type);
  }

  void openComments(BuildContext context, String announcementId) {
    CommunityCommentSheet.show(context, announcementId: announcementId);
  }

  void toggleLike(String postId) => _likes.toggleLike(postId);

  Future<void> postQuestion(
    String question,
    String category,
    QuestionType type,
  ) async {
    final id = communityId;
    if (id == null || id.isEmpty) return;

    if (role == CommunityRole.owner && _community.community.value == null) {
      await _community.fetchCommunity(id);
    }

    final success = await _questions.createPollQuestion(
      communityId: id,
      pollQuestion: question,
      pollCategory: category,
      qType: type.toJson,
      businessId: _ownerBusinessId,
    );

    if (success) {
      await _announcements.refreshAnnouncements(AnnouncementType.question);
    } else {
      SnackbarService.error(
        _questions.errorMessage.value ?? 'Something went wrong',
      );
    }
  }

  Future<void> submitMentionOption(
    String announcementId,
    String text,
    String image,
  ) async {
    final updated = await _pollOptions.addPollOption(
      announcementId: announcementId,
      question: text,
      imageUrl: image.isNotEmpty ? image : null,
    );

    if (updated != null) {
      final option = updated.pollOptions?.last;
      if (option != null) {
        _announcements.updatePollOption(announcementId, option);
      }
      return;
    }

    final message =
        _pollOptions.errorMessage.value ?? 'Failed to add option';
    if (!message.toLowerCase().contains('already')) {
      SnackbarService.error(message);
    }
  }

  void openPollSheet(BuildContext context, AnnouncementModel announcement) {
    PollBottomSheet.show(
      context,
      PostCardViewModel.from(
        announcement,
        communityOwnerUserId: _announcements.communityOwnerUserId.value,
      ),
      currentUserId: _auth.userModel?.id,
      onVote: (optionId) => submitVote(announcement.id, optionId),
    );
  }

  Future<void> submitVote(String announcementId, String optionId) async {
    final success = await _votes.submitVote(
      announcementId: announcementId,
      optionId: optionId,
    );

    if (success) {
      final user = _auth.userModel;
      _announcements.updatePollVote(
        announcementId,
        optionId,
        userId: user?.id ?? '',
        userName: user?.name ?? '',
        userAvatar: user?.avatar ?? '',
      );
    } else {
      SnackbarService.error(_votes.errorMessage.value ?? 'Vote failed');
    }
  }

  Future<void> submitRsvp(String eventId, RSVPController rsvp) async {
    final success = await rsvp.sendRSVP(
      eventId: eventId,
      status: RsvpStatus.going.toJson,
    );

    if (success) {
      _announcements.updateEventRsvpStatus(eventId, RsvpStatus.going);
      SnackbarService.success(rsvp.successMessage ?? 'RSVP sent');
    } else {
      SnackbarService.error(rsvp.errorMessage ?? 'RSVP failed');
    }
  }

  String? get _ownerBusinessId {
    if (role != CommunityRole.owner) return null;
    final id = _community.community.value?.business.id;
    return id != null && id.isNotEmpty ? id : null;
  }

  Future<void> _loadAuthorContext(String communityId) async {
    await _community.fetchCommunity(communityId);
    var ownerId = _community.community.value?.ownerUserId;
    if ((ownerId == null || ownerId.isEmpty) && role == CommunityRole.owner) {
      ownerId = _auth.userModel?.id;
    }
    _announcements.setCommunityOwnerUserId(ownerId);
  }
}

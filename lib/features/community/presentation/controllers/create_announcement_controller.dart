import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/features/community/presentation/controllers/my_community_controller.dart';
import 'package:loci/features/community/presentation/controllers/search_activity_controller.dart';

/// UI → [CreateAnnouncementController] → [CommunityService] → repository → API.
class CreateAnnouncementController extends GetxController {
  CreateAnnouncementController(this._service);

  final CommunityService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  final announcementType = AnnouncementType.notice.obs;
  final activityRefType = ActivityRefType.event.obs;
  final selectedActivityId = RxnString();
  final showActivitySuggestions = false.obs;
  final attachment = Rxn<File>();

  late String _communityId;
  var _postAsBusiness = false;

  static const creatableTypes = [
    AnnouncementType.notice,
    AnnouncementType.offer,
    AnnouncementType.activity,
  ];

  SearchActivityController get _activitySearch => Get.find<SearchActivityController>();

  void bind({
    required String communityId,
    bool postAsBusiness = false,
  }) {
    _communityId = communityId;
    _postAsBusiness = postAsBusiness;
    resetForm();
    _activitySearch.setup(communityId, activityRefType.value);
  }

  void resetForm() {
    announcementType.value = AnnouncementType.notice;
    activityRefType.value = ActivityRefType.event;
    selectedActivityId.value = null;
    showActivitySuggestions.value = false;
    attachment.value = null;
    errorMessage.value = null;
  }

  void setAnnouncementType(AnnouncementType type) {
    announcementType.value = type;
    attachment.value = null;
  }

  void setActivityRefType(ActivityRefType type) {
    activityRefType.value = type;
    selectedActivityId.value = null;
    showActivitySuggestions.value = false;
    _activitySearch.changeType(type);
  }

  void onActivityQueryChanged(String query) {
    selectedActivityId.value = null;
    showActivitySuggestions.value = query.trim().isNotEmpty;
    _activitySearch.onSearchChanged(query);
  }

  void selectActivity({required String id}) {
    selectedActivityId.value = id;
    showActivitySuggestions.value = false;
  }

  void clearActivitySelection() {
    selectedActivityId.value = null;
  }

  void clearAttachment() => attachment.value = null;

  void setAttachment(File file) => attachment.value = file;

  String? validateActivitySelection() {
    if (announcementType.value != AnnouncementType.activity) return null;
    final id = selectedActivityId.value;
    if (id == null || id.isEmpty) {
      return 'Please select an activity';
    }
    return null;
  }

  Map<String, String> _buildFields(String details) {
    final fields = <String, String>{
      'type': announcementType.value.toJson,
      'communityId': _communityId,
    };

    switch (announcementType.value) {
      case AnnouncementType.notice:
      case AnnouncementType.question:
      case AnnouncementType.offer:
        fields['details'] = details;
      case AnnouncementType.activity:
        fields['activityRefType'] = activityRefType.value.name;
        fields['activityId'] = selectedActivityId.value ?? '';
        fields['description'] = details;
    }

    if (_postAsBusiness && Get.isRegistered<MyCommunityController>()) {
      final businessId =
          Get.find<MyCommunityController>().community.value?.business.id;
      if (businessId != null && businessId.isNotEmpty) {
        fields['businessId'] = businessId;
      }
    }

    return fields;
  }

  Future<bool> publish(String details) async {
    final activityError = validateActivitySelection();
    if (activityError != null) {
      errorMessage.value = activityError;
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _service.createAnnouncement(
        fields: _buildFields(details.trim()),
        image: announcementType.value == AnnouncementType.offer
            ? attachment.value
            : null,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }

    unawaited(_refreshCommunityFeed());
    return true;
  }

  Future<void> _refreshCommunityFeed() async {
    if (!Get.isRegistered<AnnouncementController>()) return;
    final announcements = Get.find<AnnouncementController>();
    final type = announcementType.value;
    announcements.changeType(type);
    await announcements.fetchAnnouncements(type: type, isRefresh: true);
  }
}

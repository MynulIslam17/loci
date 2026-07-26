import 'package:get/get.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/all_community_controller.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/features/community/presentation/controllers/announcement_like_controller.dart';
import 'package:loci/features/community/presentation/controllers/announcements_comment_controller.dart';
import 'package:loci/features/community/presentation/controllers/community_member_controller.dart';
import 'package:loci/features/community/presentation/controllers/create_announcement_controller.dart';
import 'package:loci/features/community/presentation/controllers/join_community_controller.dart';
import 'package:loci/features/community/presentation/controllers/my_community_controller.dart';
import 'package:loci/features/community/presentation/controllers/poll_question_controller.dart';
import 'package:loci/features/community/presentation/controllers/post_poll_option_controller.dart';
import 'package:loci/features/community/presentation/controllers/remove_member_controller.dart';
import 'package:loci/features/community/presentation/controllers/search_activity_controller.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<CommunityService>();

    Get.put(AllCommunityController(service));
    Get.put(JoinCommunityController(service));
    Get.put(CommentController(service));
    Get.put(AnnouncementController(service));
    Get.put(MyCommunityController(service));
    Get.lazyPut(() => AnnouncementLikeController(service));
    Get.lazyPut(() => CreateAnnouncementController(service));
    Get.lazyPut(() => SearchActivityController(service));
    Get.lazyPut(() => PollQuestionController(service));
    Get.lazyPut(() => PostPollOptionController(service));
    Get.lazyPut(() => CommunityMemberController(service));
    Get.lazyPut(() => RemoveMemberController(service));
  }
}

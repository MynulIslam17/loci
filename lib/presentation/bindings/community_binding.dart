import 'package:get/get.dart';
import 'package:loci/presentation/controllers/comment/announcements_comment_controller.dart';
import 'package:loci/presentation/controllers/community/announcement_like_controller.dart';
import 'package:loci/presentation/controllers/community/create_announcement_controller.dart';
import 'package:loci/presentation/controllers/community/join_community_controller.dart';
import 'package:loci/presentation/controllers/community/my_community_controlle.dart';

import '../controllers/community/announcement_controller.dart';
import '../controllers/community/all_community_controller.dart';

class CommunityBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.put(AllCommunityController());
    Get.put(JoinCommunityController());
    Get.put(CommentController());
    Get.put(AnnouncementController());
    Get.put(MyCommunityController());
    Get.lazyPut(()=>AnnouncementLikeController());
    Get.lazyPut(()=>CreateAnnouncementController());


  }


}
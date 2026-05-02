import 'package:get/get.dart';

import '../controllers/community/all_community_controller.dart';

class CommunityBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.put(AllCommunityController());


  }


}
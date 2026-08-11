import 'package:get/get.dart';
import 'package:loci/features/common/domain/services/common_service.dart';
import 'package:loci/features/common/presentation/controllers/multipart_controller.dart';
import 'package:loci/features/common/presentation/controllers/patch_controller.dart';
import 'package:loci/features/common/presentation/controllers/post_controller.dart';

class CommonBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<CommonService>();
    Get.lazyPut(() => PostController(service), fenix: true);
    Get.lazyPut(() => PatchController(service), fenix: true);
    Get.lazyPut(() => ReusableMultipartController(service), fenix: true);
  }
}

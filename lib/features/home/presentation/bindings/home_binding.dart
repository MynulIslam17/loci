import 'package:get/get.dart';
import 'package:loci/features/home/domain/services/home_service.dart';
import 'package:loci/features/home/presentation/controllers/ad_list_controller.dart';
import 'package:loci/features/home/presentation/controllers/question_list_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<HomeService>();
    Get.lazyPut(() => QuestionListController(service), fenix: true);
    Get.lazyPut(() => AdListController(service), fenix: true);
  }
}

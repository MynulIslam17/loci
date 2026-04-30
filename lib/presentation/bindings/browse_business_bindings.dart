import 'package:get/get.dart';
import 'package:loci/presentation/controllers/browse_business/all_reviews_controller.dart';
import 'package:loci/presentation/controllers/browse_business/browse_business_controller.dart';
import 'package:loci/presentation/controllers/browse_business/business_profile_controller.dart';
import 'package:loci/presentation/controllers/browse_business/review_preview_controller.dart';

class BrowseBusinessBindings extends Bindings{
  @override
  void dependencies() {

    Get.lazyPut(()=>BrowseBusinessController());
    Get.lazyPut(()=>BusinessProfileController());
    Get.lazyPut(()=>AllReviewsController());
    Get.lazyPut(()=>ReviewPreviewController());


  }

}
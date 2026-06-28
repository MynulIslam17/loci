import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/busniess/ad_item_model.dart';

class AdListController extends GetxController {
  // Start in loading state so the home banner shows a shimmer on first build
  // instead of briefly flashing the fallback data while /ads is in flight.
  bool isLoading = true;
  String? errorMessage;
  List<AdItemModel> ads = [];

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  Future<void> fetchAds() async {
    try {
      isLoading = true;
      errorMessage = null;
      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.adsList,
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!['data'];
        if (data is List) {
          ads = data
              .whereType<Map<String, dynamic>>()
              .map(AdItemModel.fromJson)
              .toList();
        } else {
          ads = [];
        }
      } else {
        errorMessage = response.errorMessage ?? 'Failed to load ads';
        ads = [];
      }
    } catch (e) {
      errorMessage = e.toString();
      ads = [];
    } finally {
      isLoading = false;
      update();
    }
  }
}

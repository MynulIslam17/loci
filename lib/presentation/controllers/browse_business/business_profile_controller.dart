import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/busniess/browse_business_model.dart';


class BusinessProfileController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  BrowseBusinessModel? _business;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BrowseBusinessModel? get business => _business;

  Future<void> getBusinessProfile(String businessId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.businessProfile(businessId),
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!['data'];

        _business = BrowseBusinessModel.fromJson(
          data
        );
      } else {
        _errorMessage =
            response.body?['message'] ?? "Failed to load business";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }
}
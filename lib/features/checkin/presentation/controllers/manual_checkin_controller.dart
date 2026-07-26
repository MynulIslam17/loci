import 'package:get/get.dart';
import 'package:loci/features/common/domain/services/common_service.dart';

class ManualCheckInController extends GetxController {
  ManualCheckInController(this._service);

  final CommonService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<String> _successMessage = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  String? get successMessage => _successMessage.value;

  Future<bool> doManualCheckIn({
    required String checkInCode,
    required String type,
    String? name,
    String? email,
    String? avatar,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      _successMessage.value = null;

      final Map<String, dynamic> body = {'checkInCode': checkInCode};

      if (name != null || email != null || avatar != null) {
        body['leadData'] = {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (avatar != null) 'avatar': avatar,
        };
      }

      _successMessage.value = await _service.manualCheckIn(
        type: type,
        body: body,
      );
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}

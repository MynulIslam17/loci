import 'package:get/get.dart';
import 'package:loci/features/common/domain/services/common_service.dart';

class CheckInController extends GetxController {
  CheckInController(this._service);

  final CommonService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<String> _successMessage = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  String? get successMessage => _successMessage.value;

  Future<bool> doCheckIn({
    required String checkInCode,
    String? name,
    String? email,
    String? avatar,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      _successMessage.value = null;

      final Map<String, dynamic> body = {'qrPayload': checkInCode};

      if (name != null || email != null || avatar != null) {
        body['leadData'] = {
          'name': ?name,
          'email': ?email,
          'avatar': ?avatar,
        };
      }

      _successMessage.value = await _service.checkIn(body);
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}

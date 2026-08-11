import 'package:get/get.dart';
import 'package:loci/features/common/domain/services/common_service.dart';

class ManualCheckInController extends GetxController {
  ManualCheckInController(this._service);

  final CommonService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<String> _successMessage = Rxn<String>();
  final Rxn<String> _checkedInEntityId = Rxn<String>();
  final Rxn<String> _checkedInActivityType = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  String? get successMessage => _successMessage.value;
  String? get checkedInEntityId => _checkedInEntityId.value;
  String? get checkedInActivityType => _checkedInActivityType.value;

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
      _checkedInEntityId.value = null;
      _checkedInActivityType.value = null;

      final Map<String, dynamic> body = {'checkInCode': checkInCode};

      if (name != null || email != null || avatar != null) {
        body['leadData'] = {
          'name': ?name,
          'email': ?email,
          'avatar': ?avatar,
        };
      }

      final res = await _service.manualCheckIn(type: type, body: body);
      _applyResponse(res, fallbackType: type);
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void _applyResponse(
    Map<String, dynamic> res, {
    required String fallbackType,
  }) {
    _successMessage.value =
        res['message']?.toString() ?? 'Check-in successful';

    final data = res['data'];
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      // Prefer entityId when present (scan-style payloads); else activity `_id`.
      final id =
          (map['entityId'] ?? map['_id'] ?? map['id'])?.toString();
      if (id != null && id.isNotEmpty) {
        _checkedInEntityId.value = id;
      }
      final type =
          (map['entityType'] ?? map['activityType'])?.toString();
      _checkedInActivityType.value =
          (type != null && type.isNotEmpty) ? type : fallbackType;
    } else {
      _checkedInActivityType.value = fallbackType;
    }
  }
}

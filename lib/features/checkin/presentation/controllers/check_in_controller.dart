import 'package:get/get.dart';
import 'package:loci/features/common/domain/services/common_service.dart';

class CheckInController extends GetxController {
  CheckInController(this._service);

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
      _checkedInEntityId.value = null;
      _checkedInActivityType.value = null;

      final Map<String, dynamic> body = {'qrPayload': checkInCode};

      if (name != null || email != null || avatar != null) {
        body['leadData'] = {
          'name': ?name,
          'email': ?email,
          'avatar': ?avatar,
        };
      }

      final res = await _service.checkIn(body);
      _applyResponse(res);
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void _applyResponse(Map<String, dynamic> res) {
    _successMessage.value =
        res['message']?.toString() ?? 'Check-in successful';

    final data = res['data'];
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      // /checkins/scan returns entityId + entityType; `_id` is the check-in row.
      // /events|routes/check-in returns the activity itself (`_id` + activityType).
      final id =
          (map['entityId'] ?? map['_id'] ?? map['id'])?.toString();
      if (id != null && id.isNotEmpty) {
        _checkedInEntityId.value = id;
      }
      final type =
          (map['entityType'] ?? map['activityType'])?.toString();
      if (type != null && type.isNotEmpty) {
        _checkedInActivityType.value = type;
      }
    }
  }
}

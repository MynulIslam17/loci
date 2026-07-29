import 'package:get/get.dart';
import 'package:loci/features/event/data/models/event_detail_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class BusinessEventDetailsController extends GetxController {
  BusinessEventDetailsController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<EventDetailsModel> eventDetails = Rxn<EventDetailsModel>();

  String screenTitle = '';
  String _eventId = '';
  String _businessId = '';

  /// Call when opening the view screen (reads Get.arguments).
  Future<void> loadFromRouteArguments() async {
    final args = Get.arguments as Map<String, dynamic>?;
    screenTitle = args?['title']?.toString() ?? '';
    _eventId = args?['eventId']?.toString() ?? '';
    _businessId = args?['businessId']?.toString() ?? '';
    await fetchEventDetails(
      _eventId,
      businessId: _businessId.isNotEmpty ? _businessId : null,
    );
  }

  Future<void> retryLoad() => fetchEventDetails(
        _eventId,
        businessId: _businessId.isNotEmpty ? _businessId : null,
      );

  Future<void> fetchEventDetails(
    String eventId, {
    String? businessId,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    eventDetails.value = null;

    try {
      eventDetails.value = await _service.getEventDetails(
        eventId,
        businessId: businessId,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:get/get.dart';
import 'package:loci/features/event/data/models/event_details_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class BusinessEventDetailsController extends GetxController {
  BusinessEventDetailsController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<EventDetailsModel> eventDetails = Rxn<EventDetailsModel>();

  Future<void> fetchEventDetails(String eventId) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      eventDetails.value = await _service.getEventDetails(eventId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}

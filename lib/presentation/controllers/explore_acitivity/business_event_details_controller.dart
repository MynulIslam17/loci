import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

import '../../../core/enums/rsvp_status.dart';
import '../../../data/models/event/event_details_model.dart';

class BusinessEventDetailsController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  EventDetailsModel? _eventDetails;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  EventDetailsModel? get eventDetails => _eventDetails;

  /// Fetch event details by event ID
  Future<void> fetchEventDetails(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    update(); // update UI

    try {
      final NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(url: "${AppUrl.eventDetails(eventId)}");

      if (response.isSuccess && response.body != null) {
        _eventDetails = EventDetailsModel.fromJson(response.body!['data']);
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to load event details';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      update(); // update UI
    }
  }





}

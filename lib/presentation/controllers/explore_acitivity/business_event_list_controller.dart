import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import '../../../core/enums/rsvp_status.dart';
import '../../../data/models/event/event_model.dart';

class BusinessEventListController extends GetxController {
  bool _isLoading = false;


  bool _isPaginationLoading = false;

  String? _errorMessage;



  List<EventModel> _eventList = [];

  ///  Current page number for pagination
  int _currentPage = 1;

  ///  Flag to check if there is raffles next page
  bool _hasNextPage = true;

  // use to change the limit of events per page
  final int _limit = 2;

  ///  Public getters
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  List<EventModel> get eventList => _eventList;
  bool get hasMore => _hasNextPage;


  ///  Fetch events from API
  /// [isRefresh] → if true, reset page & clear list
  Future<void> fetchEvents({bool isRefresh = false, required String businessId,}) async {


    if (isRefresh) {
      _currentPage = 1; // reset page
      _hasNextPage = true; // reset pagination


    }

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final url = '${AppUrl.eventList}?page=$_currentPage&limit=$_limit&businessId=$businessId';


      final NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(url: url);

      if (response.isSuccess && response.body != null) {
        final model = EventListResponseModel.fromJson(response.body!);
        _eventList = model.events; // set fetched events
        _hasNextPage = model.meta.hasNextPage; // update pagination flag
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to load events';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;

      update();
    }
  }

  ///  Load next page for pagination
  Future<void> loadMoreEvents({required String businessId,}) async {
    if (!_hasNextPage || _isPaginationLoading || _isLoading ) return;

    _isPaginationLoading = true;
    _currentPage++; // increment page
    update(); // update UI

    try {
      final url = '${AppUrl.eventList}?page=$_currentPage&limit=$_limit&businessId=$businessId';

      final NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(url: url);

      if (response.isSuccess && response.body != null) {
        final model = EventListResponseModel.fromJson(response.body!);
        _eventList.addAll(model.events); // append new events
        _hasNextPage = model.meta.hasNextPage; // update flag
      } else {
        _currentPage--; //  rollback page if failed
      }
    } catch (e) {
      _currentPage--; //  rollback page on error
      _errorMessage = 'Pagination error: $e';
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }


  /// reset the controller
  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _errorMessage = null;
    _eventList.clear();
    _currentPage = 1;
    _hasNextPage = true;

  }

}

import 'package:get/get.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/core/constants/app_url.dart';

import '../../../data/models/explore_activity/task_model.dart';


class TaskController extends GetxController {
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  List<TaskModel> _taskList = [];

  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 20;

  // Search query state
  String _searchQuery = "";

  /// Public getters
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  List<TaskModel> get taskList => _taskList;
  bool get hasMore => _hasNextPage;

  /// Fetch tasks/activities from API
  /// [isRefresh] → if true, resets pagination and query
  /// [query] → the search string (q)
  Future<void> fetchTasks({
    bool isRefresh = false,
    String query = "",
    String? businessId
  }) async {

    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _taskList.clear();
    }

    _searchQuery = query;
    _isLoading = true;
    _errorMessage = null;
    update();

    try {

      String url = '${AppUrl.searchTask}?q=$_searchQuery&page=$_currentPage&limit=$_limit';

      if (businessId != null) {
        url += '&businessId=$businessId';
      }

      final NetworkResponse response = await Get.find<NetworkCaller>().getRequest(url: url);

      if (response.isSuccess && response.body != null) {
        final model = ActivityListResponseModel.fromJson(response.body!);
        _taskList = model.activities;
        _hasNextPage = model.meta.hasNextPage;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to load tasks';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// Load next page for infinite scrolling
  Future<void> loadMoreTasks({String? businessId}) async {
    if (!_hasNextPage || _isPaginationLoading) return;

    _isPaginationLoading = true;
    _currentPage++;
    update();

    try {
      String url = '${AppUrl.searchTask}?q=$_searchQuery&page=$_currentPage&limit=$_limit';

      if (businessId != null) {
        url += '&businessId=$businessId';
      }

      final NetworkResponse response = await Get.find<NetworkCaller>().getRequest(url: url);

      if (response.isSuccess && response.body != null) {
        final model = ActivityListResponseModel.fromJson(response.body!);
        _taskList.addAll(model.activities);
        _hasNextPage = model.meta.hasNextPage;
      } else {
        _currentPage--; // Rollback on failure
      }
    } catch (e) {
      _currentPage--; // Rollback on error
      _errorMessage = 'Pagination error: $e';
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }

  /// Reset the controller state
  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _errorMessage = null;
    _taskList.clear();
    _currentPage = 1;
    _hasNextPage = true;
    _searchQuery = "";
    update();
  }
}
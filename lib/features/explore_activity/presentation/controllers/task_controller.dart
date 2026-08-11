import 'package:get/get.dart';
import 'package:loci/features/explore_activity/data/models/activity_task_search_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class TaskController extends GetxController {
  TaskController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<TaskModel> taskList = <TaskModel>[].obs;

  int _currentPage = 1;
  final RxBool hasMore = true.obs;
  final int _limit = 20;

  String _searchQuery = '';

  Future<void> fetchTasks({
    bool isRefresh = false,
    String query = '',
    String? businessId,
  }) async {
    if (isRefresh) {
      _currentPage = 1;
      hasMore.value = true;
      taskList.clear();
    }

    _searchQuery = query;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final model = await _service.searchTasks(
        query: _searchQuery,
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
      );
      taskList.assignAll(model.activities);
      hasMore.value = model.meta.hasNextPage;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreTasks({String? businessId}) async {
    if (!hasMore.value || isPaginationLoading.value) return;

    isPaginationLoading.value = true;
    _currentPage++;

    try {
      final model = await _service.searchTasks(
        query: _searchQuery,
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
      );
      taskList.addAll(model.activities);
      hasMore.value = model.meta.hasNextPage;
    } catch (e) {
      _currentPage--;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isPaginationLoading.value = false;
    }
  }

  void reset() {
    isLoading.value = false;
    isPaginationLoading.value = false;
    errorMessage.value = null;
    taskList.clear();
    _currentPage = 1;
    hasMore.value = true;
    _searchQuery = '';
  }
}

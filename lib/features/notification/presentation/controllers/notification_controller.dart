import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/action_type.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/notification/data/models/notification_model.dart';
import 'package:loci/features/notification/domain/services/notification_service.dart';

class NotificationController extends GetxController {
  NotificationController(this._service);

  final NotificationService _service;
  final ScrollController scrollController = ScrollController();
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxnString _errorMessage = RxnString();
  final RxSet<String> _acceptingIds = <String>{}.obs;
  final RxSet<String> _rejectingIds = <String>{}.obs;

  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isLoading => isInitialLoading;
  bool get isPaginationLoading => _fetch.loadingMore.value;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage.value;

  bool isAccepting(String notificationId) =>
      _acceptingIds.contains(notificationId);

  bool isRejecting(String notificationId) =>
      _rejectingIds.contains(notificationId);

  bool isActingOn(String notificationId) =>
      isAccepting(notificationId) || isRejecting(notificationId);

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    ensureLoaded();
  }

  /// Loads the first page once the user is authenticated.
  Future<void> ensureLoaded() async {
    if (!Get.find<AuthController>().isLoggedIn) return;
    if (hasFetched || isInitialLoading || isRefreshing) return;
    await fetchNotifications();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      fetchMore();
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _fetch.beginFirstPage(isRefresh: refresh);
    _errorMessage.value = null;

    try {
      final model = await _service.getNotifications(
        page: _currentPage,
        limit: _limit,
      );
      _notifications.assignAll(model.data);
      _hasMore = model.meta.hasNextPage;
      _fetch.endFirstPage();
    } catch (e) {
      _errorMessage.value = AppErrorMessages.sanitize(e);
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> fetchMore() async {
    if (!_hasMore ||
        isPaginationLoading ||
        isInitialLoading ||
        isRefreshing) {
      return;
    }

    try {
      _fetch.beginLoadMore();
      _currentPage++;

      final model = await _service.getNotifications(
        page: _currentPage,
        limit: _limit,
      );
      _notifications.addAll(model.data);
      _hasMore = model.meta.hasNextPage;
    } catch (e) {
      _currentPage--;
      _errorMessage.value = AppErrorMessages.sanitize(e);
    } finally {
      _fetch.endLoadMore();
    }
  }

  Future<void> performAction({
    required String notificationId,
    required ActionType action,
  }) async {
    if (isActingOn(notificationId)) return;

    if (action == ActionType.accept) {
      _acceptingIds.add(notificationId);
    } else {
      _rejectingIds.add(notificationId);
    }

    try {
      await _service.performAction(
        notificationId: notificationId,
        action: action.value,
      );
      _notifications.removeWhere((n) => n.id == notificationId);
      SnackbarService.success(
        action == ActionType.accept ? 'Invitation accepted' : 'Invitation declined',
      );
    } catch (e) {
      SnackbarService.error(AppErrorMessages.sanitize(e));
    } finally {
      _acceptingIds.remove(notificationId);
      _rejectingIds.remove(notificationId);
    }
  }
}

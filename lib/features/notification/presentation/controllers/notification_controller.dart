import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/action_type.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/notification/data/models/notification_model.dart';
import 'package:loci/features/notification/domain/services/notification_service.dart';

class NotificationController extends GetxController {
  NotificationController(this._service);

  final NotificationService _service;
  final ScrollController scrollController = ScrollController();

  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isPaginationLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final RxSet<String> _acceptingIds = <String>{}.obs;
  final RxSet<String> _rejectingIds = <String>{}.obs;

  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading.value;
  bool get isPaginationLoading => _isPaginationLoading.value;
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
    if (Get.find<AuthController>().isLoggedIn) {
      fetchNotifications(refresh: true);
    }
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
    if (_isLoading.value) return;

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      if (refresh) {
        _currentPage = 1;
        _notifications.clear();
        _hasMore = true;
      }

      final model = await _service.getNotifications(
        page: _currentPage,
        limit: _limit,
      );
      _notifications.assignAll(model.data);
      _hasMore = model.meta.hasNextPage;
    } catch (e) {
      _errorMessage.value = AppErrorMessages.sanitize(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchMore() async {
    if (!_hasMore || _isPaginationLoading.value || _isLoading.value) return;

    try {
      _isPaginationLoading.value = true;
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
      _isPaginationLoading.value = false;
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

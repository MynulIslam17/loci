import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/notification/notification_model.dart';
import 'package:loci/data/models/notification/notifiation_response_model.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';

class NotificationController extends GetxController {
  final ScrollController scrollController = ScrollController();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

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
    if (_isLoading) return;

    try {
      _isLoading = true;
      _errorMessage = null;

      if (refresh) {
        _currentPage = 1;
        _notifications = [];
        _hasMore = true;
      }

      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.notifications,
        queryParams: {'page': _currentPage, 'limit': _limit},
      );

      if (response.isSuccess && response.body != null) {
        final model = NotificationResponseModel.fromJson(response.body!);
        _notifications = model.data;
        _hasMore = model.meta.hasNextPage;
      } else {
        _errorMessage = response.body?['message'] ?? 'Failed to load notifications';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> fetchMore() async {
    if (!_hasMore || _isPaginationLoading || _isLoading) return;

    try {
      _isPaginationLoading = true;
      _currentPage++;
      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.notifications,
        queryParams: {'page': _currentPage, 'limit': _limit},
      );

      if (response.isSuccess && response.body != null) {
        final model = NotificationResponseModel.fromJson(response.body!);
        _notifications = [..._notifications, ...model.data];
        _hasMore = model.meta.hasNextPage;
      } else {
        _currentPage--;
        _errorMessage = response.body?['message'] ?? 'Failed to load more';
      }
    } catch (e) {
      _currentPage--;
      _errorMessage = e.toString();
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }
}

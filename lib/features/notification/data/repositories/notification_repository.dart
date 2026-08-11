import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Notification data layer: remote HTTP via [NetworkCaller].
class NotificationRepository {
  final NetworkCaller _network;

  NotificationRepository(this._network);

  Future<Map<String, dynamic>> getNotifications({
    required int page,
    required int limit,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.notifications,
      queryParams: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ??
            res.errorMessage ??
            'Failed to load notifications',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> performAction({
    required String notificationId,
    required String action,
  }) async {
    final res = await _network.patchRequest(
      url: AppUrl.notificationAction(notificationId),
      body: {'action': action},
    );
    if (!res.isSuccess) {
      throw Exception(
        res.body?['message'] ??
            res.errorMessage ??
            'Failed to update notification',
      );
    }
    return res.body ?? {};
  }
}

import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Repository for syncing FCM/APNs push tokens to the backend API:
/// `PATCH /users/me/push-token` with `{ "pushToken": "<token>" }`.
class PushTokenRepository {
  final NetworkCaller _network;

  PushTokenRepository(this._network);

  /// Sends the device's push token to the server.
  /// Re-associates the device with the currently logged-in user.
  Future<bool> updatePushToken(String pushToken) async {
    try {
      final res = await _network.patchRequest(
        url: AppUrl.pushToken,
        body: {'pushToken': pushToken},
      );
      return res.isSuccess;
    } catch (_) {
      return false;
    }
  }
}

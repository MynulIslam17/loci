import 'package:get/get.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/features/push_notification/data/repositories/push_token_repository.dart';
import 'package:loci/features/push_notification/domain/services/chat_notification_bridge.dart';
import 'package:loci/features/push_notification/domain/services/push_notification_service.dart';

/// Registers the push notification graph as app-wide singletons.
///
/// Deliberately not a [Bindings] subclass: those attach to a route and are torn
/// down with it, whereas everything here has to survive every navigation —
/// tokens refresh, pushes arrive, and the socket bridge listens for the whole
/// session. [AppBindings] calls [register] once at startup instead.
class PushNotificationBinding {
  PushNotificationBinding._();

  /// Call after [NetworkCaller] and `ChatSocketService` are registered:
  /// the repository posts through the former and the bridge subscribes to the
  /// latter the moment it is constructed.
  static void register() {
    Get.put<PushTokenRepository>(
      PushTokenRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );

    Get.put<PushNotificationService>(
      PushNotificationService(Get.find<PushTokenRepository>()),
      permanent: true,
    );

    // Subscribes to the socket, so it must outlive any one chat screen.
    Get.put<ChatNotificationBridge>(ChatNotificationBridge(), permanent: true);
  }
}

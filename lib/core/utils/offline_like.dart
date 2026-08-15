import 'package:flutter/foundation.dart';
import 'package:loci/core/services/connectivity_service.dart';

/// Instagram-style like while offline: paint the like, then undo it.
/// Never hits the network.
class OfflineLike {
  OfflineLike._();

  /// Long enough for the heart to paint before it rolls back.
  static const Duration hold = Duration(milliseconds: 420);

  /// Returns true if the device is offline and [revert] was scheduled.
  /// Caller must already have applied the optimistic like.
  static Future<bool> revertIfOffline(VoidCallback revert) async {
    if (!ConnectivityService.isCurrentOffline) return false;
    await Future<void>.delayed(hold);
    revert();
    return true;
  }
}

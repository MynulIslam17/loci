import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/services/connectivity/connectivity_service.dart';

/// LinkedIn-style full-width connectivity strip.
///
/// Pink while offline. On reconnect it turns green, holds briefly, then
/// slides up and out.
class OfflineIndicatorBanner extends StatelessWidget {
  final Widget child;

  const OfflineIndicatorBanner({super.key, required this.child});

  static const Color _offlineBar = Color(0xFFF6D6D7);
  static const Color _onlineBar = Color(0xFFC8E6C9);
  static const SystemUiOverlayStyle _barOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ConnectivityService>()) {
      return child;
    }

    final connectivity = Get.find<ConnectivityService>();

    return Obx(() {
      final offline =
          connectivity.isOffline.value && connectivity.isAppReady.value;
      final restored =
          connectivity.justReconnected.value && connectivity.isAppReady.value;
      final showBar = offline || restored;

      if (!showBar) {
        return child;
      }

      final media = MediaQuery.of(context);
      final topInset = media.padding.top;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: _barOverlay,
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: _NetworkStatusBar(
                statusBarHeight: topInset,
                restored: restored && !offline,
              ),
            ),
            Expanded(
              child: MediaQuery(
                data: media.copyWith(
                  padding: media.padding.copyWith(top: 0),
                  viewPadding: media.viewPadding.copyWith(top: 0),
                ),
                child: child,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _NetworkStatusBar extends StatelessWidget {
  const _NetworkStatusBar({
    required this.statusBarHeight,
    required this.restored,
  });

  final double statusBarHeight;
  final bool restored;

  static const Color _text = Color(0xFF3D3D3D);
  static const Color _offlineIcon = Color(0xFF5C5C5C);
  static const Color _onlineIcon = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      color: restored
          ? OfflineIndicatorBanner._onlineBar
          : OfflineIndicatorBanner._offlineBar,
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 6, 16, 10),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: restored ? _onlineIcon : _offlineIcon,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: restored
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : Container(
                    width: 8,
                    height: 1.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Text(
            restored ? 'Back online.' : 'Network offline.',
            style: AppTextStyle.textSm(
              color: _text,
              weight: FontWeight.w500,
            ).copyWith(decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}

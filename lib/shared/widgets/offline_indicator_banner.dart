import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/services/connectivity_service.dart';

/// LinkedIn-style full-width offline strip.
///
/// Extends behind the status bar, pushes app content down, and uses dark
/// status icons on a light pink background. Hidden while online — no "Online"
/// flash — so reconnect feels like the bar simply collapsing.
class OfflineIndicatorBanner extends StatelessWidget {
  final Widget child;

  const OfflineIndicatorBanner({super.key, required this.child});

  static const Color _barColor = Color(0xFFF6D6D7);
  static const SystemUiOverlayStyle _offlineOverlay = SystemUiOverlayStyle(
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
      final showBar =
          connectivity.isOffline.value && connectivity.isAppReady.value;
      final media = MediaQuery.of(context);
      final topInset = media.padding.top;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: showBar ? _offlineOverlay : const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: showBar
                  ? _NetworkOfflineBar(statusBarHeight: topInset)
                  : const SizedBox(width: double.infinity),
            ),
            Expanded(
              child: MediaQuery(
                data: showBar
                    ? media.copyWith(
                        padding: media.padding.copyWith(top: 0),
                        viewPadding: media.viewPadding.copyWith(top: 0),
                      )
                    : media,
                child: child,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _NetworkOfflineBar extends StatelessWidget {
  const _NetworkOfflineBar({required this.statusBarHeight});

  final double statusBarHeight;

  static const Color _text = Color(0xFF3D3D3D);
  static const Color _iconFill = Color(0xFF5C5C5C);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: OfflineIndicatorBanner._barColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, statusBarHeight + 6, 16, 10),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: _iconFill,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 8,
                height: 1.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Network ',
                    style: AppTextStyle.textSm(
                      color: _text,
                      weight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: 'offline.',
                    style: AppTextStyle.textSm(
                      color: _text,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

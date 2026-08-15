import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/services/connectivity_service.dart';
import 'package:loci/routes/app_routes.dart';

/// A sleek, ultra-modern, non-blocking floating offline pill banner.
///
/// Designed with a minimalist aesthetic:
/// - "You are offline" with subtle amber status dot and wifi-off icon.
/// - Transitions smoothly to "Back online" (emerald) before fading away.
/// - Completely non-blocking (IgnorePointer ensures touches pass right through).
class OfflineIndicatorBanner extends StatelessWidget {
  final Widget child;

  const OfflineIndicatorBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ConnectivityService>()) {
      return child;
    }

    final connectivity = Get.find<ConnectivityService>();

    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 6,
          left: 0,
          right: 0,
          child: Obx(() {
            final isOffline = connectivity.isOffline.value;
            final justReconnected = connectivity.justReconnected.value;
            final isAppReady = connectivity.isAppReady.value;

            final isVisible = (isOffline || justReconnected) && isAppReady;

            return IgnorePointer(
              ignoring: true,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                offset: isVisible ? Offset.zero : const Offset(0, -1.8),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isVisible ? 1.0 : 0.0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: justReconnected
                            ? const Color(0xFF059669) // Emerald Green 600
                            : const Color(0xFF1E242B), // Modern Deep Slate
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: justReconnected
                              ? const Color(0xFF34D399).withOpacity(0.4)
                              : Colors.white.withOpacity(0.12),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: justReconnected
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFFFBBF24), // Amber pulse
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            justReconnected
                                ? Icons.wifi_rounded
                                : Icons.wifi_off_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            justReconnected ? "Back online" : "You are offline",
                            style: AppTextStyle.textXs(
                              color: Colors.white,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

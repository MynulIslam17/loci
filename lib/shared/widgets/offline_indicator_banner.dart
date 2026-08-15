import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/services/connectivity_service.dart';

/// Floating connectivity chip — Instagram / iOS status style.
///
/// Offline: frosted "Offline" capsule.
/// Reconnect: brief "Online" flash, then it slides away.
/// IgnorePointer so it never steals taps.
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
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: Obx(() {
            final isOffline = connectivity.isOffline.value;
            final justReconnected = connectivity.justReconnected.value;
            final isAppReady = connectivity.isAppReady.value;
            final isVisible = (isOffline || justReconnected) && isAppReady;
            final online = justReconnected;

            return IgnorePointer(
              ignoring: true,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                offset: isVisible ? Offset.zero : const Offset(0, -1.6),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 280),
                  opacity: isVisible ? 1.0 : 0.0,
                  child: Center(child: _Chip(online: online)),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final accent = online ? const Color(0xFF34D399) : const Color(0xFFFBBF24);

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
          decoration: BoxDecoration(
            color: online
                ? const Color(0xE6059669)
                : Colors.black.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white.withValues(alpha: online ? 0.18 : 0.14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                online ? 'Online' : 'Offline',
                style: AppTextStyle.textXs(
                  color: Colors.white,
                  weight: FontWeight.w600,
                ).copyWith(
                  letterSpacing: 0.4,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

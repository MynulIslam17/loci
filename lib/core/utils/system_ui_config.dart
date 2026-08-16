import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loci/shared/widgets/offline_indicator_banner.dart';

/// Keeps app content above the system status and navigation bars.
class SystemUiConfig {
  SystemUiConfig._();

  static const SystemUiOverlayStyle _overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  static Future<void> init() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(_overlayStyle);
  }

  static Widget wrapApp(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    final isIOS = theme.platform == TargetPlatform.iOS;
    final content = AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: SafeArea(
        top: false,
        // Skip the bottom inset on iOS so the native glass tab bar can sit
        // in the home-indicator region (Android keeps the existing inset).
        bottom: !isIOS,
        child: OfflineIndicatorBanner(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );

    if (!isIOS) return content;

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: theme.brightness,
        primaryColor: theme.colorScheme.primary,
        scaffoldBackgroundColor: theme.colorScheme.surface,
        barBackgroundColor: theme.appBarTheme.backgroundColor,
      ),
      child: content,
    );
  }
}

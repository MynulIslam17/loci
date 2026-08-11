import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: SafeArea(
        top: false,
        bottom: true,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

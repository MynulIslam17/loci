import 'package:flutter/material.dart';

extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// iOS / macOS should use Cupertino controls; Android uses Material.
  bool get isCupertino {
    final platform = theme.platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }
}
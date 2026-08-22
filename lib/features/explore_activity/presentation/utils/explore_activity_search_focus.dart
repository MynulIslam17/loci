import 'package:flutter/material.dart';

/// Keeps the explore-activities search field from reclaiming focus (and
/// reopening the keyboard) after pushing edit/view routes.
class ExploreActivitySearchFocus {
  ExploreActivitySearchFocus(this.focusNode);

  final FocusNode focusNode;

  void unfocus() {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
    final primary = FocusManager.instance.primaryFocus;
    if (primary != null && primary.hasFocus) {
      primary.unfocus();
    }
  }

  Future<T?> guard<T>(Future<T?>? Function() navigate) async {
    unfocus();
    final future = navigate();
    if (future == null) return null;
    return await future;
  }
}

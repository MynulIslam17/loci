import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Thin shell for an edit modal bottom sheet.
///
/// The caller is expected to pass a `StatefulWidget` as [child] that owns its
/// own state (text controllers, form key, submit button, navigation), so that
/// disposal is tied to the widget's `State.dispose()` and the sheet is never
/// rebuilt by external state changes while it is animating out.
class ProfileBottomSheet {
  static Future<void> show({required String title, required Widget child}) {
    final colorScheme = Get.context!.theme.colorScheme;

    return showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              child,
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:loci/core/services/connectivity/connectivity_service.dart';
import 'package:loci/shared/widgets/offline_indicator_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('OfflineIndicatorBanner keeps child mounted stably when offline state changes', (tester) async {
    final connectivity = Get.put(ConnectivityService(), permanent: true);
    connectivity.isAppReady.value = true;
    connectivity.isOffline.value = false;
    connectivity.isOnline.value = true;
    connectivity.justReconnected.value = false;

    final controller = TextEditingController(text: 'Initial text');
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OfflineIndicatorBanner(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Initial text'), findsOneWidget);
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    // Simulate going offline
    connectivity.isOffline.value = true;
    connectivity.isOnline.value = false;
    await tester.pumpAndSettle();

    // Child text field must retain focus and text
    expect(find.text('Initial text'), findsOneWidget);
    expect(focusNode.hasFocus, isTrue);

    // Simulate reconnecting
    connectivity.isOffline.value = false;
    connectivity.isOnline.value = true;
    connectivity.justReconnected.value = true;
    await tester.pumpAndSettle();

    expect(find.text('Initial text'), findsOneWidget);
    expect(focusNode.hasFocus, isTrue);

    // Simulate reconnected banner dismiss
    connectivity.justReconnected.value = false;
    await tester.pumpAndSettle();

    expect(find.text('Initial text'), findsOneWidget);
    expect(focusNode.hasFocus, isTrue);

    controller.dispose();
    focusNode.dispose();
  });
}


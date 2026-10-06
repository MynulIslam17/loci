import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:loci/features/location/presentation/bindings/live_navigation_binding.dart';
import 'package:loci/features/location/presentation/controllers/live_navigation_controller.dart';
import 'package:loci/features/location/presentation/pages/live_navigation_screen.dart';
import 'package:loci/features/location/presentation/widgets/navigation_route_sheet.dart';

void main() {
  testWidgets('navigation screen builds its reactive route card', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialBinding: LiveNavigationBinding(),
        home: const LiveNavigationScreen(),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Retry route'), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
    Get.find<LiveNavigationController>().remainingDistance.value = '1.2 km';
    await tester.pump();
    expect(find.text('1.2 km'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final sheet = find.byType(NavigationRouteSheet);
    final initialHeight = tester.getSize(sheet).height;
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(tester.getSize(sheet).height, greaterThan(initialHeight));
    expect(find.text('Retry route'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();
    expect(tester.getSize(sheet).height, lessThan(initialHeight));
    expect(find.text('Retry route'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
  });
}

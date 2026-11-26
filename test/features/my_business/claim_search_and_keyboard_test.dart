import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loci/features/my_business/data/models/find_business_response.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';
import 'package:loci/features/my_business/presentation/controllers/find_google_business_controller.dart';
import 'package:loci/shared/models/paginated_response.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/shared/widgets/keyboard_done_area.dart';

Business business(String name) => Business.fromJson(<String, dynamic>{
  'source': 'google',
  'placeId': 'place-$name',
  'name': name,
  'location': 'Chicago, IL',
  'phone': '',
  'website': '',
  'coordinates': <String, dynamic>{'lat': 0, 'lng': 0},
  'types': <String>[],
});

class FakeBusinessService implements MyBusinessService {
  final List<String?> searches = <String?>[];
  final Map<String, Completer<List<Business>>> pending =
      <String, Completer<List<Business>>>{};
  bool manual = false;

  @override
  Future<PaginatedResponse<Business>> findGoogleBusinesses({
    required int page,
    required int limit,
    String? search,
  }) async {
    searches.add(search);
    final List<Business> data = manual
        ? await (pending[search ?? ''] = Completer<List<Business>>()).future
        : <Business>[business(search ?? '')];
    return PaginatedResponse<Business>(
      success: true,
      message: '',
      data: data,
      meta: PaginationMeta(
        total: data.length,
        page: page,
        limit: limit,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('business search', () {
    late FakeBusinessService service;
    late FindGoogleBusinessController c;

    setUp(() {
      service = FakeBusinessService();
      c = FindGoogleBusinessController(service)..onInit();
    });

    test('typing quickly sends one request for the final text', () async {
      for (final String q in <String>['p', 'pi', 'piz', 'pizza']) {
        c.searchBusinesses(q);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      await Future<void>.delayed(
        FindGoogleBusinessController.searchDebounce * 2,
      );
      expect(service.searches, <String>['pizza']);
      expect(c.items.single.name, 'pizza');
      expect(c.isLoading.value, isFalse);
    });

    test('a slow older response never overwrites newer results', () async {
      service.manual = true;
      c.searchBusinesses('old');
      await Future<void>.delayed(
        FindGoogleBusinessController.searchDebounce * 2,
      );
      c.searchBusinesses('new');
      await Future<void>.delayed(
        FindGoogleBusinessController.searchDebounce * 2,
      );
      service.pending['new']!.complete(<Business>[business('new')]);
      await pumpEventQueue();
      service.pending['old']!.complete(<Business>[business('old')]);
      await pumpEventQueue();
      expect(c.items.single.name, 'new');
    });

    test('selecting a business cancels a pending search', () async {
      c.searchBusinesses('piz');
      c.selectBusiness(business('Pizzaburg'));
      await Future<void>.delayed(
        FindGoogleBusinessController.searchDebounce * 2,
      );
      expect(service.searches, isEmpty);
      expect(c.showResults.value, isFalse);
      expect(c.selectedBusiness.value?.name, 'Pizzaburg');
      expect(c.isLoading.value, isFalse);
    });
  });

  group('KeyboardDoneArea', () {
    Future<FocusNode> pumpForm(WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardDoneArea(
              showDoneBar: true,
              child: Column(
                children: <Widget>[
                  TextField(focusNode: node, maxLines: 3),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      );
      return node;
    }

    testWidgets('Done appears with the keyboard and hides it', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetViewInsets);
      final FocusNode node = await pumpForm(tester);
      expect(find.byKey(const Key('keyboard_done')), findsNothing);

      await tester.tap(find.byType(TextField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 900);
      await tester.pump();
      expect(node.hasFocus, isTrue);
      expect(find.byKey(const Key('keyboard_done')), findsOneWidget);

      await tester.tap(find.byKey(const Key('keyboard_done')));
      await tester.pump();
      expect(node.hasFocus, isFalse);
    });

    testWidgets('tapping outside a field hides the keyboard', (
      WidgetTester tester,
    ) async {
      final FocusNode node = await pumpForm(tester);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(node.hasFocus, isTrue);
      await tester.tapAt(const Offset(200, 500));
      await tester.pump();
      expect(node.hasFocus, isFalse);
    });

    testWidgets('the whole focused field stays above the Done bar', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetViewInsets);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardDoneArea(
              showDoneBar: true,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 600),
                    TextField(
                      key: const Key('message'),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 400),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('message')));
      tester.view.viewInsets = const FakeViewPadding(bottom: 336 * 3);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      final Rect field = tester.getRect(find.byType(InputDecorator));
      final Rect bar = tester.getRect(find.byType(KeyboardDoneBar));
      expect(field.bottom, lessThanOrEqualTo(bar.top));
      expect(field.top, greaterThanOrEqualTo(0));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loci/features/auth/presentation/widgets/auth_collapsing_scaffold.dart';

void main() {
  testWidgets('a short sign-in form can fully collapse the image header', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthCollapsingScaffold(
          title: 'Sign In',
          child: SizedBox(height: 100),
        ),
      ),
    );

    final position = tester.state<ScrollableState>(find.byType(Scrollable)).position;
    expect(position.maxScrollExtent, greaterThanOrEqualTo(296));

    position.jumpTo(position.maxScrollExtent);
    await tester.pump();

    expect(position.pixels, greaterThanOrEqualTo(296));
  });
}

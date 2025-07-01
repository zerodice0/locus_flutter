// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locus_flutter/main.dart';

void main() {
  testWidgets('Locus app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LocusApp(),
      ),
    );

    // Verify that the main dashboard loads
    expect(find.text('Locus'), findsOneWidget);
    expect(find.text('환영합니다!'), findsOneWidget);
    expect(find.text('장소 추가'), findsOneWidget);
    expect(find.text('장소 탐색'), findsOneWidget);
  });
}

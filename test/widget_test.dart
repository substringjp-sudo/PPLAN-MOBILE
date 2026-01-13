import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('Foundation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PPlanApp()));

    // Verify that the foundation text is displayed.
    expect(find.text('PPLAN Mobile Foundation'), findsOneWidget);
  });
}

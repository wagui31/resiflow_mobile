import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:resiflow_mobile/app.dart';

void main() {
  testWidgets('renders architecture dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ResiflowApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ResiFlow'), findsOneWidget);
    expect(find.text('Architecture mobile'), findsOneWidget);
  });
}

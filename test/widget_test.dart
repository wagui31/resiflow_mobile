import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resiflow_mobile/core/i18n/l10n.dart';
import 'package:resiflow_mobile/features/dashboard/presentation/dashboard_screen.dart';

void main() {
  testWidgets('renders architecture dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('fr'),
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: AppL10n.localizationsDelegates,
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('ResiFlow'), findsOneWidget);
    expect(find.text('Architecture mobile'), findsOneWidget);
  });
}

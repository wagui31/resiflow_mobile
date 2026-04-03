import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resiflow_mobile/core/i18n/l10n.dart';
import 'package:resiflow_mobile/features/auth/application/auth_session_controller.dart';
import 'package:resiflow_mobile/features/auth/domain/auth_models.dart';
import 'package:resiflow_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:resiflow_mobile/features/dashboard/domain/dashboard_models.dart';
import 'package:resiflow_mobile/features/dashboard/presentation/dashboard_screen.dart';

const _currentUser = UserProfile(
  id: 7,
  email: 'lea.martin@example.com',
  firstName: 'Lea',
  lastName: 'Martin',
  residenceId: 12,
  residenceName: 'Residence Horizon',
  residenceCode: 'RH-12',
  currency: 'EUR',
  numeroImmeuble: 'B',
  codeLogement: '203',
  role: UserRole.user,
  status: UserStatus.active,
  paymentStatus: PaymentStatus.upToDate,
);

const _dashboardSnapshot = DashboardSnapshot(
  overview: DashboardOverview(
    balance: 18450,
    residentCount: 42,
    lateResidentCount: 3,
    monthlyExpenses: 2180,
    recentVotes: <DashboardVote>[
      DashboardVote(
        id: 1,
        title: 'Renovation du hall',
        description: 'Validation du devis principal pour le hall d entree.',
        estimatedAmount: 3200,
        status: 'OUVERT',
        startDate: null,
        endDate: null,
      ),
    ],
  ),
  stats: DashboardStats(
    totalContributions: 26500,
    totalExpenses: 8050,
    currentBalance: 18450,
    topPayers: <DashboardTopPayer>[],
    balanceEvolution: <DashboardBalancePoint>[
      DashboardBalancePoint(month: '2026-01', balance: 15000),
      DashboardBalancePoint(month: '2026-02', balance: 16750),
      DashboardBalancePoint(month: '2026-03', balance: 18450),
    ],
  ),
);

void main() {
  testWidgets('renders architecture dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          currentUserProvider.overrideWith((ref) => _currentUser),
          dashboardSnapshotProvider.overrideWith(
            (ref) async => _dashboardSnapshot,
          ),
        ],
        child: MaterialApp(
          locale: Locale('fr'),
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: AppL10n.localizationsDelegates,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Bonjour Lea'), findsOneWidget);
    expect(
      find.text(
        'Voici l essentiel de la residence Residence Horizon aujourd hui',
      ),
      findsOneWidget,
    );
    expect(find.text('Evolution de la cagnotte'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Solde actuel'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Solde actuel'), findsOneWidget);
    expect(find.textContaining('EUR'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Votes recents'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Votes recents'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resiflow_mobile/core/i18n/l10n.dart';
import 'package:resiflow_mobile/features/auth/application/auth_session_controller.dart';
import 'package:resiflow_mobile/features/auth/domain/auth_models.dart';
import 'package:resiflow_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:resiflow_mobile/features/dashboard/domain/dashboard_models.dart';
import 'package:resiflow_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:resiflow_mobile/features/depense/application/depense_providers.dart';
import 'package:resiflow_mobile/features/depense/domain/depense_models.dart';
import 'package:resiflow_mobile/features/depense/presentation/depense_screen.dart';

const _currentUser = UserProfile(
  id: 7,
  email: 'lea.martin@example.com',
  firstName: 'Lea',
  lastName: 'Martin',
  residenceId: 12,
  residenceName: 'Residence Horizon',
  residenceCode: 'RH-12',
  currency: 'EUR',
  logement: UserLogementSummary(
    logementId: 203,
    numero: '203',
    immeuble: 'B',
    typeLogement: 'Appartement',
    codeInterne: 'RES-MAISON-001',
    active: true,
  ),
  numeroImmeuble: 'B',
  codeLogement: 'RES-MAISON-001',
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
    paymentHousingStats: DashboardPaymentHousingStats(
      residenceId: 12,
      totalActiveHousing: 42,
      totalInactiveHousing: 0,
      upToDateHousing: 39,
      lateHousing: 3,
    ),
    expenseCategoryStats: DashboardExpenseCategoryStats(
      residenceId: 12,
      categories: <DashboardExpenseCategoryCount>[
        DashboardExpenseCategoryCount(
          categoryId: 1,
          categoryName: 'Entretien',
          expenseCount: 4,
        ),
        DashboardExpenseCategoryCount(
          categoryId: 2,
          categoryName: 'Securite',
          expenseCount: 2,
        ),
      ],
    ),
  ),
);

const _sharedExpenseUserWithoutNestedLogement = UserProfile(
  id: 7,
  email: 'lea.martin@example.com',
  firstName: 'Lea',
  lastName: 'Martin',
  residenceId: 12,
  residenceName: 'Residence Horizon',
  residenceCode: 'RH-12',
  currency: 'EUR',
  logement: null,
  numeroImmeuble: 'B',
  codeLogement: 'RES-MAISON-001',
  role: UserRole.user,
  status: UserStatus.active,
  paymentStatus: PaymentStatus.late,
);

const _sharedExpenseUserWithDifferentUserAndHousingIds = UserProfile(
  id: 4,
  email: 'samir.benali@example.com',
  firstName: 'Samir',
  lastName: 'Benali',
  residenceId: 12,
  residenceName: 'Residence Horizon',
  residenceCode: 'RH-12',
  currency: 'EUR',
  logement: UserLogementSummary(
    logementId: 5,
    numero: '003',
    immeuble: null,
    typeLogement: 'Maison',
    codeInterne: 'RES1-MAISON-003',
    active: true,
  ),
  numeroImmeuble: null,
  codeLogement: 'RES1-MAISON-003',
  role: UserRole.user,
  status: UserStatus.active,
  paymentStatus: PaymentStatus.upToDate,
);

final _expenseOverview = ExpenseOverview(
  balance: const ResidenceFundBalance(residenceId: 12, balance: 500),
  categories: const <ExpenseCategory>[],
  cagnotteExpenses: const <ExpenseRecord>[],
  sharedExpenses: <SharedExpenseRecord>[
    SharedExpenseRecord(
      id: 41,
      residenceId: 12,
      categoryId: null,
      categoryName: 'Entretien',
      description: 'Reparation ascenseur',
      totalAmount: 120,
      totalPaidAmount: 0,
      amountPerPerson: 60,
      remainingParticipantsCount: 2,
      createdAt: DateTime(2026, 4, 10),
      validatedAt: DateTime(2026, 4, 11),
      createdBy: const ExpenseUserSummary(
        id: 2,
        firstName: 'Admin',
        lastName: 'Residence',
        fullName: 'Admin Residence',
      ),
      participants: const <SharedExpenseParticipantRecord>[
        SharedExpenseParticipantRecord(
          logementId: 203,
          logementLabel: 'B - 203',
          codeInterne: 'RES-MAISON-001',
          firstName: null,
          lastName: null,
          fullName: '',
          amountDue: 60,
          amountPaid: 0,
          status: SharedExpenseParticipantStatus.unpaid,
        ),
      ],
    ),
  ],
);

final _expenseOverviewWithUserIdFallbackTrap = ExpenseOverview(
  balance: const ResidenceFundBalance(residenceId: 12, balance: 500),
  categories: const <ExpenseCategory>[],
  cagnotteExpenses: const <ExpenseRecord>[],
  sharedExpenses: <SharedExpenseRecord>[
    SharedExpenseRecord(
      id: 42,
      residenceId: 12,
      categoryId: null,
      categoryName: 'Entretien',
      description: 'Travaux toiture',
      totalAmount: 5000,
      totalPaidAmount: 2500,
      amountPerPerson: 1000,
      remainingParticipantsCount: 3,
      createdAt: DateTime(2026, 4, 10),
      validatedAt: DateTime(2026, 4, 11),
      createdBy: const ExpenseUserSummary(
        id: 2,
        firstName: 'Admin',
        lastName: 'Residence',
        fullName: 'Admin Residence',
      ),
      participants: const <SharedExpenseParticipantRecord>[
        SharedExpenseParticipantRecord(
          logementId: 4,
          logementLabel: '002',
          codeInterne: 'RES1-MAISON-002',
          firstName: null,
          lastName: null,
          fullName: '',
          amountDue: 1000,
          amountPaid: 0,
          status: SharedExpenseParticipantStatus.unpaid,
        ),
        SharedExpenseParticipantRecord(
          logementId: 5,
          logementLabel: '003',
          codeInterne: 'RES1-MAISON-003',
          firstName: null,
          lastName: null,
          fullName: '',
          amountDue: 1000,
          amountPaid: 1500,
          status: SharedExpenseParticipantStatus.paid,
        ),
      ],
    ),
  ],
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
          locale: const Locale('fr'),
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: AppL10n.localizationsDelegates,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Bonjour'), findsOneWidget);
    expect(find.text('Lea Martin'), findsOneWidget);
    expect(_findRichText('Logement : RES-MAISON-001'), findsOneWidget);
    expect(_findRichText('Residence : Residence Horizon'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Evolution de la cagnotte'),
      300,
      scrollable: find.byType(Scrollable).first,
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

  testWidgets(
    'shows shared expense payment action from housing code fallback',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            currentUserProvider.overrideWith(
              (ref) => _sharedExpenseUserWithoutNestedLogement,
            ),
            expenseViewTabProvider.overrideWith((ref) => ExpenseViewTab.shared),
            expenseOverviewProvider.overrideWith(
              (ref) async => _expenseOverview,
            ),
          ],
          child: MaterialApp(
            locale: const Locale('fr'),
            supportedLocales: AppL10n.supportedLocales,
            localizationsDelegates: AppL10n.localizationsDelegates,
            home: const DepenseScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Depenses partagees'), findsOneWidget);
      expect(find.byTooltip('Payer cette depense'), findsOneWidget);
    },
  );

  testWidgets(
    'prefers housing id before user id fallback for shared expenses',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            currentUserProvider.overrideWith(
              (ref) => _sharedExpenseUserWithDifferentUserAndHousingIds,
            ),
            expenseViewTabProvider.overrideWith((ref) => ExpenseViewTab.shared),
            expenseOverviewProvider.overrideWith(
              (ref) async => _expenseOverviewWithUserIdFallbackTrap,
            ),
          ],
          child: MaterialApp(
            locale: const Locale('fr'),
            supportedLocales: AppL10n.supportedLocales,
            localizationsDelegates: AppL10n.localizationsDelegates,
            home: const DepenseScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Depenses partagees'), findsOneWidget);
      expect(find.text('Paye'), findsOneWidget);
      expect(find.byTooltip('Payer cette depense'), findsNothing);
    },
  );
}

Finder _findRichText(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is RichText && widget.text.toPlainText() == text,
    description: 'RichText with "$text"',
  );
}

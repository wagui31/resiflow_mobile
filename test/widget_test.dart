import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

import 'package:resiflow_mobile/core/i18n/l10n.dart';
import 'package:resiflow_mobile/features/auth/application/auth_session_controller.dart';
import 'package:resiflow_mobile/features/auth/domain/auth_models.dart';
import 'package:resiflow_mobile/features/cagnotte/application/cagnotte_providers.dart';
import 'package:resiflow_mobile/features/cagnotte/data/cagnotte_repository.dart';
import 'package:resiflow_mobile/features/cagnotte/domain/cagnotte_models.dart';
import 'package:resiflow_mobile/features/cagnotte/presentation/cagnotte_correction_dialog.dart';
import 'package:resiflow_mobile/features/cagnotte/presentation/cagnotte_transactions_dialog.dart';
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

final _fundTransactions = <ResidenceFundTransaction>[
  ResidenceFundTransaction(
    id: 1,
    residenceId: 12,
    logementId: 101,
    amount: 40,
    type: ResidenceFundTransactionType.contribution,
    logementCodeInterne: 'A-101',
    referenceId: null,
    createdAt: DateTime(2026, 4, 10),
  ),
  ResidenceFundTransaction(
    id: 2,
    residenceId: 12,
    logementId: 101,
    amount: 15,
    type: ResidenceFundTransactionType.depense,
    logementCodeInterne: 'A-101',
    referenceId: null,
    createdAt: DateTime(2026, 4, 11),
  ),
  ResidenceFundTransaction(
    id: 3,
    residenceId: 12,
    logementId: null,
    amount: 5,
    type: ResidenceFundTransactionType.correction,
    logementCodeInterne: null,
    referenceId: 10,
    createdAt: DateTime(2026, 4, 12),
  ),
];

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

  testWidgets(
    'confirms positive fund correction with green delta before submit',
    (WidgetTester tester) async {
      final repository = _FakeCagnotteRepository();

      await tester.pumpWidget(
        _buildCorrectionDialogTestApp(repository: repository),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Delta'), findsNothing);

      await tester.enterText(find.byType(TextFormField).first, '130');
      await tester.enterText(
        find.byType(TextFormField).last,
        'Ajustement comptable',
      );

      await tester.tap(find.text('Corriger'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmer la correction'), findsOneWidget);
      expect(find.text('Correction du solde cagnotte'), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(
        find.text(
          'Attention vous allez augmenter le solde de la cagnotte de ce delta. Cela va etre visible pour tous les residents.',
        ),
        findsOneWidget,
      );

      final deltaText = tester.widget<Text>(find.byKey(confirmationDeltaTextKey));
      expect(deltaText.data, contains('30'));
      expect(deltaText.style?.color, Colors.green.shade700);
      expect(repository.callCount, 0);

      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      expect(repository.callCount, 1);
      expect(repository.lastResidenceId, 12);
      expect(repository.lastNouveauSolde, 130);
      expect(repository.lastMotif, 'Ajustement comptable');
    },
  );

  testWidgets(
    'confirms negative fund correction with red delta before submit',
    (WidgetTester tester) async {
      final repository = _FakeCagnotteRepository();

      await tester.pumpWidget(
        _buildCorrectionDialogTestApp(repository: repository),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '75');
      await tester.enterText(find.byType(TextFormField).last, 'Regularisation');

      await tester.tap(find.text('Corriger'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Attention vous allez baisser le solde de la cagnotte de ce delta. Cela va etre visible pour tous les residents.',
        ),
        findsOneWidget,
      );

      final deltaText = tester.widget<Text>(find.byKey(confirmationDeltaTextKey));
      expect(deltaText.data, contains('25'));
      expect(deltaText.style?.color, Colors.red.shade700);
      expect(repository.callCount, 0);
    },
  );

  testWidgets(
    'shows contribution depense and correction legend labels on one row',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            residenceFundTransactionsProvider(12).overrideWith(
              (ref) async => _fundTransactions,
            ),
          ],
          child: MaterialApp(
            locale: const Locale('fr'),
            supportedLocales: AppL10n.supportedLocales,
            localizationsDelegates: AppL10n.localizationsDelegates,
            home: const Scaffold(
              body: CagnotteTransactionsDialog(
                residenceId: 12,
                currencyCode: 'EUR',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Contribution'), findsOneWidget);
      expect(find.text('Depense'), findsOneWidget);
      expect(find.text('Correction'), findsOneWidget);
      expect(find.text('Fleche verte Contribution'), findsNothing);
      expect(find.text('Fleche rouge Depense'), findsNothing);
    },
  );
}

Finder _findRichText(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is RichText && widget.text.toPlainText() == text,
    description: 'RichText with "$text"',
  );
}

Widget _buildCorrectionDialogTestApp({
  required _FakeCagnotteRepository repository,
}) {
  return ProviderScope(
    overrides: <Override>[
      cagnotteRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      locale: const Locale('fr'),
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: AppL10n.localizationsDelegates,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showCagnotteCorrectionDialog(
                context,
                residenceId: 12,
                currentBalance: 100,
                currencyCode: 'EUR',
              ),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    ),
  );
}

class _FakeCagnotteRepository extends CagnotteRepository {
  _FakeCagnotteRepository() : super(Dio());

  int callCount = 0;
  int? lastResidenceId;
  double? lastNouveauSolde;
  String? lastMotif;

  @override
  Future<CreateResidenceFundCorrectionResult> createCorrection({
    required int residenceId,
    required double nouveauSolde,
    required String motif,
  }) async {
    callCount += 1;
    lastResidenceId = residenceId;
    lastNouveauSolde = nouveauSolde;
    lastMotif = motif;
    return CreateResidenceFundCorrectionResult(
      residenceId: residenceId,
      ancienSolde: 100,
      nouveauSolde: nouveauSolde,
      delta: nouveauSolde - 100,
      correctionId: 1,
      transactionId: 2,
      typeTransaction: ResidenceFundTransactionType.correction,
      dateCreation: DateTime(2026, 4, 19),
    );
  }
}

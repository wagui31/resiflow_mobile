import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resiflow_mobile/core/i18n/l10n.dart';
import 'package:resiflow_mobile/features/auth/application/auth_session_controller.dart';
import 'package:resiflow_mobile/features/auth/domain/auth_models.dart';
import 'package:resiflow_mobile/features/users/data/users_repository.dart';
import 'package:resiflow_mobile/features/users/presentation/admin_user_reactivation_dialog.dart';

const _adminUser = UserProfile(
  id: 1,
  email: 'admin@example.com',
  firstName: 'Admin',
  lastName: 'Residence',
  residenceId: 12,
  residenceName: 'Residence Horizon',
  residenceCode: 'RH-12',
  currency: 'EUR',
  logement: UserLogementSummary(
    logementId: 100,
    numero: '100',
    immeuble: 'A',
    typeLogement: 'Appartement',
    codeInterne: 'RES-A-100',
    active: true,
  ),
  numeroImmeuble: 'A',
  codeLogement: 'RES-A-100',
  role: UserRole.admin,
  status: UserStatus.active,
  paymentStatus: PaymentStatus.upToDate,
);

const _rejectedUser = UserProfile(
  id: 7,
  email: 'rejected.user@example.com',
  firstName: 'Lina',
  lastName: 'Durand',
  residenceId: 12,
  residenceName: 'Residence Horizon',
  residenceCode: 'RH-12',
  currency: 'EUR',
  logement: UserLogementSummary(
    logementId: 201,
    numero: '201',
    immeuble: 'B',
    typeLogement: 'Appartement',
    codeInterne: 'RES-B-201',
    active: true,
  ),
  numeroImmeuble: 'B',
  codeLogement: 'RES-B-201',
  role: UserRole.user,
  status: UserStatus.rejected,
  paymentStatus: PaymentStatus.unknown,
);

const _archivedUser = UserProfile(
  id: 8,
  email: 'archived.user@example.com',
  firstName: 'Nora',
  lastName: 'Petit',
  residenceId: 12,
  residenceName: 'Residence Horizon',
  residenceCode: 'RH-12',
  currency: 'EUR',
  logement: UserLogementSummary(
    logementId: 202,
    numero: '202',
    immeuble: 'B',
    typeLogement: 'Appartement',
    codeInterne: 'RES-B-202',
    active: true,
  ),
  numeroImmeuble: 'B',
  codeLogement: 'RES-B-202',
  role: UserRole.user,
  status: UserStatus.archived,
  paymentStatus: PaymentStatus.unknown,
);

void main() {
  testWidgets('shows rejected and archived tabs and reactivates a user', (
    WidgetTester tester,
  ) async {
    final repository = _FakeUsersRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          currentUserProvider.overrideWith((ref) => _adminUser),
          currentUserRoleProvider.overrideWith((ref) => UserRole.admin),
          usersRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: AppL10n.localizationsDelegates,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showAdminUserReactivationDialog(context),
                  child: const Text('Ouvrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Gerer les utilisateurs'), findsOneWidget);
    expect(find.text('Rejected'), findsWidgets);
    expect(find.text('Archived'), findsOneWidget);
    expect(find.text('Lina Durand'), findsOneWidget);

    await tester.tap(find.text('Reactiver').first);
    await tester.pumpAndSettle();

    expect(find.text('Reactiver cet utilisateur ?'), findsOneWidget);
    await tester.tap(find.text('Reactiver').last);
    await tester.pumpAndSettle();

    expect(repository.reactivatedUserIds, contains(7));
    expect(find.text('L utilisateur a ete reactive.'), findsOneWidget);
  });
}

class _FakeUsersRepository extends UsersRepository {
  _FakeUsersRepository() : super(Dio());

  final List<int> reactivatedUserIds = <int>[];

  @override
  Future<List<UserProfile>> fetchAdminUsers({UserStatus? status}) async {
    return switch (status) {
      UserStatus.rejected => const <UserProfile>[_rejectedUser],
      UserStatus.archived => const <UserProfile>[_archivedUser],
      _ => const <UserProfile>[],
    };
  }

  @override
  Future<void> reactivateUser(int userId, {String? comment}) async {
    reactivatedUserIds.add(userId);
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:resiflow_mobile/core/i18n/l10n.dart';
import 'package:resiflow_mobile/core/router/app_router.dart';
import 'package:resiflow_mobile/features/auth/data/auth_repository.dart';
import 'package:resiflow_mobile/features/auth/domain/auth_models.dart';
import 'package:resiflow_mobile/features/auth/presentation/auth_screen.dart';
import 'package:resiflow_mobile/features/auth/presentation/forgot_password_screens.dart';

void main() {
  testWidgets('forgot password email step requests a code and opens code step', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(
      _buildForgotPasswordApp(
        repository: repository,
        router: GoRouter(
          initialLocation: forgotPasswordEmailPath,
          routes: <RouteBase>[
            GoRoute(
              path: forgotPasswordEmailPath,
              name: forgotPasswordEmailRouteName,
              builder: (context, state) => const ForgotPasswordEmailScreen(),
            ),
            GoRoute(
              path: forgotPasswordCodePath,
              name: forgotPasswordCodeRouteName,
              builder: (context, state) {
                final extra = state.extra! as ForgotPasswordCodeRouteData;
                return ForgotPasswordCodeScreen(email: extra.email);
              },
            ),
            GoRoute(
              path: loginPath,
              name: loginRouteName,
              builder: (context, state) => const Scaffold(body: Text('LOGIN')),
            ),
          ],
        ),
      ),
    );

    final sendCodeButton = find.widgetWithText(FilledButton, 'Envoyer le code');

    await tester.enterText(find.byType(TextField).first, 'lea.martin@example.com');
    await tester.ensureVisible(sendCodeButton);
    await tester.tap(sendCodeButton);
    await tester.pumpAndSettle();

    expect(repository.requestedEmails, <String>['lea.martin@example.com']);
    expect(find.text('Verifier le code'), findsWidgets);
    expect(find.textContaining('lea.martin@example.com'), findsOneWidget);
  });

  testWidgets('forgot password code step verifies code and opens reset step', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(
      _buildForgotPasswordApp(
        repository: repository,
        router: GoRouter(
          initialLocation: forgotPasswordCodePath,
          routes: <RouteBase>[
            GoRoute(
              path: forgotPasswordCodePath,
              name: forgotPasswordCodeRouteName,
              builder: (context, state) => const ForgotPasswordCodeScreen(
                email: 'lea.martin@example.com',
              ),
            ),
            GoRoute(
              path: forgotPasswordResetPath,
              name: forgotPasswordResetRouteName,
              builder: (context, state) {
                final extra = state.extra! as ForgotPasswordResetRouteData;
                return ForgotPasswordResetScreen(
                  email: extra.email,
                  resetSessionToken: extra.resetSessionToken,
                  resetSessionExpiresAt: extra.resetSessionExpiresAt,
                );
              },
            ),
            GoRoute(
              path: loginPath,
              name: loginRouteName,
              builder: (context, state) => const Scaffold(body: Text('LOGIN')),
            ),
          ],
        ),
      ),
    );

    final verifyCodeButton = find.widgetWithText(FilledButton, 'Verifier le code');

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.ensureVisible(verifyCodeButton);
    await tester.tap(verifyCodeButton);
    await tester.pumpAndSettle();

    expect(repository.verifiedCodes, <String>['123456']);
    expect(find.text('Choisir un nouveau mot de passe'), findsOneWidget);
  });

  testWidgets('forgot password reset step updates password and returns to login', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(
      _buildForgotPasswordApp(
        repository: repository,
        router: GoRouter(
          initialLocation: forgotPasswordResetPath,
          routes: <RouteBase>[
            GoRoute(
              path: forgotPasswordResetPath,
              name: forgotPasswordResetRouteName,
              builder: (context, state) => ForgotPasswordResetScreen(
                email: 'lea.martin@example.com',
                resetSessionToken: 'reset-session-token',
                resetSessionExpiresAt: DateTime(2026, 5, 16, 12, 30),
              ),
            ),
            GoRoute(
              path: loginPath,
              name: loginRouteName,
              builder: (context, state) => const Scaffold(body: Text('LOGIN')),
            ),
          ],
        ),
      ),
    );

    final resetButton = find.widgetWithText(
      FilledButton,
      'Reinitialiser le mot de passe',
    );

    await tester.enterText(find.byType(TextField).first, 'Secure#Password1');
    await tester.enterText(find.byType(TextField).at(1), 'Secure#Password1');
    await tester.ensureVisible(resetButton);
    await tester.tap(resetButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(repository.lastResetSessionToken, 'reset-session-token');
    expect(repository.lastResetPassword, 'Secure#Password1');
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('login screen exposes the forgot password entry point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: AppL10n.localizationsDelegates,
          home: const AuthScreen(mode: AuthScreenMode.login),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Mot de passe oublie ?'), findsOneWidget);
  });
}

Widget _buildForgotPasswordApp({
  required _FakeAuthRepository repository,
  required GoRouter router,
}) {
  return ProviderScope(
    overrides: <Override>[
      authRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(
      locale: const Locale('fr'),
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: AppL10n.localizationsDelegates,
      routerConfig: router,
    ),
  );
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(Dio());

  final List<String> requestedEmails = <String>[];
  final List<String> verifiedCodes = <String>[];
  String? lastResetSessionToken;
  String? lastResetPassword;

  @override
  Future<ForgotPasswordRequestCodeResult> requestPasswordResetCode({
    required String email,
  }) async {
    requestedEmails.add(email.trim());
    return const ForgotPasswordRequestCodeResult(
      message: 'Si un compte existe pour cet email, un code a ete envoye.',
    );
  }

  @override
  Future<ForgotPasswordVerifyCodeResult> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    requestedEmails.add(email.trim());
    verifiedCodes.add(code.trim());
    return ForgotPasswordVerifyCodeResult(
      resetSessionToken: 'reset-session-token',
      resetSessionExpiresAt: DateTime(2026, 5, 16, 12, 30),
    );
  }

  @override
  Future<void> resetForgottenPassword({
    required String resetSessionToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    lastResetSessionToken = resetSessionToken;
    lastResetPassword = newPassword;
  }
}

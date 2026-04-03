import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../../features/auth/domain/auth_session_models.dart';
import '../../features/auth/presentation/account_status_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/landing_screen.dart';
import '../../features/auth/presentation/session_loading_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/depense/presentation/depense_screen.dart';
import '../../features/paiement/presentation/paiement_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/vote/presentation/vote_screen.dart';
import 'app_shell.dart';

const String sessionLoadingRouteName = 'session-loading';
const String landingRouteName = 'landing';
const String loginRouteName = 'login';
const String registerRouteName = 'register';
const String accountStatusRouteName = 'account-status';
const String dashboardRouteName = 'dashboard';
const String paiementRouteName = 'paiement';
const String depenseRouteName = 'depense';
const String voteRouteName = 'vote';
const String settingsRouteName = 'settings';

const String sessionLoadingPath = '/session-loading';
const String landingPath = '/landing';
const String loginPath = '/login';
const String registerPath = '/register';
const String accountStatusPath = '/account-status';
const String dashboardPath = '/dashboard';
const String paiementPath = '/paiement';
const String depensePath = '/depense';
const String votePath = '/vote';
const String settingsPath = '/settings';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authSessionControllerProvider);

  return GoRouter(
    initialLocation: sessionLoadingPath,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isBootRoute = location == sessionLoadingPath;
      final isPublicRoute =
          location == landingPath ||
          location == loginPath ||
          location == registerPath ||
          location == accountStatusPath;
      final isPrivateRoute = !isBootRoute && !isPublicRoute;
      final accountNotice = switch (session) {
        UnauthenticatedSession(:final accountNotice) => accountNotice,
        _ => null,
      };

      if (session.isBootstrapping) {
        return isBootRoute ? null : sessionLoadingPath;
      }

      if (session.isAuthenticated) {
        if (location == dashboardPath || isPrivateRoute) {
          return null;
        }
        return dashboardPath;
      }

      if (accountNotice != null) {
        if (location == accountStatusPath || location == loginPath) {
          return null;
        }
        return accountStatusPath;
      }

      if (location == accountStatusPath || isBootRoute) {
        return landingPath;
      }

      if (isPrivateRoute) {
        return landingPath;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: sessionLoadingPath,
        name: sessionLoadingRouteName,
        builder: (context, state) => const SessionLoadingScreen(),
      ),
      GoRoute(
        path: landingPath,
        name: landingRouteName,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: loginPath,
        name: loginRouteName,
        builder: (context, state) =>
            const AuthScreen(mode: AuthScreenMode.login),
      ),
      GoRoute(
        path: registerPath,
        name: registerRouteName,
        builder: (context, state) =>
            const AuthScreen(mode: AuthScreenMode.register),
      ),
      GoRoute(
        path: accountStatusPath,
        name: accountStatusRouteName,
        builder: (context, state) => const AccountStatusScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: paiementPath,
                name: paiementRouteName,
                builder: (context, state) => const PaiementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: depensePath,
                name: depenseRouteName,
                builder: (context, state) => const DepenseScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: dashboardPath,
                name: dashboardRouteName,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: votePath,
                name: voteRouteName,
                builder: (context, state) => const VoteScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: settingsPath,
                name: settingsRouteName,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

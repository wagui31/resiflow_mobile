import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/depense/presentation/depense_screen.dart';
import '../../features/paiement/presentation/paiement_screen.dart';
import '../../features/residence/presentation/residence_screen.dart';
import '../../features/vote/presentation/vote_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    routes: <RouteBase>[
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/paiement',
        name: 'paiement',
        builder: (context, state) => const PaiementScreen(),
      ),
      GoRoute(
        path: '/depense',
        name: 'depense',
        builder: (context, state) => const DepenseScreen(),
      ),
      GoRoute(
        path: '/vote',
        name: 'vote',
        builder: (context, state) => const VoteScreen(),
      ),
      GoRoute(
        path: '/residence',
        name: 'residence',
        builder: (context, state) => const ResidenceScreen(),
      ),
    ],
  );
});

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const List<_DashboardModule> _modules = <_DashboardModule>[
    _DashboardModule(
      title: 'Authentification',
      description: 'Structure du module auth.',
      routeName: 'auth',
      icon: Icons.lock_outline,
    ),
    _DashboardModule(
      title: 'Paiements',
      description: 'Base du module paiement.',
      routeName: 'paiement',
      icon: Icons.payments_outlined,
    ),
    _DashboardModule(
      title: 'Depenses',
      description: 'Base du module depense.',
      routeName: 'depense',
      icon: Icons.receipt_long_outlined,
    ),
    _DashboardModule(
      title: 'Votes',
      description: 'Base du module vote.',
      routeName: 'vote',
      icon: Icons.how_to_vote_outlined,
    ),
    _DashboardModule(
      title: 'Residence',
      description: 'Base du module residence.',
      routeName: 'residence',
      icon: Icons.apartment_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ResiFlow'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text(
            'Architecture mobile',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Socle Flutter feature-based conforme au contexte projet: Riverpod, Dio, go_router et separation core/features.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          for (final module in _modules) ...<Widget>[
            Card(
              child: ListTile(
                leading: Icon(module.icon),
                title: Text(module.title),
                subtitle: Text(module.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.goNamed(module.routeName),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DashboardModule {
  const _DashboardModule({
    required this.title,
    required this.description,
    required this.routeName,
    required this.icon,
  });

  final String title;
  final String description;
  final String routeName;
  final IconData icon;
}

import 'package:flutter/material.dart';

import '../../../core/widgets/module_scaffold.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Authentification',
      description:
          'Espace reserve au parcours de connexion et d inscription, sans logique metier implemente a ce stade.',
    );
  }
}

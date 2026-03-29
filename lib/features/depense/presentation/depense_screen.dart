import 'package:flutter/material.dart';

import '../../../core/widgets/module_scaffold.dart';

class DepenseScreen extends StatelessWidget {
  const DepenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Depense',
      description:
          'Point d entree du module depense. La logique applicative reste volontairement absente a ce stade.',
    );
  }
}

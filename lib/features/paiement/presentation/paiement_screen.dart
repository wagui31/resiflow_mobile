import 'package:flutter/material.dart';

import '../../../core/widgets/module_scaffold.dart';

class PaiementScreen extends StatelessWidget {
  const PaiementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Paiement',
      description:
          'Point d entree du module paiement. Les integrations API seront branchees uniquement sur les endpoints backend existants lors des taches concernees.',
    );
  }
}

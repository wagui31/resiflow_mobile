import 'package:flutter/material.dart';

import '../../../core/widgets/module_scaffold.dart';

class ResidenceScreen extends StatelessWidget {
  const ResidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Residence',
      description:
          'Point d entree du module residence. Les futurs ecrans utiliseront l API backend reelle sans deplacer la logique metier cote frontend.',
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/widgets/module_scaffold.dart';

class VoteScreen extends StatelessWidget {
  const VoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Vote',
      description:
          'Point d entree du module vote, avec un squelette d interface uniquement destine a valider l architecture.',
    );
  }
}

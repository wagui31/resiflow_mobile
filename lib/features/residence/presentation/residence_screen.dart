import 'package:flutter/material.dart';

import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/widgets/module_scaffold.dart';

class ResidenceScreen extends StatelessWidget {
  const ResidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      title: context.l10n.moduleResidenceTitle,
      description: context.l10n.moduleResidenceScreenDescription,
    );
  }
}

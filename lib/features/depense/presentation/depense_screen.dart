import 'package:flutter/material.dart';

import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/widgets/module_scaffold.dart';

class DepenseScreen extends StatelessWidget {
  const DepenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      title: context.l10n.moduleExpenseTitle,
      description: context.l10n.moduleExpenseScreenDescription,
    );
  }
}

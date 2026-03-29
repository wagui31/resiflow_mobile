import 'package:flutter/material.dart';

import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/widgets/module_scaffold.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      title: context.l10n.moduleAuthTitle,
      description: context.l10n.moduleAuthScreenDescription,
    );
  }
}

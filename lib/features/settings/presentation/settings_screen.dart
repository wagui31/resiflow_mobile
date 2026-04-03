import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/application/auth_session_controller.dart';
import '../../../features/auth/domain/auth_models.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/module_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
    final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;

    return ModuleScaffold(
      title: context.l10n.moduleSettingsTitle,
      description: isAdmin
          ? context.l10n.moduleUsersAdminDescription
          : context.l10n.moduleUsersUserDescription,
      child: ResponsiveBuilder(
        builder: (context, layout) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(layout.isMobile ? 18 : 22),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isAdmin
                          ? context.l10n.moduleUsersAdminTitle
                          : context.l10n.moduleUsersUserTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: layout.itemSpacing / 2),
                    Text(
                      isAdmin
                          ? context.l10n.moduleUsersAdminBody
                          : context.l10n.moduleUsersUserBody,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

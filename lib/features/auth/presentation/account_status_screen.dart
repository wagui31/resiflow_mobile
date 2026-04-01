import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/widgets/responsive_page_container.dart';
import '../application/auth_session_controller.dart';
import '../domain/auth_models.dart';

class AccountStatusScreen extends ConsumerWidget {
  const AccountStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(currentAccountNoticeProvider);
    final status = notice?.status ?? UserStatus.unknown;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = switch (status) {
      UserStatus.pending => context.l10n.authStatusPending,
      UserStatus.rejected => context.l10n.authStatusRejected,
      _ => context.l10n.authStatusLabel,
    };
    final message = switch (status) {
      UserStatus.pending => notice?.message ?? context.l10n.authRegisterSuccessPending,
      UserStatus.rejected =>
        notice?.message ?? context.l10n.accountStatusRejectedDescription,
      _ => '',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.moduleAuthTitle),
        actions: const <Widget>[
          LanguageSwitcher(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ResponsivePageContainer(
          child: ResponsiveBuilder(
            builder: (context, layout) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(layout.horizontalPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              status == UserStatus.rejected
                                  ? Icons.gpp_bad_outlined
                                  : Icons.hourglass_top_rounded,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            message,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: <Widget>[
                              FilledButton(
                                onPressed: () {
                                  context.goNamed(loginRouteName);
                                },
                                child: Text(context.l10n.authLoginButton),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(authSessionControllerProvider.notifier)
                                      .dismissAccountNotice();
                                  context.goNamed(landingRouteName);
                                },
                                child: Text(
                                  context.l10n.accountStatusBackToLanding,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

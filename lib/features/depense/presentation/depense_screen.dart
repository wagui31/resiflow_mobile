import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_dashboard_theme.dart';
import '../../../core/widgets/global_page_header.dart';
import '../../../core/widgets/responsive_page_container.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../application/depense_providers.dart';
import '../data/depense_repository.dart';
import '../domain/depense_models.dart';

class DepenseScreen extends ConsumerWidget {
  const DepenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsivePageContainer(
        child: ResponsiveBuilder(
          builder: (context, layout) {
            final userRole =
                ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
            final currencyCode = ref.watch(currentCurrencyCodeProvider);
            final selectedTab = ref.watch(expenseViewTabProvider);
            final isAdmin =
                userRole == UserRole.admin || userRole == UserRole.superAdmin;
            final overviewAsync = selectedTab == ExpenseViewTab.pending
                ? const AsyncValue<ExpenseOverview>.loading()
                : ref.watch(expenseOverviewProvider);
            final pendingItemsCount = isAdmin
                ? ref.watch(pendingExpenseAdminItemsCountProvider).valueOrNull
                : null;

            return ListView(
              children: <Widget>[
                GlobalPageHeader(
                  title: context.l10n.moduleExpenseTitle,
                  layout: layout,
                  residenceBalance: overviewAsync.valueOrNull?.balance.balance,
                  currencyCode: currencyCode,
                  actions: <Widget>[
                    IconButton(
                      onPressed: () => _refreshExpenseView(ref, selectedTab),
                      tooltip: context.l10n.expenseRefreshTooltip,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                SizedBox(height: layout.sectionSpacing),
                _ExpenseModeCard(
                  layout: layout,
                  isAdmin: isAdmin,
                  pendingCount: pendingItemsCount,
                ),
                SizedBox(height: layout.sectionSpacing),
                if (selectedTab == ExpenseViewTab.pending)
                  _AdminPendingSharedExpensePaymentsBody(layout: layout)
                else
                  overviewAsync.when(
                    loading: () => _ExpenseLoadingState(layout: layout),
                    error: (error, _) => _ExpenseErrorState(
                      message: _resolveExpenseErrorMessage(context, error),
                      onRetry: () => _refreshExpenseView(ref, selectedTab),
                    ),
                    data: (overview) {
                      return switch (selectedTab) {
                        ExpenseViewTab.shared => _ExpenseSharedSection(
                          layout: layout,
                          overview: overview,
                          currencyCode: currencyCode,
                          isAdmin: isAdmin,
                        ),
                        _ => _ExpenseCagnotteSection(
                          layout: layout,
                          overview: overview,
                          currencyCode: currencyCode,
                          isAdmin: isAdmin,
                        ),
                      };
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExpenseModeCard extends ConsumerWidget {
  const _ExpenseModeCard({
    required this.layout,
    required this.isAdmin,
    required this.pendingCount,
  });

  final ResponsiveLayout layout;
  final bool isAdmin;
  final int? pendingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedTab = ref.watch(expenseViewTabProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: layout.isDesktop ? 360 : layout.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.expenseModeSelectorLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.expenseModeSelectorDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: layout.isMobile ? layout.maxContentWidth : 420,
            child: SegmentedButton<ExpenseViewTab>(
              segments: <ButtonSegment<ExpenseViewTab>>[
                ButtonSegment<ExpenseViewTab>(
                  value: ExpenseViewTab.cagnotte,
                  icon: const Icon(Icons.account_balance_wallet_rounded),
                  label: _SegmentLabel(context.l10n.expenseModeCagnotte),
                ),
                ButtonSegment<ExpenseViewTab>(
                  value: ExpenseViewTab.shared,
                  icon: const Icon(Icons.group_work_rounded),
                  label: _SegmentLabel(context.l10n.expenseModeShared),
                ),
                if (isAdmin)
                  ButtonSegment<ExpenseViewTab>(
                    value: ExpenseViewTab.pending,
                    icon: const Icon(Icons.pending_actions_rounded),
                    label: _PendingExpenseSegmentLabel(
                      label: context.l10n.expenseModePending,
                      pendingCount: pendingCount,
                    ),
                  ),
              ],
              selected: <ExpenseViewTab>{selectedTab},
              onSelectionChanged: (selection) =>
                  ref.read(expenseViewTabProvider.notifier).state =
                      selection.first,
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCagnotteSection extends ConsumerWidget {
  const _ExpenseCagnotteSection({
    required this.layout,
    required this.overview,
    required this.currencyCode,
    required this.isAdmin,
  });

  final ResponsiveLayout layout;
  final ExpenseOverview overview;
  final String? currencyCode;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCategoryIds = ref.watch(selectedExpenseCategoryIdsProvider);
    final approvedCagnotteExpenses = overview.cagnotteExpenses;
    final availableCategories = overview.categories
        .where(
          (category) => approvedCagnotteExpenses.any(
            (expense) => expense.categoryId == category.id,
          ),
        )
        .toList();
    final availableCategoryIds = availableCategories
        .map((category) => category.id)
        .toSet();
    final effectiveCategoryIds = selectedCategoryIds
        .where(availableCategoryIds.contains)
        .toSet();
    final filteredExpenses = effectiveCategoryIds.isEmpty
        ? approvedCagnotteExpenses
        : approvedCagnotteExpenses
              .where(
                (expense) =>
                    expense.categoryId != null &&
                    effectiveCategoryIds.contains(expense.categoryId),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(layout.isMobile ? 20 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                colorScheme.primary.withValues(alpha: 0.14),
                colorScheme.tertiary.withValues(alpha: 0.1),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      context.l10n.expenseCagnotteTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (isAdmin) ...<Widget>[
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: overview.categories.isEmpty
                          ? null
                          : () => _showCreateExpenseDialog(
                              context,
                              ref,
                              overview,
                            ),
                      tooltip: context.l10n.expenseCreateAction,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isAdmin && !layout.isMobile
                      ? layout.maxContentWidth - 88
                      : layout.maxContentWidth,
                ),
                child: Text(
                  context.l10n.expenseCagnotteDescription,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: layout.sectionSpacing),
        _ExpenseCategoryFilter(
          layout: layout,
          categories: availableCategories,
          selectedCategoryIds: effectiveCategoryIds,
          onSelectionChanged: (categoryIds) {
            ref.read(selectedExpenseCategoryIdsProvider.notifier).state =
                categoryIds;
          },
        ),
        SizedBox(height: layout.sectionSpacing),
        if (filteredExpenses.isEmpty)
          _ExpenseEmptyState(body: context.l10n.expenseEmptyBody)
        else
          Wrap(
            spacing: layout.itemSpacing,
            runSpacing: layout.itemSpacing,
            children: filteredExpenses
                .map(
                  (expense) => SizedBox(
                    width: _expenseCardWidth(layout),
                    child: _ExpenseCard(
                      expense: expense,
                      currencyCode: currencyCode,
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _ExpenseSharedSection extends StatelessWidget {
  const _ExpenseSharedSection({
    required this.layout,
    required this.overview,
    required this.currencyCode,
    required this.isAdmin,
  });

  final ResponsiveLayout layout;
  final ExpenseOverview overview;
  final String? currencyCode;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(layout.isMobile ? 20 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                colorScheme.primary.withValues(alpha: 0.14),
                colorScheme.tertiary.withValues(alpha: 0.1),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      context.l10n.expenseSharedTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (isAdmin) ...<Widget>[
                    const SizedBox(width: 12),
                    Consumer(
                      builder: (context, ref, _) {
                        return IconButton.filledTonal(
                          onPressed: () =>
                              _showCreateSharedExpenseDialog(context, overview),
                          tooltip: context.l10n.expenseSharedCreateAction,
                          icon: const Icon(Icons.add_rounded),
                        );
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isAdmin && !layout.isMobile
                      ? layout.maxContentWidth - 88
                      : layout.maxContentWidth,
                ),
                child: Text(
                  context.l10n.expenseSharedDescription,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: layout.sectionSpacing),
        if (overview.sharedExpenses.isEmpty)
          _ExpenseEmptyState(body: context.l10n.expenseSharedEmptyBody)
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: overview.sharedExpenses
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: layout.itemSpacing),
                    child: _SharedExpenseCard(
                      expense: entry.value,
                      currencyCode: currencyCode,
                      showCategoryTag: entry.key != 0,
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _CreateSharedExpenseDialog extends ConsumerStatefulWidget {
  const _CreateSharedExpenseDialog({required this.overview});

  final ExpenseOverview overview;

  @override
  ConsumerState<_CreateSharedExpenseDialog> createState() =>
      _CreateSharedExpenseDialogState();
}

class _CreateSharedExpenseDialogState
    extends ConsumerState<_CreateSharedExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _loadingParticipants = true;
  bool _submitting = false;
  int? _participantsCount;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadParticipantsCount();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = ref.watch(currentCurrencyCodeProvider);
    final mediaQuery = MediaQuery.of(context);
    final maxDialogHeight = mediaQuery.size.height * 0.78;
    final amount = _normalizeAmount(_amountController.text);
    final estimatedAmountPerPerson = _estimateSharedAmountPerPerson(
      amount,
      _participantsCount,
    );
    final participantLabel = _loadingParticipants
        ? context.l10n.authSubmittingLabel
        : _participantsCount?.toString() ?? '-';
    final estimatedLabel = estimatedAmountPerPerson == null
        ? context.l10n.expenseSharedEstimatedAmountPlaceholder
        : CurrencyFormatter.format(
            context,
            estimatedAmountPerPerson,
            currencyCode: currencyCode,
          );

    return AlertDialog(
      title: Text(context.l10n.expenseSharedCreateDialogTitle),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 460, maxHeight: maxDialogHeight),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(context.l10n.expenseSharedCreateDialogBody),
                ),
                const SizedBox(height: 18),
                _ReadOnlyExpenseField(
                  label: context.l10n.expenseSharedParticipantsLabel,
                  value: participantLabel,
                  isLoading: _loadingParticipants,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  enabled: !_submitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: context.l10n.expenseSharedTotalAmountLabel,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    final normalized = _normalizeAmount(value);
                    if (normalized == null) {
                      return context.l10n.expenseCreateAmountError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _ReadOnlyExpenseField(
                  label:
                      context.l10n.expenseSharedEstimatedAmountPerPersonLabel,
                  value: estimatedLabel,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_submitting,
                  minLines: 3,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: context.l10n.expenseCreateDescriptionLabel,
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.expenseCreateDescriptionError;
                    }
                    return null;
                  },
                ),
                if (_errorText != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.paymentDialogCancel),
        ),
        FilledButton(
          onPressed:
              _submitting ||
                  _loadingParticipants ||
                  (_participantsCount ?? 0) <= 0
              ? null
              : _submit,
          child: Text(
            _submitting
                ? context.l10n.authSubmittingLabel
                : context.l10n.expenseSharedCreateSubmit,
          ),
        ),
      ],
    );
  }

  Future<void> _loadParticipantsCount() async {
    try {
      final result = await ref
          .read(depenseRepositoryProvider)
          .fetchResidenceParticipantsCount(widget.overview.balance.residenceId);
      if (!mounted) {
        return;
      }
      setState(() {
        _participantsCount = result.participantsCount;
        _loadingParticipants = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingParticipants = false;
        _errorText = _resolveExpenseErrorMessage(context, error);
      });
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final amount = _normalizeAmount(_amountController.text);
    if (amount == null) {
      return;
    }
    if ((_participantsCount ?? 0) <= 0) {
      setState(() {
        _errorText = _resolveExpenseErrorMessage(
          context,
          const ApiException(
            message:
                'Aucun logement actif n est disponible pour cette residence.',
          ),
        );
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await ref
          .read(depenseRepositoryProvider)
          .createSharedExpense(
            residenceId: widget.overview.balance.residenceId,
            amount: amount,
            description: _descriptionController.text.trim(),
          );
      ref.invalidate(expenseOverviewProvider);
      ref.invalidate(adminPendingExpensesProvider);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorText = _resolveExpenseErrorMessage(context, error);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _ReadOnlyExpenseField extends StatelessWidget {
  const _ReadOnlyExpenseField({
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  final String label;
  final String value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedExpenseEditableAmountField extends StatelessWidget {
  const _SharedExpenseEditableAmountField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.validator,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.edit_rounded),
        filled: true,
        fillColor: colorScheme.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.72),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: validator,
    );
  }
}

class _CreateExpenseDialog extends ConsumerStatefulWidget {
  const _CreateExpenseDialog({required this.overview});

  final ExpenseOverview overview;

  @override
  ConsumerState<_CreateExpenseDialog> createState() =>
      _CreateExpenseDialogState();
}

class _CreateExpenseDialogState extends ConsumerState<_CreateExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedCategoryId;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.overview.categories.isEmpty
        ? null
        : widget.overview.categories.first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxDialogHeight = mediaQuery.size.height * 0.7;

    return AlertDialog(
      title: Text(context.l10n.expenseCreateDialogTitle),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 440, maxHeight: maxDialogHeight),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(context.l10n.expenseCreateDialogBody),
                const SizedBox(height: 18),
                DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: context.l10n.expenseCreateCategoryLabel,
                  ),
                  items: widget.overview.categories
                      .map(
                        (category) => DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _selectedCategoryId = value),
                  validator: (value) {
                    if (value == null) {
                      return context.l10n.expenseCreateCategoryError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  enabled: !_submitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: context.l10n.expenseCreateAmountLabel,
                  ),
                  validator: (value) {
                    final normalized = _normalizeAmount(value);
                    if (normalized == null) {
                      return context.l10n.expenseCreateAmountError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_submitting,
                  minLines: 3,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: context.l10n.expenseCreateDescriptionLabel,
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.expenseCreateDescriptionError;
                    }
                    return null;
                  },
                ),
                if (_errorText != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.paymentDialogCancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(
            _submitting
                ? context.l10n.authSubmittingLabel
                : context.l10n.expenseCreateSubmit,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final categoryId = _selectedCategoryId;
    final amount = _normalizeAmount(_amountController.text);
    if (categoryId == null || amount == null) {
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await ref
          .read(depenseRepositoryProvider)
          .createCagnotteExpense(
            residenceId: widget.overview.balance.residenceId,
            categoryId: categoryId,
            amount: amount,
            description: _descriptionController.text.trim(),
          );
      ref.invalidate(expenseOverviewProvider);
      ref.invalidate(adminPendingExpensesProvider);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorText = _resolveExpenseErrorMessage(context, error);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _ExpenseCategoryFilter extends StatelessWidget {
  const _ExpenseCategoryFilter({
    required this.layout,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onSelectionChanged,
  });

  final ResponsiveLayout layout;
  final List<ExpenseCategory> categories;
  final Set<int> selectedCategoryIds;
  final ValueChanged<Set<int>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = _categoryFilterSummary(
      context,
      categories,
      selectedCategoryIds,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 18 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.expenseCategoryFilterLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          MenuAnchor(
            menuChildren: <Widget>[
              CheckboxMenuButton(
                value: selectedCategoryIds.isEmpty,
                onChanged: (_) => onSelectionChanged(<int>{}),
                closeOnActivate: false,
                child: Text(context.l10n.expenseCategoryAll),
              ),
              if (categories.isNotEmpty) const Divider(height: 1),
              ...categories.map(
                (category) => CheckboxMenuButton(
                  value: selectedCategoryIds.contains(category.id),
                  onChanged: (checked) {
                    final nextSelection = Set<int>.from(selectedCategoryIds);
                    if (checked ?? false) {
                      nextSelection.add(category.id);
                    } else {
                      nextSelection.remove(category.id);
                    }
                    onSelectionChanged(nextSelection);
                  },
                  closeOnActivate: false,
                  child: Text(category.name),
                ),
              ),
            ],
            builder: (context, controller, child) => SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.filter_list_rounded),
                label: Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense, required this.currencyCode});

  final ExpenseRecord expense;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    final categoryName = expense.categoryName?.trim().isNotEmpty == true
        ? expense.categoryName!.trim()
        : context.l10n.expenseCategoryUnknown;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  categoryName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.format(
                  context,
                  expense.amount,
                  currencyCode: currencyCode,
                ),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: dashboardTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            expense.description,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 20,
            runSpacing: 14,
            children: <Widget>[
              _ExpenseMetaItem(
                label: context.l10n.expenseCreatedAtLabel,
                value: _formatExpenseDate(context, expense.createdAt),
              ),
              _ExpenseMetaItem(
                label: context.l10n.expenseValidatedAtLabel,
                value: _formatExpenseDate(context, expense.validatedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SharedExpenseCard extends ConsumerStatefulWidget {
  const _SharedExpenseCard({
    required this.expense,
    required this.currencyCode,
    this.showCategoryTag = true,
  });

  final SharedExpenseRecord expense;
  final String? currencyCode;
  final bool showCategoryTag;

  @override
  ConsumerState<_SharedExpenseCard> createState() => _SharedExpenseCardState();
}

class _SharedExpenseCardState extends ConsumerState<_SharedExpenseCard> {
  bool _expanded = false;
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    final totalAmount = widget.expense.totalAmount;
    final totalPaidAmount = widget.expense.totalPaidAmount;
    final progress = _sharedExpenseProgress(totalPaidAmount, totalAmount);
    final isOverLimit =
        totalAmount > 0 && totalPaidAmount - totalAmount > 0.009;
    final totalAmountLabel = CurrencyFormatter.format(
      context,
      totalAmount,
      currencyCode: widget.currencyCode,
    );
    final amountPerPersonLabel = CurrencyFormatter.format(
      context,
      widget.expense.amountPerPerson ?? 0,
      currencyCode: widget.currencyCode,
    );
    final paidAmountLabel = CurrencyFormatter.format(
      context,
      totalPaidAmount,
      currencyCode: widget.currencyCode,
    );
    final currentUser = ref.watch(currentUserProvider);
    final currentParticipant = _findCurrentSharedExpenseParticipant(
      currentUser,
      widget.expense,
    );
    final userRole = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
    final isAdmin =
        userRole == UserRole.admin || userRole == UserRole.superAdmin;
    final currentParticipantStatus = currentParticipant == null
        ? null
        : _participantStatusMeta(context, currentParticipant.status);
    final currentParticipantPaidAmount = currentParticipant == null
        ? null
        : CurrencyFormatter.format(
            context,
            currentParticipant.amountPaid,
            currencyCode: widget.currencyCode,
          );
    final currentRemainingAmount = currentParticipant == null
        ? 0.0
        : _sharedExpenseRemainingAmount(widget.expense, currentParticipant);
    final canCreatePayment =
        currentParticipant != null &&
        _canPaySharedExpenseParticipant(
          currentParticipant.status,
          currentRemainingAmount,
        );
    final participantsCount = widget.expense.participants.length;
    final remainingParticipantsCount = widget.expense.remainingParticipantsCount
        .clamp(0, participantsCount);
    final paymentSummaryLabel = currentParticipant == null
        ? null
        : _sharedCurrentPaymentLabel(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: widget.showCategoryTag
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.expense.categoryName?.trim().isNotEmpty ==
                                    true
                                ? widget.expense.categoryName!.trim()
                                : context.l10n.expenseCategoryUnknown,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          if ((currentParticipantStatus != null &&
                  paymentSummaryLabel != null) ||
              isAdmin) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (currentParticipantStatus != null &&
                    paymentSummaryLabel != null)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: currentParticipantStatus.color.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              currentParticipantStatus.icon,
                              size: 18,
                              color: currentParticipantStatus.color,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '$paymentSummaryLabel ${currentParticipantStatus.label}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: currentParticipantStatus.color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (canCreatePayment) ...<Widget>[
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: () => _showSharedExpensePaymentDialog(
                      context,
                      expense: widget.expense,
                      participant: currentParticipant,
                      currencyCode: widget.currencyCode,
                      suggestedAmount: currentRemainingAmount,
                    ),
                    tooltip: _sharedExpensePayActionLabel(context),
                    icon: const Icon(Icons.payments_rounded),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      maximumSize: const Size(44, 44),
                    ),
                  ),
                ],
                if (isAdmin) ...<Widget>[
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: _deleting ? null : _handleDeleteSharedExpense,
                    tooltip: _deleteSharedExpenseTooltip(context),
                    icon: _deleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer,
                      foregroundColor: colorScheme.error,
                      minimumSize: const Size(44, 44),
                      maximumSize: const Size(44, 44),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (currentParticipantPaidAmount != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              _sharedExpensePaidSummaryLabel(
                context,
                currentParticipantPaidAmount,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.expense.description,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    context.l10n.expenseSharedAmountPerPersonLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    amountPerPersonLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SharedExpenseProgressBar(
            progress: progress,
            paidAmountLabel: paidAmountLabel,
            totalAmountLabel: totalAmountLabel,
            isOverLimit: isOverLimit,
            progressColor: dashboardTheme.successColor,
            trackColor: colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _expanded
                          ? context.l10n.expenseSharedHideParticipants
                          : context.l10n.expenseSharedShowParticipants,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    _sharedExpenseParticipantsProgressLabel(
                      context,
                      remainingParticipantsCount,
                      participantsCount,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                '${context.l10n.expenseCreatedAtLabel} ${_formatExpenseDate(context, widget.expense.createdAt)}'
                ' | ${context.l10n.expenseValidatedAtLabel} ${_formatExpenseDate(context, widget.expense.validatedAt)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                context.l10n.expenseSharedCreatedBy(
                  _sharedCreatorLabel(context, widget.expense.createdBy),
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              heightFactor: _expanded ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: widget.expense.participants
                      .map(
                        (participant) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SharedExpenseParticipantRow(
                            expense: widget.expense,
                            participant: participant,
                            currencyCode: widget.currencyCode,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteSharedExpense() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_deleteSharedExpenseConfirmTitle(context)),
        content: Text(_deleteSharedExpenseConfirmBody(context)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.paymentDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_deleteSharedExpenseConfirmActionLabel(context)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _deleting = true);
    try {
      await ref
          .read(depenseRepositoryProvider)
          .deleteSharedExpense(widget.expense.id);
      _refreshAfterAdminSharedExpenseDeletion(ref);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_deleteSharedExpenseSuccessMessage(context))),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_resolveExpenseErrorMessage(context, error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }
}

class _SharedExpenseParticipantRow extends ConsumerStatefulWidget {
  const _SharedExpenseParticipantRow({
    required this.expense,
    required this.participant,
    required this.currencyCode,
  });

  final SharedExpenseRecord expense;
  final SharedExpenseParticipantRecord participant;
  final String? currencyCode;

  @override
  ConsumerState<_SharedExpenseParticipantRow> createState() =>
      _SharedExpenseParticipantRowState();
}

class _SharedExpenseParticipantRowState
    extends ConsumerState<_SharedExpenseParticipantRow> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final participant = widget.participant;
    final statusMeta = _participantStatusMeta(context, participant.status);
    final userRole = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
    final isAdmin =
        userRole == UserRole.admin || userRole == UserRole.superAdmin;
    final canCancelPayment =
        isAdmin &&
        (participant.status == SharedExpenseParticipantStatus.partiallyPaid ||
            participant.status == SharedExpenseParticipantStatus.paid);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  participant.displayLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusMeta.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(statusMeta.icon, size: 18, color: statusMeta.color),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            statusMeta.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: statusMeta.color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 46,
                child: canCancelPayment
                    ? IconButton.filledTonal(
                        onPressed: _deleting ? null : _handleCancelPayment,
                        tooltip: _cancelSharedExpenseHousingPaymentTooltip(
                          context,
                        ),
                        icon: _deleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.restart_alt_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.errorContainer,
                          foregroundColor: colorScheme.error,
                          minimumSize: const Size(44, 44),
                          maximumSize: const Size(44, 44),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          if (participant.supportingLabel.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              participant.supportingLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            context.l10n.expenseSharedParticipantAmountSummary(
              CurrencyFormatter.format(
                context,
                participant.amountPaid,
                currencyCode: widget.currencyCode,
              ),
              CurrencyFormatter.format(
                context,
                participant.amountDue,
                currencyCode: widget.currencyCode,
              ),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancelPayment() async {
    final participant = widget.participant;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_cancelSharedExpenseHousingPaymentConfirmTitle(context)),
        content: Text(
          _cancelSharedExpenseHousingPaymentConfirmBody(
            context,
            logementLabel: participant.displayLabel,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.paymentDialogCancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(_cancelSharedExpenseHousingPaymentActionLabel(context)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _deleting = true);
    try {
      await ref
          .read(depenseRepositoryProvider)
          .cancelSharedExpenseHousingPayments(
            expenseId: widget.expense.id,
            logementId: participant.logementId,
          );
      _refreshAfterAdminSharedExpenseHousingPaymentDeletion(ref);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _cancelSharedExpenseHousingPaymentSuccessMessage(
              context,
              logementLabel: participant.displayLabel,
            ),
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_resolveExpenseErrorMessage(context, error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }
}

class _SharedExpensePaymentDialog extends ConsumerStatefulWidget {
  const _SharedExpensePaymentDialog({
    required this.expense,
    required this.participant,
    required this.currencyCode,
    required this.suggestedAmount,
  });

  final SharedExpenseRecord expense;
  final SharedExpenseParticipantRecord participant;
  final String? currencyCode;
  final double suggestedAmount;

  @override
  ConsumerState<_SharedExpensePaymentDialog> createState() =>
      _SharedExpensePaymentDialogState();
}

class _SharedExpensePaymentDialogState
    extends ConsumerState<_SharedExpensePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: _formatAmountInputValue(widget.suggestedAmount),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxDialogHeight = mediaQuery.size.height * 0.7;
    final remainingAmount = _sharedExpenseRemainingAmount(
      widget.expense,
      widget.participant,
    );

    return AlertDialog(
      title: Text(_sharedExpensePaymentDialogTitle(context)),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: maxDialogHeight),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _sharedExpensePaymentDialogBody(
                    context,
                    widget.expense.description,
                  ),
                ),
                const SizedBox(height: 18),
                _ReadOnlyExpenseField(
                  label: _sharedExpenseRemainingAmountFieldLabel(context),
                  value: CurrencyFormatter.format(
                    context,
                    remainingAmount,
                    currencyCode: widget.currencyCode,
                  ),
                ),
                const SizedBox(height: 16),
                _SharedExpenseEditableAmountField(
                  controller: _amountController,
                  enabled: !_submitting,
                  label: _sharedExpenseAmountToPayFieldLabel(context),
                  validator: (value) {
                    final normalized = _normalizeAmount(value);
                    if (normalized == null) {
                      return _sharedExpenseAmountToPayError(context);
                    }
                    return null;
                  },
                ),
                if ((_errorText ?? '').isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    _errorText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.payments_rounded),
          label: Text(_sharedExpensePaySubmitLabel(context)),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final amount = _normalizeAmount(_amountController.text);
    if (amount == null) {
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await ref
          .read(depenseRepositoryProvider)
          .paySharedExpense(expenseId: widget.expense.id, amount: amount);
      ref.invalidate(expenseOverviewProvider);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorText = _resolveExpenseErrorMessage(context, error);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _ExpenseMetaItem extends StatelessWidget {
  const _ExpenseMetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

SharedExpenseParticipantRecord? _findCurrentSharedExpenseParticipant(
  UserProfile? currentUser,
  SharedExpenseRecord expense,
) {
  if (currentUser == null) {
    return null;
  }

  final currentLogementId = currentUser.logement?.logementId;
  final currentUserId = currentUser.id;
  final currentLogementCode =
      (currentUser.logement?.codeInterne ?? currentUser.codeLogement ?? '')
          .trim()
          .toLowerCase();
  final currentLogementLabel =
      currentUser.logement?.displayLabel.trim().toLowerCase() ?? '';

  for (final participant in expense.participants) {
    if (currentLogementId != null &&
        currentLogementId > 0 &&
        participant.logementId == currentLogementId) {
      return participant;
    }
  }

  for (final participant in expense.participants) {
    final participantCode = (participant.codeInterne ?? '')
        .trim()
        .toLowerCase();
    if (currentLogementCode.isNotEmpty &&
        participantCode.isNotEmpty &&
        participantCode == currentLogementCode) {
      return participant;
    }
  }

  for (final participant in expense.participants) {
    final participantLabel = (participant.logementLabel ?? '')
        .trim()
        .toLowerCase();
    if (currentLogementLabel.isNotEmpty &&
        participantLabel.isNotEmpty &&
        participantLabel == currentLogementLabel) {
      return participant;
    }
  }

  for (final participant in expense.participants) {
    if (currentUserId > 0 && participant.logementId == currentUserId) {
      return participant;
    }
  }

  return null;
}

String _sharedExpenseParticipantsProgressLabel(
  BuildContext context,
  int unpaidCount,
  int totalCount,
) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return '$unpaidCount/$totalCount logements';
  }
  return '$unpaidCount/$totalCount housing units';
}

String _sharedCurrentPaymentLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Paiement';
  }
  return 'Payment';
}

String _sharedExpensePaidSummaryLabel(
  BuildContext context,
  String amountLabel,
) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Vous avez deja paye $amountLabel';
  }
  return 'You already paid $amountLabel';
}

String _sharedExpensePayActionLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Payer cette depense';
  }
  return 'Pay this expense';
}

String _sharedExpensePaymentDialogTitle(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Initier un paiement pour cette depense partagee';
  }
  return 'Start a payment for this shared expense';
}

String _sharedExpensePaymentDialogBody(
  BuildContext context,
  String description,
) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Saisissez le montant a payer pour "$description". Le reste affiche est informatif, le montant saisi peut etre inferieur ou superieur.';
  }
  return 'Enter the amount you want to pay for "$description". The remaining amount is informational, and the amount you enter can be lower or higher.';
}

String _sharedExpenseRemainingAmountFieldLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Reste a payer';
  }
  return 'Remaining amount';
}

String _sharedExpenseAmountToPayFieldLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Montant a payer';
  }
  return 'Amount to pay';
}

String _sharedExpenseAmountToPayError(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Saisissez un montant valide.';
  }
  return 'Enter a valid amount.';
}

String _sharedExpensePaySubmitLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Initier le paiement';
  }
  return 'Start payment';
}

bool _canPaySharedExpenseParticipant(
  SharedExpenseParticipantStatus status,
  double remainingAmount,
) {
  if (remainingAmount <= 0.009) {
    return false;
  }
  return status == SharedExpenseParticipantStatus.unpaid ||
      status == SharedExpenseParticipantStatus.partiallyPaid;
}

double _sharedExpenseRemainingAmount(
  SharedExpenseRecord expense,
  SharedExpenseParticipantRecord participant,
) {
  final dueAmount = participant.amountDue > 0
      ? participant.amountDue
      : (expense.amountPerPerson ?? 0);
  final remainingAmount = dueAmount - participant.amountPaid;
  if (remainingAmount <= 0) {
    return 0;
  }
  return double.parse(remainingAmount.toStringAsFixed(2));
}

String _formatAmountInputValue(double amount) {
  final normalized = double.parse(amount.toStringAsFixed(2));
  if (normalized == normalized.truncateToDouble()) {
    return normalized.toStringAsFixed(0);
  }
  return normalized.toStringAsFixed(2);
}

class _SharedExpenseProgressBar extends StatelessWidget {
  const _SharedExpenseProgressBar({
    required this.progress,
    required this.paidAmountLabel,
    required this.totalAmountLabel,
    required this.isOverLimit,
    required this.progressColor,
    required this.trackColor,
  });

  final double progress;
  final String paidAmountLabel;
  final String totalAmountLabel;
  final bool isOverLimit;
  final Color progressColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fillColor = isOverLimit ? colorScheme.tertiary : progressColor;
    final currentAmountLabel = isOverLimit
        ? '$paidAmountLabel / $totalAmountLabel'
        : paidAmountLabel;
    final isComplete = progress >= 0.999;
    final showPaidOutside = !isOverLimit && progress > 0 && progress < 0.28;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final fillWidth = trackWidth * progress.clamp(0.0, 1.0);

        return SizedBox(
          height: 32,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 32,
                decoration: BoxDecoration(
                  color: trackColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: fillWidth,
                height: 32,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: !showPaidOutside && progress > 0
                    ? Text(
                        currentAmountLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              if (showPaidOutside)
                Positioned(
                  left: ((fillWidth + 10).clamp(10.0, trackWidth - 70) as num)
                      .toDouble(),
                  child: Text(
                    paidAmountLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: fillColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (!isComplete && !isOverLimit)
                Positioned(
                  right: 10,
                  child: Text(
                    totalAmountLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminPendingSharedExpensePaymentsBody extends ConsumerWidget {
  const _AdminPendingSharedExpensePaymentsBody({required this.layout});

  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(adminPendingSharedExpensePaymentsProvider);
    final expensesAsync = ref.watch(adminPendingExpensesProvider);

    final firstError = expensesAsync.error ?? paymentsAsync.error;
    if (firstError != null &&
        expensesAsync.valueOrNull == null &&
        paymentsAsync.valueOrNull == null) {
      return _ExpenseErrorState(
        message: _resolveExpenseErrorMessage(context, firstError),
        onRetry: () {
          ref.invalidate(adminPendingExpensesProvider);
          ref.invalidate(adminPendingSharedExpensePaymentsProvider);
        },
      );
    }

    final isInitialLoading =
        (expensesAsync.isLoading && expensesAsync.valueOrNull == null) ||
        (paymentsAsync.isLoading && paymentsAsync.valueOrNull == null);
    if (isInitialLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final expenses = expensesAsync.valueOrNull ?? const <ExpenseRecord>[];
    final payments =
        paymentsAsync.valueOrNull ?? const <SharedExpensePaymentRecord>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AdminPendingExpensesSection(layout: layout, expenses: expenses),
        SizedBox(height: layout.sectionSpacing),
        _AdminPendingSharedExpensePaymentsSection(
          layout: layout,
          payments: payments,
        ),
      ],
    );
  }
}

class _AdminPendingExpensesSection extends ConsumerWidget {
  const _AdminPendingExpensesSection({
    required this.layout,
    required this.expenses,
  });

  final ResponsiveLayout layout;
  final List<ExpenseRecord> expenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyCode = ref.watch(currentCurrencyCodeProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _pendingExpensesTitle(context),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _pendingExpensesBody(context),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          if (expenses.isEmpty)
            _ExpenseEmptyState(
              title: _pendingExpensesEmptyTitle(context),
              body: _pendingExpensesEmptyBody(context),
            )
          else
            Column(
              children: expenses
                  .map(
                    (expense) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(layout.isMobile ? 16 : 18),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      expense.description.isNotEmpty
                                          ? expense.description
                                          : '${context.l10n.moduleExpenseTitle} #${expense.id}',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _expenseTypeLabel(context, expense.type),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  context.l10n.paymentAdminStatusPending,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            CurrencyFormatter.format(
                              context,
                              expense.amount,
                              currencyCode: currencyCode,
                            ),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            children: <Widget>[
                              _AdminExpensePaymentMeta(
                                label: _expenseTypeMetaLabel(context),
                                value: _expenseTypeLabel(context, expense.type),
                              ),
                              if ((expense.categoryName ?? '')
                                  .trim()
                                  .isNotEmpty)
                                _AdminExpensePaymentMeta(
                                  label:
                                      context.l10n.expenseCreateCategoryLabel,
                                  value: expense.categoryName!.trim(),
                                ),
                              if (expense.amountPerPerson != null)
                                _AdminExpensePaymentMeta(
                                  label: context
                                      .l10n
                                      .expenseSharedAmountPerPersonLabel,
                                  value: CurrencyFormatter.format(
                                    context,
                                    expense.amountPerPerson!,
                                    currencyCode: currencyCode,
                                  ),
                                ),
                              _AdminExpensePaymentMeta(
                                label: context.l10n.expenseCreatedAtLabel,
                                value: _formatExpenseDate(
                                  context,
                                  expense.createdAt,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _expenseCreatedByLabel(
                                context,
                                expense.createdById,
                              ),
                              textAlign: TextAlign.right,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: <Widget>[
                              FilledButton.tonalIcon(
                                onPressed: () => _handleAdminExpenseAction(
                                  context,
                                  ref,
                                  expense,
                                  _ExpenseAdminAction.approve,
                                ),
                                icon: const Icon(Icons.check_rounded),
                                label: Text(context.l10n.paymentAdminValidate),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _handleAdminExpenseAction(
                                  context,
                                  ref,
                                  expense,
                                  _ExpenseAdminAction.reject,
                                ),
                                icon: const Icon(Icons.close_rounded),
                                label: Text(_cancelExpenseActionLabel(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _AdminPendingSharedExpensePaymentsSection extends ConsumerWidget {
  const _AdminPendingSharedExpensePaymentsSection({
    required this.layout,
    required this.payments,
  });

  final ResponsiveLayout layout;
  final List<SharedExpensePaymentRecord> payments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyCode = ref.watch(currentCurrencyCodeProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.paymentAdminPendingTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.paymentAdminPendingBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          if (payments.isEmpty)
            _ExpenseEmptyState(
              title: context.l10n.paymentAdminPendingEmptyTitle,
              body: context.l10n.paymentAdminPendingEmptyBody,
            )
          else
            Column(
              children: payments
                  .map(
                    (payment) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(layout.isMobile ? 16 : 18),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      payment.adminLogementLabel,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    if (payment
                                        .expenseLabel
                                        .isNotEmpty) ...<Widget>[
                                      const SizedBox(height: 4),
                                      Text(
                                        payment.expenseLabel,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  context.l10n.paymentAdminStatusPending,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            CurrencyFormatter.format(
                              context,
                              payment.amount,
                              currencyCode: currencyCode,
                            ),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            children: <Widget>[
                              _AdminExpensePaymentMeta(
                                label: context.l10n.paymentAdminResidentEmail,
                                value: payment.logementLabel,
                              ),
                              _AdminExpensePaymentMeta(
                                label: context.l10n.moduleExpenseTitle,
                                value: payment.expenseLabel.isNotEmpty
                                    ? payment.expenseLabel
                                    : '${payment.expenseId}',
                              ),
                              _AdminExpensePaymentMeta(
                                label: _sharedExpensePaymentRequestDateLabel(
                                  context,
                                ),
                                value: _formatExpenseDate(
                                  context,
                                  payment.createdAt ?? payment.paymentDate,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _sharedExpensePaymentRequestedByLabel(
                                context,
                                payment.createdByName,
                              ),
                              textAlign: TextAlign.right,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: <Widget>[
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    _handleAdminSharedExpensePaymentAction(
                                      context,
                                      ref,
                                      payment,
                                      _SharedExpensePaymentAdminAction.validate,
                                    ),
                                icon: const Icon(Icons.check_rounded),
                                label: Text(context.l10n.paymentAdminValidate),
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _handleAdminSharedExpensePaymentAction(
                                      context,
                                      ref,
                                      payment,
                                      _SharedExpensePaymentAdminAction.reject,
                                    ),
                                icon: const Icon(Icons.close_rounded),
                                label: Text(context.l10n.paymentAdminReject),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _AdminExpensePaymentMeta extends StatelessWidget {
  const _AdminExpensePaymentMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

enum _SharedExpensePaymentAdminAction { validate, reject }

enum _ExpenseAdminAction { approve, reject }

class _ExpenseLoadingState extends StatelessWidget {
  const _ExpenseLoadingState({required this.layout});

  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _LoadingBlock(height: 116),
        SizedBox(height: layout.sectionSpacing),
        const _LoadingBlock(height: 102),
        SizedBox(height: layout.sectionSpacing),
        Wrap(
          spacing: layout.itemSpacing,
          runSpacing: layout.itemSpacing,
          children: List<Widget>.generate(
            layout.isMobile ? 3 : 4,
            (_) => SizedBox(
              width: _expenseCardWidth(layout),
              child: const _LoadingBlock(height: 210),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
          ],
        ),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ExpenseErrorState extends StatelessWidget {
  const _ExpenseErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.error_outline_rounded, size: 34, color: colorScheme.error),
          const SizedBox(height: 14),
          Text(
            context.l10n.expenseErrorTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.authRetryButton),
          ),
        ],
      ),
    );
  }
}

class _ExpenseEmptyState extends StatelessWidget {
  const _ExpenseEmptyState({this.title, required this.body});

  final String? title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.inventory_2_outlined,
            size: 34,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            title ?? context.l10n.expenseEmptyTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }
}

class _PendingExpenseSegmentLabel extends StatelessWidget {
  const _PendingExpenseSegmentLabel({
    required this.label,
    required this.pendingCount,
  });

  final String label;
  final int? pendingCount;

  @override
  Widget build(BuildContext context) {
    final count = pendingCount ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
        if (count > 0) ...<Widget>[
          const SizedBox(width: 4),
          Badge(
            backgroundColor: colorScheme.primary,
            textColor: colorScheme.onPrimary,
            label: Text('$count'),
          ),
        ],
      ],
    );
  }
}

String _categoryFilterSummary(
  BuildContext context,
  List<ExpenseCategory> categories,
  Set<int> selectedCategoryIds,
) {
  if (selectedCategoryIds.isEmpty ||
      selectedCategoryIds.length == categories.length) {
    return context.l10n.expenseCategoryAll;
  }

  final selectedCategories = categories
      .where((category) => selectedCategoryIds.contains(category.id))
      .toList();

  if (selectedCategories.length == 1) {
    return selectedCategories.first.name;
  }

  if (selectedCategories.length == 2) {
    return '${selectedCategories[0].name}, ${selectedCategories[1].name}';
  }

  return '${selectedCategories[0].name}, ${selectedCategories[1].name} +${selectedCategories.length - 2}';
}

double _expenseCardWidth(ResponsiveLayout layout) {
  if (layout.isDesktop || layout.isTablet) {
    return (layout.maxContentWidth - layout.itemSpacing) / 2;
  }
  return layout.maxContentWidth;
}

double _sharedExpenseProgress(double paidAmount, double totalAmount) {
  if (totalAmount <= 0) {
    return 0;
  }
  return (paidAmount / totalAmount).clamp(0.0, 1.0);
}

String _formatExpenseDate(BuildContext context, DateTime? date) {
  if (date == null) {
    return context.l10n.paymentDateUnavailable;
  }
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}

String _sharedExpensePaymentRequestDateLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Date de demande';
  }
  return 'Request date';
}

String _sharedExpensePaymentRequestedByLabel(
  BuildContext context,
  String requesterName,
) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  final prefix = locale == 'fr' ? 'Demande par :' : 'Requested by:';
  final name = requesterName.trim();
  if (name.isEmpty) {
    return prefix;
  }
  return '$prefix $name';
}

String _pendingExpensesTitle(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Depenses en attente' : 'Pending expenses';
}

String _pendingExpensesBody(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Validez ou annulez les depenses creees par les administrateurs avant leur affichage dans les listes approuvees.';
  }
  return 'Validate or cancel expenses created by administrators before they appear in the approved lists.';
}

String _pendingExpensesEmptyTitle(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Aucune depense en attente' : 'No pending expenses';
}

String _pendingExpensesEmptyBody(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Aucune depense ne necessite de validation pour le moment.';
  }
  return 'No expense currently requires validation.';
}

String _expenseTypeMetaLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Type' : 'Type';
}

String _expenseTypeLabel(BuildContext context, ExpenseType type) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return switch (type) {
    ExpenseType.cagnotte => locale == 'fr' ? 'Cagnotte' : 'Fund',
    ExpenseType.partage => locale == 'fr' ? 'Partagee' : 'Shared',
    ExpenseType.unknown => locale == 'fr' ? 'Inconnu' : 'Unknown',
  };
}

String _expenseCreatedByLabel(BuildContext context, int? createdById) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  final prefix = locale == 'fr' ? 'Creee par admin :' : 'Created by admin:';
  if (createdById == null || createdById <= 0) {
    return prefix;
  }
  return '$prefix #$createdById';
}

String _cancelExpenseActionLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Annuler' : 'Cancel';
}

String _approveExpenseConfirmTitle(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Valider cette depense ?' : 'Validate this expense?';
}

String _approveExpenseConfirmBody(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Une fois validee, la depense apparaitra dans la liste correspondante. Les depenses cagnotte mettront aussi a jour la cagnotte.';
  }
  return 'Once validated, the expense will appear in the matching list. Fund expenses will also update the residence fund.';
}

String _approveExpenseSuccessMessage(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'La depense a ete validee.'
      : 'The expense has been validated.';
}

String _rejectExpenseSuccessMessage(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'La depense a ete annulee.'
      : 'The expense has been cancelled.';
}

String _deleteSharedExpenseTooltip(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Supprimer cette depense partagee'
      : 'Delete this shared expense';
}

String _deleteSharedExpenseConfirmTitle(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Supprimer cette depense partagee ?'
      : 'Delete this shared expense?';
}

String _deleteSharedExpenseConfirmBody(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Attention, vous allez annuler une depense partagee. Tous les paiements lies a cette depense partagee seront aussi supprimes et elle n apparaitra plus dans l affichage.';
  }
  return 'Warning: you are about to cancel a shared expense. All payments linked to this shared expense will also be deleted and it will no longer appear in the UI.';
}

String _deleteSharedExpenseConfirmActionLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Supprimer' : 'Delete';
}

String _deleteSharedExpenseSuccessMessage(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'La depense partagee et ses paiements lies ont ete supprimes.'
      : 'The shared expense and its linked payments have been deleted.';
}

String _cancelSharedExpenseHousingPaymentTooltip(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Annuler le paiement de ce logement'
      : 'Cancel this housing payment';
}

String _cancelSharedExpenseHousingPaymentConfirmTitle(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Annuler ce paiement logement ?'
      : 'Cancel this housing payment?';
}

String _cancelSharedExpenseHousingPaymentConfirmBody(
  BuildContext context, {
  required String logementLabel,
}) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Vous allez annuler tous les paiements de la depense partagee pour le logement $logementLabel. Cette action supprimera les paiements enregistres pour ce logement sur cette depense partagee.';
  }
  return 'You are about to cancel all shared expense payments for housing $logementLabel. This will remove the recorded payments for this housing on this shared expense.';
}

String _cancelSharedExpenseHousingPaymentActionLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Annuler le paiement' : 'Cancel payment';
}

String _cancelSharedExpenseHousingPaymentSuccessMessage(
  BuildContext context, {
  required String logementLabel,
}) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Les paiements du logement $logementLabel ont ete annules pour cette depense partagee.';
  }
  return 'Payments for housing $logementLabel have been cancelled for this shared expense.';
}

void _refreshExpenseView(WidgetRef ref, ExpenseViewTab selectedTab) {
  if (selectedTab == ExpenseViewTab.pending) {
    ref.invalidate(adminPendingSharedExpensePaymentsProvider);
    ref.invalidate(adminPendingExpensesProvider);
  }
  ref.invalidate(expenseOverviewProvider);
}

Future<void> _handleAdminSharedExpensePaymentAction(
  BuildContext context,
  WidgetRef ref,
  SharedExpensePaymentRecord payment,
  _SharedExpensePaymentAdminAction action,
) async {
  if (action == _SharedExpensePaymentAdminAction.validate) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.paymentAdminValidateConfirmTitle),
        content: Text(context.l10n.paymentAdminValidateConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.paymentDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.paymentAdminValidate),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }
  }

  try {
    final repository = ref.read(depenseRepositoryProvider);
    if (action == _SharedExpensePaymentAdminAction.validate) {
      await repository.validateSharedExpensePayment(payment.id);
    } else {
      await repository.rejectSharedExpensePayment(payment.id);
    }

    _refreshAfterAdminSharedExpensePaymentAction(ref);

    if (context.mounted) {
      final successMessage = action == _SharedExpensePaymentAdminAction.validate
          ? context.l10n.paymentAdminValidateSuccess
          : context.l10n.paymentAdminRejectSuccess;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveExpenseErrorMessage(context, error))),
      );
    }
  }
}

Future<void> _handleAdminExpenseAction(
  BuildContext context,
  WidgetRef ref,
  ExpenseRecord expense,
  _ExpenseAdminAction action,
) async {
  if (action == _ExpenseAdminAction.approve) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_approveExpenseConfirmTitle(context)),
        content: Text(_approveExpenseConfirmBody(context)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.paymentDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.paymentAdminValidate),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }
  }

  try {
    final repository = ref.read(depenseRepositoryProvider);
    if (action == _ExpenseAdminAction.approve) {
      await repository.approveExpense(expense.id);
    } else {
      await repository.rejectExpense(expense.id);
    }

    _refreshAfterAdminExpenseAction(ref);

    if (context.mounted) {
      final successMessage = action == _ExpenseAdminAction.approve
          ? _approveExpenseSuccessMessage(context)
          : _rejectExpenseSuccessMessage(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveExpenseErrorMessage(context, error))),
      );
    }
  }
}

void _refreshAfterAdminSharedExpensePaymentAction(WidgetRef ref) {
  ref.invalidate(adminPendingSharedExpensePaymentsProvider);
  ref.invalidate(expenseOverviewProvider);
}

void _refreshAfterAdminSharedExpenseDeletion(WidgetRef ref) {
  ref.invalidate(adminPendingSharedExpensePaymentsProvider);
  ref.invalidate(expenseOverviewProvider);
}

void _refreshAfterAdminSharedExpenseHousingPaymentDeletion(WidgetRef ref) {
  ref.invalidate(adminPendingSharedExpensePaymentsProvider);
  ref.invalidate(expenseOverviewProvider);
}

void _refreshAfterAdminExpenseAction(WidgetRef ref) {
  ref.invalidate(adminPendingExpensesProvider);
  ref.invalidate(adminPendingSharedExpensePaymentsProvider);
  ref.invalidate(expenseOverviewProvider);
}

String _resolveExpenseErrorMessage(BuildContext context, Object error) {
  final exception = ApiException.fromError(error);
  return switch (exception.kind) {
    ApiExceptionKind.timeout => context.l10n.authErrorTimeout,
    ApiExceptionKind.network => context.l10n.authErrorNetwork,
    ApiExceptionKind.unauthorized => context.l10n.authErrorUnauthorized,
    ApiExceptionKind.forbidden =>
      exception.message.isEmpty
          ? context.l10n.expenseForbiddenError
          : exception.message,
    ApiExceptionKind.notFound =>
      exception.message.isEmpty
          ? context.l10n.expenseNotFoundError
          : exception.message,
    ApiExceptionKind.badRequest => exception.message,
    ApiExceptionKind.unknown => exception.message,
  };
}

String _sharedCreatorLabel(BuildContext context, ExpenseUserSummary createdBy) {
  if (createdBy.fullName.trim().isNotEmpty) {
    return createdBy.fullName.trim();
  }
  return context.l10n.expenseSharedUnknownCreator;
}

_ParticipantStatusMeta _participantStatusMeta(
  BuildContext context,
  SharedExpenseParticipantStatus status,
) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final dashboardTheme =
      theme.extension<AppDashboardTheme>() ??
      AppDashboardTheme.light(colorScheme);

  return switch (status) {
    SharedExpenseParticipantStatus.unpaid => _ParticipantStatusMeta(
      label: context.l10n.expenseSharedStatusUnpaid,
      icon: Icons.do_not_disturb_alt_rounded,
      color: colorScheme.error,
    ),
    SharedExpenseParticipantStatus.partiallyPaid => _ParticipantStatusMeta(
      label: context.l10n.expenseSharedStatusPartiallyPaid,
      icon: Icons.timelapse_rounded,
      color: dashboardTheme.warningColor,
    ),
    SharedExpenseParticipantStatus.paid => _ParticipantStatusMeta(
      label: context.l10n.expenseSharedStatusPaid,
      icon: Icons.check_circle_rounded,
      color: dashboardTheme.successColor,
    ),
    SharedExpenseParticipantStatus.unknown => _ParticipantStatusMeta(
      label: context.l10n.dashboardPaymentStatusUnknown,
      icon: Icons.help_outline_rounded,
      color: colorScheme.onSurfaceVariant,
    ),
  };
}

double? _normalizeAmount(String? rawValue) {
  if (rawValue == null) {
    return null;
  }
  final normalized = rawValue.trim().replaceAll(',', '.');
  if (normalized.isEmpty) {
    return null;
  }
  final value = double.tryParse(normalized);
  if (value == null || value <= 0) {
    return null;
  }
  return value;
}

double? _estimateSharedAmountPerPerson(double? amount, int? participantsCount) {
  if (amount == null || participantsCount == null || participantsCount <= 0) {
    return null;
  }
  return double.parse((amount / participantsCount).toStringAsFixed(2));
}

class _ParticipantStatusMeta {
  const _ParticipantStatusMeta({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

Future<void> _showCreateExpenseDialog(
  BuildContext context,
  WidgetRef ref,
  ExpenseOverview overview,
) async {
  final created = await showDialog<bool>(
    context: context,
    builder: (context) => _CreateExpenseDialog(overview: overview),
  );

  if (created == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.expenseCreateSuccess)));
  }
}

Future<void> _showCreateSharedExpenseDialog(
  BuildContext context,
  ExpenseOverview overview,
) async {
  final created = await showDialog<bool>(
    context: context,
    builder: (context) => _CreateSharedExpenseDialog(overview: overview),
  );

  if (created == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.expenseSharedCreateSuccess)),
    );
  }
}

Future<void> _showSharedExpensePaymentDialog(
  BuildContext context, {
  required SharedExpenseRecord expense,
  required SharedExpenseParticipantRecord participant,
  required String? currencyCode,
  required double suggestedAmount,
}) async {
  final created = await showDialog<bool>(
    context: context,
    builder: (context) => _SharedExpensePaymentDialog(
      expense: expense,
      participant: participant,
      currencyCode: currencyCode,
      suggestedAmount: suggestedAmount,
    ),
  );

  if (created == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_sharedExpensePaymentSuccessMessage(context))),
    );
  }
}

String _sharedExpensePaymentSuccessMessage(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  if (locale == 'fr') {
    return 'Le paiement de la depense partagee a bien ete enregistre.';
  }
  return 'The shared expense payment has been recorded.';
}

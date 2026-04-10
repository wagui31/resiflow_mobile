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
            final overviewAsync = ref.watch(expenseOverviewProvider);
            final userRole =
                ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
            final currencyCode = ref.watch(currentCurrencyCodeProvider);
            final isAdmin =
                userRole == UserRole.admin || userRole == UserRole.superAdmin;

            return ListView(
              children: <Widget>[
                GlobalPageHeader(
                  title: context.l10n.moduleExpenseTitle,
                  layout: layout,
                  residenceBalance: overviewAsync.valueOrNull?.balance.balance,
                  currencyCode: currencyCode,
                  actions: <Widget>[
                    IconButton(
                      onPressed: () => ref.invalidate(expenseOverviewProvider),
                      tooltip: context.l10n.expenseRefreshTooltip,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                SizedBox(height: layout.sectionSpacing),
                _ExpenseModeCard(layout: layout, isAdmin: isAdmin),
                SizedBox(height: layout.sectionSpacing),
                overviewAsync.when(
                  loading: () => _ExpenseLoadingState(layout: layout),
                  error: (error, _) => _ExpenseErrorState(
                    message: _resolveExpenseErrorMessage(context, error),
                    onRetry: () => ref.invalidate(expenseOverviewProvider),
                  ),
                  data: (overview) => _ExpenseCagnotteSection(
                    layout: layout,
                    overview: overview,
                    currencyCode: currencyCode,
                    isAdmin: isAdmin,
                  ),
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
  const _ExpenseModeCard({required this.layout, required this.isAdmin});

  final ResponsiveLayout layout;
  final bool isAdmin;

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
                  label: _SegmentLabel(
                    '${context.l10n.expenseModeShared} - ${context.l10n.expenseModeSoon}',
                  ),
                  enabled: false,
                ),
                if (isAdmin)
                  ButtonSegment<ExpenseViewTab>(
                    value: ExpenseViewTab.pending,
                    icon: const Icon(Icons.pending_actions_rounded),
                    label: _SegmentLabel(
                      '${context.l10n.expenseModePending} - ${context.l10n.expenseModeSoon}',
                    ),
                    enabled: false,
                  ),
              ],
              selected: <ExpenseViewTab>{selectedTab},
              onSelectionChanged: (selection) {
                final next = selection.first;
                if (next == ExpenseViewTab.cagnotte) {
                  ref.read(expenseViewTabProvider.notifier).state = next;
                }
              },
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
    final approvedCagnotteExpenses = overview.expenses
        .where(
          (expense) =>
              expense.type == ExpenseType.cagnotte &&
              expense.status == ExpenseStatus.approuvee,
        )
        .toList();
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
          const _ExpenseEmptyState()
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
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: maxDialogHeight,
        ),
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
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
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
      await ref.read(depenseRepositoryProvider).createCagnotteExpense(
        residenceId: widget.overview.balance.residenceId,
        categoryId: categoryId,
        amount: amount,
        description: _descriptionController.text.trim(),
      );
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
    final categoryName =
        expense.categoryName?.trim().isNotEmpty == true
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
          Icon(
            Icons.error_outline_rounded,
            size: 34,
            color: colorScheme.error,
          ),
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
  const _ExpenseEmptyState();

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
            context.l10n.expenseEmptyTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.expenseEmptyBody,
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

String _formatExpenseDate(BuildContext context, DateTime? date) {
  if (date == null) {
    return context.l10n.paymentDateUnavailable;
  }
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}

String _resolveExpenseErrorMessage(BuildContext context, Object error) {
  final exception = ApiException.fromError(error);
  return switch (exception.kind) {
    ApiExceptionKind.timeout => context.l10n.authErrorTimeout,
    ApiExceptionKind.network => context.l10n.authErrorNetwork,
    ApiExceptionKind.unauthorized => context.l10n.authErrorUnauthorized,
    ApiExceptionKind.forbidden => exception.message.isEmpty
        ? context.l10n.expenseForbiddenError
        : exception.message,
    ApiExceptionKind.notFound => exception.message.isEmpty
        ? context.l10n.expenseNotFoundError
        : exception.message,
    ApiExceptionKind.badRequest => exception.message,
    ApiExceptionKind.unknown => exception.message,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.expenseCreateSuccess)),
    );
  }
}

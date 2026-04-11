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
                  data: (overview) {
                    final selectedTab = ref.watch(expenseViewTabProvider);
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
                  label: _SegmentLabel(context.l10n.expenseModeShared),
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
                if (next == ExpenseViewTab.cagnotte ||
                    next == ExpenseViewTab.shared) {
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
                          onPressed: () => _showCreateSharedExpenseDialog(
                            context,
                            overview,
                          ),
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
            children: overview.sharedExpenses
                .map(
                  (expense) => Padding(
                    padding: EdgeInsets.only(bottom: layout.itemSpacing),
                    child: _SharedExpenseCard(
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
        constraints: BoxConstraints(
          maxWidth: 460,
          maxHeight: maxDialogHeight,
        ),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
            message: 'Aucun participant actif n est disponible pour cette residence.',
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
      await ref.read(depenseRepositoryProvider).createSharedExpense(
        residenceId: widget.overview.balance.residenceId,
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

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        enabled: false,
      ),
      child: isLoading
          ? const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
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

class _SharedExpenseCard extends StatefulWidget {
  const _SharedExpenseCard({
    required this.expense,
    required this.currencyCode,
  });

  final SharedExpenseRecord expense;
  final String? currencyCode;

  @override
  State<_SharedExpenseCard> createState() => _SharedExpenseCardState();
}

class _SharedExpenseCardState extends State<_SharedExpenseCard> {
  bool _expanded = false;

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
    final totalLabel = _sharedExpenseTotalLabel(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      totalLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalAmountLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: dashboardTheme.successColor,
                      ),
                    ),
                  ],
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
          const SizedBox(height: 14),
          Text(
            widget.expense.description,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          _SharedExpenseProgressBar(
            progress: progress,
            paidAmountLabel: paidAmountLabel,
            totalAmountLabel: totalAmountLabel,
            progressColor: dashboardTheme.successColor,
            trackColor: colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              _ExpenseMetaItem(
                label: context.l10n.expenseCreatedAtLabel,
                value: _formatExpenseDate(context, widget.expense.createdAt),
              ),
              _ExpenseMetaItem(
                label: context.l10n.expenseValidatedAtLabel,
                value: _formatExpenseDate(context, widget.expense.validatedAt),
              ),
              _ExpenseMetaItem(
                label: context.l10n.expenseSharedRemainingResidentsLabel,
                value: widget.expense.remainingParticipantsCount.toString(),
                alignment: CrossAxisAlignment.end,
                valueColor: dashboardTheme.warningColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.expenseSharedCreatedBy(
              _sharedCreatorLabel(context, widget.expense.createdBy),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
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
                    context.l10n.expenseSharedParticipantsCount(
                      widget.expense.participants.length,
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
}

class _SharedExpenseParticipantRow extends StatelessWidget {
  const _SharedExpenseParticipantRow({
    required this.participant,
    required this.currencyCode,
  });

  final SharedExpenseParticipantRecord participant;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusMeta = _participantStatusMeta(context, participant.status);

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
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180, maxWidth: 360),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  participant.fullName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.expenseSharedParticipantAmountSummary(
                    CurrencyFormatter.format(
                      context,
                      participant.amountPaid,
                      currencyCode: currencyCode,
                    ),
                    CurrencyFormatter.format(
                      context,
                      participant.amountDue,
                      currencyCode: currencyCode,
                    ),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusMeta.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(statusMeta.icon, size: 18, color: statusMeta.color),
                const SizedBox(width: 8),
                Text(
                  statusMeta.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: statusMeta.color,
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

class _ExpenseMetaItem extends StatelessWidget {
  const _ExpenseMetaItem({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
    this.valueColor,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: alignment,
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
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _SharedExpenseProgressBar extends StatelessWidget {
  const _SharedExpenseProgressBar({
    required this.progress,
    required this.paidAmountLabel,
    required this.totalAmountLabel,
    required this.progressColor,
    required this.trackColor,
  });

  final double progress;
  final String paidAmountLabel;
  final String totalAmountLabel;
  final Color progressColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = progress >= 0.999;
    final showPaidOutside = progress > 0 && progress < 0.28;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final fillWidth = trackWidth * progress;

        return SizedBox(
          height: 28,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 28,
                decoration: BoxDecoration(
                  color: trackColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: fillWidth,
                height: 28,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: !showPaidOutside && progress > 0
                    ? Text(
                        paidAmountLabel,
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
                      color: progressColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (!isComplete)
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
  const _ExpenseEmptyState({
    required this.body,
  });

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
            context.l10n.expenseEmptyTitle,
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

String _sharedExpenseTotalLabel(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'fr'
      ? 'Total'
      : 'Total';
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

String _sharedCreatorLabel(
  BuildContext context,
  ExpenseUserSummary createdBy,
) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.expenseCreateSuccess)),
    );
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

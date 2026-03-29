// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ResiFlow';

  @override
  String get dashboardTitle => 'Mobile architecture';

  @override
  String get dashboardSubtitle => 'Flutter feature-based foundation aligned with the project context: Riverpod, Dio, go_router, and a clear core/features split.';

  @override
  String get moduleAuthTitle => 'Authentication';

  @override
  String get moduleAuthDescription => 'Auth module structure.';

  @override
  String get moduleAuthScreenDescription => 'Entry area for sign-in and sign-up flows, with no business logic implemented at this stage.';

  @override
  String get modulePaymentTitle => 'Payment';

  @override
  String get modulePaymentDescription => 'Payment module foundation.';

  @override
  String get modulePaymentScreenDescription => 'Entry point for the payment module. API integrations will only be wired to existing backend endpoints in the relevant tasks.';

  @override
  String get moduleExpenseTitle => 'Expense';

  @override
  String get moduleExpenseDescription => 'Expense module foundation.';

  @override
  String get moduleExpenseScreenDescription => 'Entry point for the expense module. Application logic is intentionally absent at this stage.';

  @override
  String get moduleVoteTitle => 'Vote';

  @override
  String get moduleVoteDescription => 'Vote module foundation.';

  @override
  String get moduleVoteScreenDescription => 'Entry point for the vote module, with a UI skeleton meant only to validate the architecture.';

  @override
  String get moduleResidenceTitle => 'Residence';

  @override
  String get moduleResidenceDescription => 'Residence module foundation.';

  @override
  String get moduleResidenceScreenDescription => 'Entry point for the residence module. Future screens will rely on the real backend API without shifting business logic to the frontend.';

  @override
  String get languageSwitcherTooltip => 'Change language';

  @override
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';
}

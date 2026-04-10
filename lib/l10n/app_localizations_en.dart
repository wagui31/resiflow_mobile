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
  String get dashboardTitle => 'Home';

  @override
  String get dashboardSubtitle =>
      'A clear, useful view connected to your residence real backend data.';

  @override
  String dashboardGreeting(String name) {
    return 'Hello $name';
  }

  @override
  String get dashboardGreetingGeneric => 'Hello';

  @override
  String dashboardWelcomeResidence(String residenceName) {
    return 'Here is what matters in $residenceName today.';
  }

  @override
  String get dashboardWelcomeResidenceFallback =>
      'Here is what matters in your residence today.';

  @override
  String dashboardWelcomeResidenceCompact(String residenceName) {
    return 'Here is what matters in residence $residenceName today';
  }

  @override
  String get dashboardWelcomeResidenceCompactFallback =>
      'Here is what matters in your residence today';

  @override
  String get dashboardMetaResidenceCode => 'Residence code';

  @override
  String get dashboardMetaPaymentStatus => 'Payment status';

  @override
  String get dashboardPaymentStatusUpToDate => 'Up to date';

  @override
  String get dashboardPaymentStatusLate => 'Late';

  @override
  String get dashboardPaymentStatusUnknown => 'Unknown';

  @override
  String get dashboardPaymentStatusTooltipUpToDate =>
      'Payment status up to date';

  @override
  String get dashboardPaymentStatusTooltipLate => 'Payment status late';

  @override
  String get dashboardPaymentStatusTooltipUnknown =>
      'Payment status unavailable';

  @override
  String get dashboardChartTitle => 'Fund evolution';

  @override
  String get dashboardChartSubtitle =>
      'Cumulative balance month by month from backend transactions.';

  @override
  String get dashboardChartLegendCurrent => 'Balance';

  @override
  String get dashboardChartEmpty =>
      'Not enough data yet to display the evolution.';

  @override
  String get dashboardChartEmptyNoData =>
      'No transactions are available yet to display an evolution.';

  @override
  String get dashboardChartSinglePointTitle =>
      'Only one period is available so far.';

  @override
  String dashboardChartSinglePointBody(String month, String balance) {
    return 'Latest known balance for $month: $balance. The chart will appear once multiple periods are available.';
  }

  @override
  String get dashboardCardBalance => 'Current balance';

  @override
  String get dashboardCardContributions => 'Total contributions';

  @override
  String get dashboardCardExpenses => 'Total expenses';

  @override
  String get dashboardCardLateResidents => 'Late residents';

  @override
  String get dashboardCardResidents => 'Residents';

  @override
  String get dashboardActionsTitle => 'Quick access';

  @override
  String get dashboardActionsSubtitle =>
      'Shortcuts to the modules connected to the budget and residence.';

  @override
  String get dashboardActivityTitle => 'Recent votes';

  @override
  String get dashboardActivitySubtitle =>
      'Latest votes exposed by the backend.';

  @override
  String get dashboardActivityEmpty => 'No recent votes available.';

  @override
  String get dashboardEstimatedAmount => 'Estimated amount';

  @override
  String get dashboardErrorTitle => 'Unable to load the dashboard.';

  @override
  String get headerResidenceBalanceLabel => 'Residence balance:';

  @override
  String get dashboardVoteStatusOpen => 'Open';

  @override
  String get dashboardVoteStatusValidated => 'Validated';

  @override
  String get dashboardVoteStatusRejected => 'Rejected';

  @override
  String get moduleAuthTitle => 'Authentication';

  @override
  String get moduleAuthDescription => 'Auth module structure.';

  @override
  String get moduleAuthScreenDescription =>
      'Entry area for sign-in and sign-up flows, with no business logic implemented at this stage.';

  @override
  String get authHeroEyebrow => 'Residence access';

  @override
  String get authHeroTitle => 'A clean entry point for every residence.';

  @override
  String get authHeroDescription =>
      'Sign in with your existing account or request access with your residence code. The frontend only consumes the real backend contract.';

  @override
  String get landingBadge => 'Neighbors, budget and payments';

  @override
  String get landingTitle => 'Residence life, clear from the first screen.';

  @override
  String get landingDescription =>
      'Access your condominium space through a simple welcome screen built around neighbor interactions, shared management, the residence fund and payments.';

  @override
  String get landingFeatureNeighbors => 'Neighbor connections';

  @override
  String get landingFeatureSharedManagement => 'Shared management';

  @override
  String get landingFeatureCagnotte => 'Residence fund';

  @override
  String get landingFeaturePayments => 'Simplified payments';

  @override
  String get landingCtaTitle => 'Access your residence';

  @override
  String get landingCtaDescription =>
      'Sign in to return to your space, or register with your residence code to submit an access request.';

  @override
  String get landingLoginPrompt => 'Already have an account?';

  @override
  String get landingLoginButton => 'Sign in';

  @override
  String get landingRegisterButton => 'Register';

  @override
  String get authFeatureResidenceCode => 'Residence code required';

  @override
  String get authFeatureAdminValidation => 'Admin validation workflow';

  @override
  String get authFeatureSecureAccess => 'JWT + protected profile';

  @override
  String get authSignInTab => 'Sign in';

  @override
  String get authSignUpTab => 'Register';

  @override
  String get authLoginPageTitle => 'Sign in';

  @override
  String get authSignInHeading => 'Connect to your residence';

  @override
  String get authSignInDescription =>
      'Use the credentials already validated by the backend.';

  @override
  String get authSignUpHeading => 'Request access';

  @override
  String get authSignUpDescription =>
      'Create a resident account linked to a residence. Approval remains handled by the backend admin workflow.';

  @override
  String get authNoAccountPrompt => 'No account?';

  @override
  String get authAlreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get authRegisterLinkLabel => 'Register';

  @override
  String get authBackToLogin => 'Back to sign in';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authResidenceCodeLabel => 'Residence code';

  @override
  String get authResidenceCodeHelp =>
      'This code is provided by your residence administrator';

  @override
  String get authBuildingLabel => 'Building';

  @override
  String get authHousingLabel => 'Housing';

  @override
  String get authCaptchaLabel => 'Security check';

  @override
  String get authCaptchaDescription =>
      'Complete the Turnstile challenge before creating your account.';

  @override
  String get authCaptchaMissingSiteKey =>
      'Captcha is enabled on the backend, but the public site key is missing from app-config.';

  @override
  String get authCaptchaPending =>
      'Complete the captcha challenge to continue.';

  @override
  String get authCaptchaReady =>
      'Captcha verified. You can submit the registration form.';

  @override
  String get authLoadingConfig => 'Loading public application configuration...';

  @override
  String get authConfigErrorTitle =>
      'Unable to load registration configuration';

  @override
  String get authRetryButton => 'Retry';

  @override
  String get authSubmittingLabel => 'Please wait...';

  @override
  String get authLoginButton => 'Sign in';

  @override
  String get authLogoutButton => 'Sign out';

  @override
  String get authRegisterButton => 'Create request';

  @override
  String get authRegisterCta => 'Register';

  @override
  String get authRequiredFieldsMessage =>
      'Fill in all required fields before continuing.';

  @override
  String get authInvalidEmailMessage => 'Please enter a valid email address.';

  @override
  String get authErrorTechnical =>
      'A technical error occurred. Please try again.';

  @override
  String get authErrorNetwork =>
      'Unable to reach the server. Check your connection.';

  @override
  String get authErrorTimeout =>
      'The server is taking too long to respond. Please try again.';

  @override
  String get authErrorInvalidCredentials => 'Invalid email or password.';

  @override
  String get authErrorAccountPending =>
      'Your account is pending validation by a residence administrator.';

  @override
  String get authErrorAccountRejected =>
      'Your access request was rejected. Contact a residence administrator if needed.';

  @override
  String get authErrorEmailAlreadyUsed =>
      'This email address is already in use.';

  @override
  String get authErrorInvalidResidenceCode => 'The residence code is invalid.';

  @override
  String get authErrorInvalidCaptcha =>
      'The security verification failed. Please try again.';

  @override
  String get authErrorInvalidRequest =>
      'The submitted information is invalid. Check the form and try again.';

  @override
  String get authErrorUnauthorized =>
      'Authentication is required. Please sign in again.';

  @override
  String get authPasswordMismatchMessage => 'Passwords do not match.';

  @override
  String get authLoginSuccess =>
      'Authentication successful. Your profile has been loaded from the backend.';

  @override
  String get authRegisterPageTitle => 'Register';

  @override
  String get authRegisterSuccessTitle => 'Your account has been created';

  @override
  String get authRegisterSuccessPending =>
      'Your request has been created. An administrator must validate your account before you can sign in.';

  @override
  String get authRegisterSuccessGeneric =>
      'Registration request sent successfully.';

  @override
  String get authCurrentUserTitle => 'Current backend profile';

  @override
  String get authRoleLabel => 'Role';

  @override
  String get authStatusLabel => 'Status';

  @override
  String get authResidenceLabel => 'Residence';

  @override
  String get authRoleSuperAdmin => 'Super admin';

  @override
  String get authRoleAdmin => 'Admin';

  @override
  String get authRoleUser => 'Resident';

  @override
  String get authStatusPending => 'Pending validation';

  @override
  String get authStatusActive => 'Active';

  @override
  String get authStatusRejected => 'Rejected';

  @override
  String get sessionLoadingTitle => 'Checking your session...';

  @override
  String get accountStatusRejectedDescription =>
      'Your access is currently rejected. Contact a residence administrator if you believe this is a mistake.';

  @override
  String get accountStatusBackToLanding => 'Back to landing';

  @override
  String get modulePaymentTitle => 'Payment';

  @override
  String get modulePaymentDescription => 'Payment module foundation.';

  @override
  String get modulePaymentScreenDescription =>
      'Entry point for the payment module. API integrations will only be wired to existing backend endpoints in the relevant tasks.';

  @override
  String get paymentModeSelectorLabel => 'View';

  @override
  String get paymentModeSelectorDescription =>
      'Choose which payments to consult from this single screen.';

  @override
  String get paymentModeMine => 'Payments';

  @override
  String get paymentModeResident => 'Resident';

  @override
  String get paymentModePending => 'Pending';

  @override
  String get paymentResidentSearchTitle => 'Consult a resident';

  @override
  String get paymentResidentSearchBody =>
      'Search for a resident in your residence by email to load the same payment tracking.';

  @override
  String get paymentResidentEmailLabel => 'Resident email';

  @override
  String get paymentResidentSearchButton => 'Search';

  @override
  String get paymentResidentSearchHint =>
      'Enter an email address, then run the search.';

  @override
  String get paymentResidentEmptyTitle => 'No search started';

  @override
  String get paymentResidentEmptyBody =>
      'Enter a resident email to display status, pending payment, monthly tracking and history.';

  @override
  String paymentResidentViewing(String email) {
    return 'Viewing resident $email';
  }

  @override
  String get paymentResidentViewingDescription =>
      'The displayed data belongs to the searched resident.';

  @override
  String get paymentResidentForbiddenError =>
      'Access to this resident is forbidden.';

  @override
  String get paymentStatusOverdue => 'Late';

  @override
  String get paymentStatusUpToDate => 'Up to date';

  @override
  String get paymentStatusUnknown => 'Unavailable';

  @override
  String get paymentHeroLateTitle => 'Payment is overdue';

  @override
  String paymentHeroLateBody(String date) {
    return 'Your payment has expired since $date.';
  }

  @override
  String get paymentHeroHealthyTitle => 'Payment status looks healthy';

  @override
  String paymentHeroHealthyBody(String date) {
    return 'You are up to date until $date.';
  }

  @override
  String get paymentHeroFallbackBody => 'Payment status is not available yet.';

  @override
  String get paymentDueSoon => 'Your payment is approaching its due date.';

  @override
  String get paymentPrimaryAction => 'Start a payment';

  @override
  String get paymentPendingLocksCreation =>
      'A payment is already pending. You cannot start another one until it has been processed.';

  @override
  String get paymentPendingTitle => 'Pending payment';

  @override
  String get paymentPendingBody =>
      'This payment is still waiting for validation from a residence administrator.';

  @override
  String get paymentPendingAmount => 'Amount';

  @override
  String get paymentPendingPeriod => 'Period';

  @override
  String get paymentPendingMonths => 'Number of months';

  @override
  String paymentPendingMonthsValue(int count) {
    return '$count months';
  }

  @override
  String get paymentPendingHint =>
      'Please have this payment validated by a residence administrator.';

  @override
  String get paymentPendingSelfHint =>
      'This payment will also appear in the pending payments list so you can validate it yourself.';

  @override
  String get paymentPendingEmptyTitle => 'No pending payment';

  @override
  String get paymentPendingEmptyBody =>
      'You can start a new payment as soon as a new period needs to be covered.';

  @override
  String get paymentDeletePending => 'Delete';

  @override
  String get paymentDeleteConfirmTitle => 'Delete the pending payment?';

  @override
  String get paymentDeleteConfirmBody =>
      'This action only removes the payment that is still waiting for validation.';

  @override
  String get paymentDeleteSuccess => 'The pending payment has been deleted.';

  @override
  String get paymentTimelineTitle => 'Monthly tracking';

  @override
  String get paymentTimelineBody =>
      'Unpaid months appear first. If everything is settled, the last three paid months stay visible.';

  @override
  String get paymentTimelineEmptyTitle => 'No months to display';

  @override
  String get paymentTimelineEmptyBody =>
      'The backend did not return any month tracking yet.';

  @override
  String get paymentTimelineShowMore => 'Show more';

  @override
  String paymentTimelineTooManyUnpaid(int count) {
    return 'You have a total of $count unpaid months';
  }

  @override
  String get paymentMonthPaid => 'Paid';

  @override
  String get paymentMonthUnpaid => 'Unpaid';

  @override
  String get paymentHistoryTitle => 'History';

  @override
  String get paymentHistoryBody =>
      'Review the latest validated payments and their covered period.';

  @override
  String get paymentHistoryEmptyTitle => 'No history available';

  @override
  String get paymentHistoryEmptyBody =>
      'Validated payments will appear here once they have been confirmed.';

  @override
  String get paymentDialogTitle => 'Start a payment';

  @override
  String get paymentDialogBody =>
      'Choose a start month and how many months to pay. The backend will validate overlaps before creating the payment.';

  @override
  String paymentDialogBodyForResident(String email) {
    return 'You are about to start a payment for resident $email. Choose a start month and how many months to pay. The backend will validate overlaps before creating the payment.';
  }

  @override
  String get paymentDialogStartMonth => 'Start month';

  @override
  String get paymentDialogMonthCount => 'Number of months';

  @override
  String paymentDialogMonthCountValue(int count) {
    return '$count months';
  }

  @override
  String get paymentDialogCancel => 'Cancel';

  @override
  String get paymentDialogSubmit => 'Confirm request';

  @override
  String get paymentCreateSuccess =>
      'The payment has been created and is now waiting for validation.';

  @override
  String paymentCreateSuccessForResident(String email) {
    return 'The payment for $email has been created and is now waiting for validation.';
  }

  @override
  String get paymentErrorTitle => 'Unable to load the payment view.';

  @override
  String get paymentNotFoundError =>
      'The requested payment could not be found.';

  @override
  String get paymentDateUnavailable => 'Date unavailable';

  @override
  String get paymentRefreshTooltip => 'Refresh the payment page';

  @override
  String get paymentAdminPendingTitle => 'Pending payments';

  @override
  String get paymentAdminPendingBody =>
      'Review and process payment requests that are still waiting for validation.';

  @override
  String get paymentAdminPendingEmptyTitle => 'No pending payments';

  @override
  String get paymentAdminPendingEmptyBody =>
      'New requests will appear here as soon as they are created.';

  @override
  String get paymentAdminResidentEmail => 'User';

  @override
  String get paymentAdminPeriod => 'Period';

  @override
  String get paymentAdminStatusPending => 'PENDING';

  @override
  String get paymentAdminValidate => 'Validate';

  @override
  String get paymentAdminReject => 'Reject';

  @override
  String get paymentAdminValidateConfirmTitle => 'Validate this payment?';

  @override
  String get paymentAdminValidateConfirmBody =>
      'Do you confirm that you have collected this payment? This action will update the residence fund.';

  @override
  String get paymentAdminValidateSuccess => 'The payment has been validated.';

  @override
  String get paymentAdminRejectSuccess => 'The payment has been rejected.';

  @override
  String get moduleExpenseTitle => 'Expense';

  @override
  String get moduleExpenseDescription => 'Expense module foundation.';

  @override
  String get moduleExpenseScreenDescription =>
      'Expense view connected to the residence real backend endpoints.';

  @override
  String get expenseModeSelectorLabel => 'Expense types';

  @override
  String get expenseModeSelectorDescription =>
      'Review fund-backed expenses here. The other tabs will stay available later.';

  @override
  String get expenseModeCagnotte => 'Fund';

  @override
  String get expenseModeShared => 'Shared';

  @override
  String get expenseModePending => 'Pending';

  @override
  String get expenseModeSoon => 'Soon';

  @override
  String get expenseCagnotteTitle => 'Approved fund expenses';

  @override
  String get expenseCagnotteDescription =>
      'Review the expenses already validated and funded by the residence pot, with a quick category filter.';

  @override
  String get expenseCategoryFilterLabel => 'Filter by category';

  @override
  String get expenseCategoryAll => 'All categories';

  @override
  String get expenseCategoryUnknown => 'Unspecified category';

  @override
  String get expenseCreatedAtLabel => 'Created';

  @override
  String get expenseValidatedAtLabel => 'Validated';

  @override
  String get expenseEmptyTitle => 'No expenses available';

  @override
  String get expenseEmptyBody => 'No approved fund expense is available.';

  @override
  String get expenseErrorTitle => 'Unable to load the expense view.';

  @override
  String get expenseForbiddenError =>
      'Access to this residence expenses is forbidden.';

  @override
  String get expenseNotFoundError =>
      'The requested expense resource could not be found.';

  @override
  String get expenseRefreshTooltip => 'Refresh the expense page';

  @override
  String get expenseCreateAction => 'Create an expense';

  @override
  String get expenseCreateDialogTitle => 'New fund expense';

  @override
  String get expenseCreateDialogBody =>
      'Provide the category, amount, and a description. The expense will be created as pending.';

  @override
  String get expenseCreateCategoryLabel => 'Category';

  @override
  String get expenseCreateCategoryError => 'Select a category.';

  @override
  String get expenseCreateAmountLabel => 'Amount';

  @override
  String get expenseCreateAmountError => 'Enter a valid amount.';

  @override
  String get expenseCreateDescriptionLabel => 'Description';

  @override
  String get expenseCreateDescriptionError => 'Enter a description.';

  @override
  String get expenseCreateSubmit => 'Create expense';

  @override
  String get expenseCreateSuccess =>
      'The expense has been created as pending.';

  @override
  String get moduleVoteTitle => 'Vote';

  @override
  String get moduleVoteDescription => 'Vote module foundation.';

  @override
  String get moduleVoteScreenDescription =>
      'Entry point for the vote module, with a UI skeleton meant only to validate the architecture.';

  @override
  String get moduleSettingsTitle => 'Users';

  @override
  String get moduleSettingsDescription => 'Access the residence residents.';

  @override
  String get moduleSettingsScreenDescription =>
      'Entry point for the users module.';

  @override
  String get moduleUsersAdminTitle => 'Resident management';

  @override
  String get moduleUsersAdminDescription =>
      'Administrators can manage residence residents.';

  @override
  String get moduleUsersAdminBody =>
      'Review residents, track their status, and host future administration actions here without changing the backend contract.';

  @override
  String get moduleUsersUserTitle => 'Resident directory';

  @override
  String get moduleUsersUserDescription =>
      'Users can consult the residence residents.';

  @override
  String get moduleUsersUserBody =>
      'Browse the resident list and useful residence information from a single entry point.';

  @override
  String get usersRefreshTooltip => 'Refresh the residents view';

  @override
  String get usersEditProfileAction => 'Edit my profile';

  @override
  String get usersAdminViewLabel => 'Admin view';

  @override
  String get usersResidentsTab => 'Residents';

  @override
  String get usersPendingTab => 'Pending';

  @override
  String get usersSearchLabel => 'Search by email';

  @override
  String get usersSearchHint => 'Filter residents by email';

  @override
  String get usersLoadErrorTitle => 'Unable to load residents.';

  @override
  String get usersResidentsEmptyTitle => 'No residents to display';

  @override
  String get usersResidentsEmptyBody =>
      'No active resident matches the current search.';

  @override
  String get usersPendingEmptyTitle => 'No pending accounts';

  @override
  String get usersPendingEmptyBody =>
      'New registration requests will appear here as soon as they are created.';

  @override
  String get usersCurrentSectionTitle => 'You right now';

  @override
  String get usersAdminsSectionTitle => 'Admins';

  @override
  String get usersLateSectionTitle => 'Late residents';

  @override
  String get usersOthersSectionTitle => 'Other residents';

  @override
  String get usersResidenceEntryDateLabel => 'Residence entry date';

  @override
  String get usersActionsTooltip => 'Resident actions';

  @override
  String get usersEditDateAction => 'Edit entry date';

  @override
  String get usersPromoteToAdminAction => 'Promote to admin';

  @override
  String get usersDemoteToUserAction => 'Set as resident';

  @override
  String get usersDeleteAction => 'Delete';

  @override
  String get usersPendingCardBody =>
      'This account is still waiting for validation from a residence administrator.';

  @override
  String get usersCreatedAtLabel => 'Created on';

  @override
  String get usersApproveAction => 'Approve';

  @override
  String get usersRejectAction => 'Reject';

  @override
  String get usersApproveConfirmTitle => 'Approve this user?';

  @override
  String get usersApproveConfirmBody =>
      'Do you confirm the validation of this user?';

  @override
  String get usersApproveSuccess => 'The user has been approved.';

  @override
  String get usersRejectSuccess => 'The user has been rejected.';

  @override
  String get usersDeleteConfirmTitle => 'Delete this user?';

  @override
  String usersDeleteConfirmBody(String email) {
    return 'Account $email will be removed from the residence.';
  }

  @override
  String get usersDeleteSuccess => 'The user has been deleted.';

  @override
  String get usersRoleChangeConfirmTitle => 'Change this user role?';

  @override
  String usersRoleChangeConfirmBody(String email, String roleLabel) {
    return '$email will be assigned the $roleLabel role.';
  }

  @override
  String get usersRoleUpdatedSuccess => 'The user role has been updated.';

  @override
  String get usersEditProfileDialogTitle => 'Edit my profile';

  @override
  String get usersFirstNameLabel => 'First name';

  @override
  String get usersLastNameLabel => 'Last name';

  @override
  String get usersSaveAction => 'Save';

  @override
  String get usersProfileUpdatedSuccess => 'The profile has been updated.';

  @override
  String get usersDateUpdatedSuccess =>
      'The residence entry date has been updated.';

  @override
  String get moduleResidenceTitle => 'Residence';

  @override
  String get moduleResidenceDescription => 'Residence module foundation.';

  @override
  String get moduleResidenceScreenDescription =>
      'Entry point for the residence module. Future screens will rely on the real backend API without shifting business logic to the frontend.';

  @override
  String get languageSwitcherTooltip => 'Change language';

  @override
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';
}

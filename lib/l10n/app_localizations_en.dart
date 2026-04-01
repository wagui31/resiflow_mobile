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
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardSubtitle => 'A clear, useful view connected to your residence real backend data.';

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
  String get dashboardWelcomeResidenceFallback => 'Here is what matters in your residence today.';

  @override
  String dashboardWelcomeResidenceCompact(String residenceName) {
    return 'Here is what matters in residence $residenceName today';
  }

  @override
  String get dashboardWelcomeResidenceCompactFallback => 'Here is what matters in your residence today';

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
  String get dashboardPaymentStatusTooltipUpToDate => 'Payment status up to date';

  @override
  String get dashboardPaymentStatusTooltipLate => 'Payment status late';

  @override
  String get dashboardPaymentStatusTooltipUnknown => 'Payment status unavailable';

  @override
  String get dashboardChartTitle => 'Fund evolution';

  @override
  String get dashboardChartSubtitle => 'Cumulative balance month by month from backend transactions.';

  @override
  String get dashboardChartLegendCurrent => 'Balance';

  @override
  String get dashboardChartEmpty => 'Not enough data yet to display the evolution.';

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
  String get dashboardActionsSubtitle => 'Shortcuts to the modules connected to the budget and residence.';

  @override
  String get dashboardActivityTitle => 'Recent votes';

  @override
  String get dashboardActivitySubtitle => 'Latest votes exposed by the backend.';

  @override
  String get dashboardActivityEmpty => 'No recent votes available.';

  @override
  String get dashboardEstimatedAmount => 'Estimated amount';

  @override
  String get dashboardErrorTitle => 'Unable to load the dashboard.';

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
  String get moduleAuthScreenDescription => 'Entry area for sign-in and sign-up flows, with no business logic implemented at this stage.';

  @override
  String get authHeroEyebrow => 'Residence access';

  @override
  String get authHeroTitle => 'A clean entry point for every residence.';

  @override
  String get authHeroDescription => 'Sign in with your existing account or request access with your residence code. The frontend only consumes the real backend contract.';

  @override
  String get landingBadge => 'Neighbors, budget and payments';

  @override
  String get landingTitle => 'Residence life, clear from the first screen.';

  @override
  String get landingDescription => 'Access your condominium space through a simple welcome screen built around neighbor interactions, shared management, the residence fund and payments.';

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
  String get landingCtaDescription => 'Sign in to return to your space, or register with your residence code to submit an access request.';

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
  String get authSignInDescription => 'Use the credentials already validated by the backend.';

  @override
  String get authSignUpHeading => 'Request access';

  @override
  String get authSignUpDescription => 'Create a resident account linked to a residence. Approval remains handled by the backend admin workflow.';

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
  String get authResidenceCodeHelp => 'This code is provided by your residence administrator';

  @override
  String get authBuildingLabel => 'Building';

  @override
  String get authHousingLabel => 'Housing';

  @override
  String get authCaptchaLabel => 'Security check';

  @override
  String get authCaptchaDescription => 'Complete the Turnstile challenge before creating your account.';

  @override
  String get authCaptchaMissingSiteKey => 'Captcha is enabled on the backend, but the public site key is missing from app-config.';

  @override
  String get authCaptchaPending => 'Complete the captcha challenge to continue.';

  @override
  String get authCaptchaReady => 'Captcha verified. You can submit the registration form.';

  @override
  String get authLoadingConfig => 'Loading public application configuration...';

  @override
  String get authConfigErrorTitle => 'Unable to load registration configuration';

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
  String get authRequiredFieldsMessage => 'Fill in all required fields before continuing.';

  @override
  String get authInvalidEmailMessage => 'Please enter a valid email address.';

  @override
  String get authErrorTechnical => 'A technical error occurred. Please try again.';

  @override
  String get authErrorNetwork => 'Unable to reach the server. Check your connection.';

  @override
  String get authErrorTimeout => 'The server is taking too long to respond. Please try again.';

  @override
  String get authErrorInvalidCredentials => 'Invalid email or password.';

  @override
  String get authErrorAccountPending => 'Your account is pending validation by a residence administrator.';

  @override
  String get authErrorAccountRejected => 'Your access request was rejected. Contact a residence administrator if needed.';

  @override
  String get authErrorEmailAlreadyUsed => 'This email address is already in use.';

  @override
  String get authErrorInvalidResidenceCode => 'The residence code is invalid.';

  @override
  String get authErrorInvalidCaptcha => 'The security verification failed. Please try again.';

  @override
  String get authErrorInvalidRequest => 'The submitted information is invalid. Check the form and try again.';

  @override
  String get authErrorUnauthorized => 'Authentication is required. Please sign in again.';

  @override
  String get authPasswordMismatchMessage => 'Passwords do not match.';

  @override
  String get authLoginSuccess => 'Authentication successful. Your profile has been loaded from the backend.';

  @override
  String get authRegisterPageTitle => 'Register';

  @override
  String get authRegisterSuccessTitle => 'Your account has been created';

  @override
  String get authRegisterSuccessPending => 'Your request has been created. An administrator must validate your account before you can sign in.';

  @override
  String get authRegisterSuccessGeneric => 'Registration request sent successfully.';

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
  String get accountStatusRejectedDescription => 'Your access is currently rejected. Contact a residence administrator if you believe this is a mistake.';

  @override
  String get accountStatusBackToLanding => 'Back to landing';

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

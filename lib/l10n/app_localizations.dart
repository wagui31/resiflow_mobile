import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ResiFlow'**
  String get appName;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A clear, useful view connected to your residence real backend data.'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}'**
  String dashboardGreeting(String name);

  /// No description provided for @dashboardGreetingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get dashboardGreetingGeneric;

  /// No description provided for @dashboardWelcomeResidence.
  ///
  /// In en, this message translates to:
  /// **'Here is what matters in {residenceName} today.'**
  String dashboardWelcomeResidence(String residenceName);

  /// No description provided for @dashboardWelcomeResidenceFallback.
  ///
  /// In en, this message translates to:
  /// **'Here is what matters in your residence today.'**
  String get dashboardWelcomeResidenceFallback;

  /// No description provided for @dashboardWelcomeResidenceCompact.
  ///
  /// In en, this message translates to:
  /// **'Here is what matters in residence {residenceName} today'**
  String dashboardWelcomeResidenceCompact(String residenceName);

  /// No description provided for @dashboardWelcomeResidenceCompactFallback.
  ///
  /// In en, this message translates to:
  /// **'Here is what matters in your residence today'**
  String get dashboardWelcomeResidenceCompactFallback;

  /// No description provided for @dashboardMetaResidenceCode.
  ///
  /// In en, this message translates to:
  /// **'Residence code'**
  String get dashboardMetaResidenceCode;

  /// No description provided for @dashboardMetaPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get dashboardMetaPaymentStatus;

  /// No description provided for @dashboardPaymentStatusUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get dashboardPaymentStatusUpToDate;

  /// No description provided for @dashboardPaymentStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get dashboardPaymentStatusLate;

  /// No description provided for @dashboardPaymentStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get dashboardPaymentStatusUnknown;

  /// No description provided for @dashboardPaymentStatusTooltipUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Payment status up to date'**
  String get dashboardPaymentStatusTooltipUpToDate;

  /// No description provided for @dashboardPaymentStatusTooltipLate.
  ///
  /// In en, this message translates to:
  /// **'Payment status late'**
  String get dashboardPaymentStatusTooltipLate;

  /// No description provided for @dashboardPaymentStatusTooltipUnknown.
  ///
  /// In en, this message translates to:
  /// **'Payment status unavailable'**
  String get dashboardPaymentStatusTooltipUnknown;

  /// No description provided for @dashboardChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Fund evolution'**
  String get dashboardChartTitle;

  /// No description provided for @dashboardChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cumulative balance month by month from backend transactions.'**
  String get dashboardChartSubtitle;

  /// No description provided for @dashboardChartLegendCurrent.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get dashboardChartLegendCurrent;

  /// No description provided for @dashboardChartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet to display the evolution.'**
  String get dashboardChartEmpty;

  /// No description provided for @dashboardChartEmptyNoData.
  ///
  /// In en, this message translates to:
  /// **'No transactions are available yet to display an evolution.'**
  String get dashboardChartEmptyNoData;

  /// No description provided for @dashboardChartSinglePointTitle.
  ///
  /// In en, this message translates to:
  /// **'Only one period is available so far.'**
  String get dashboardChartSinglePointTitle;

  /// No description provided for @dashboardChartSinglePointBody.
  ///
  /// In en, this message translates to:
  /// **'Latest known balance for {month}: {balance}. The chart will appear once multiple periods are available.'**
  String dashboardChartSinglePointBody(String month, String balance);

  /// No description provided for @dashboardCardBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get dashboardCardBalance;

  /// No description provided for @dashboardCardContributions.
  ///
  /// In en, this message translates to:
  /// **'Total contributions'**
  String get dashboardCardContributions;

  /// No description provided for @dashboardCardExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get dashboardCardExpenses;

  /// No description provided for @dashboardCardLateResidents.
  ///
  /// In en, this message translates to:
  /// **'Late residents'**
  String get dashboardCardLateResidents;

  /// No description provided for @dashboardCardResidents.
  ///
  /// In en, this message translates to:
  /// **'Residents'**
  String get dashboardCardResidents;

  /// No description provided for @dashboardActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get dashboardActionsTitle;

  /// No description provided for @dashboardActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts to the modules connected to the budget and residence.'**
  String get dashboardActionsSubtitle;

  /// No description provided for @dashboardActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent votes'**
  String get dashboardActivityTitle;

  /// No description provided for @dashboardActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest votes exposed by the backend.'**
  String get dashboardActivitySubtitle;

  /// No description provided for @dashboardActivityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent votes available.'**
  String get dashboardActivityEmpty;

  /// No description provided for @dashboardEstimatedAmount.
  ///
  /// In en, this message translates to:
  /// **'Estimated amount'**
  String get dashboardEstimatedAmount;

  /// No description provided for @dashboardErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the dashboard.'**
  String get dashboardErrorTitle;

  /// No description provided for @dashboardVoteStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get dashboardVoteStatusOpen;

  /// No description provided for @dashboardVoteStatusValidated.
  ///
  /// In en, this message translates to:
  /// **'Validated'**
  String get dashboardVoteStatusValidated;

  /// No description provided for @dashboardVoteStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get dashboardVoteStatusRejected;

  /// No description provided for @moduleAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get moduleAuthTitle;

  /// No description provided for @moduleAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Auth module structure.'**
  String get moduleAuthDescription;

  /// No description provided for @moduleAuthScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Entry area for sign-in and sign-up flows, with no business logic implemented at this stage.'**
  String get moduleAuthScreenDescription;

  /// No description provided for @authHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Residence access'**
  String get authHeroEyebrow;

  /// No description provided for @authHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'A clean entry point for every residence.'**
  String get authHeroTitle;

  /// No description provided for @authHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your existing account or request access with your residence code. The frontend only consumes the real backend contract.'**
  String get authHeroDescription;

  /// No description provided for @landingBadge.
  ///
  /// In en, this message translates to:
  /// **'Neighbors, budget and payments'**
  String get landingBadge;

  /// No description provided for @landingTitle.
  ///
  /// In en, this message translates to:
  /// **'Residence life, clear from the first screen.'**
  String get landingTitle;

  /// No description provided for @landingDescription.
  ///
  /// In en, this message translates to:
  /// **'Access your condominium space through a simple welcome screen built around neighbor interactions, shared management, the residence fund and payments.'**
  String get landingDescription;

  /// No description provided for @landingFeatureNeighbors.
  ///
  /// In en, this message translates to:
  /// **'Neighbor connections'**
  String get landingFeatureNeighbors;

  /// No description provided for @landingFeatureSharedManagement.
  ///
  /// In en, this message translates to:
  /// **'Shared management'**
  String get landingFeatureSharedManagement;

  /// No description provided for @landingFeatureCagnotte.
  ///
  /// In en, this message translates to:
  /// **'Residence fund'**
  String get landingFeatureCagnotte;

  /// No description provided for @landingFeaturePayments.
  ///
  /// In en, this message translates to:
  /// **'Simplified payments'**
  String get landingFeaturePayments;

  /// No description provided for @landingCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Access your residence'**
  String get landingCtaTitle;

  /// No description provided for @landingCtaDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to return to your space, or register with your residence code to submit an access request.'**
  String get landingCtaDescription;

  /// No description provided for @landingLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get landingLoginPrompt;

  /// No description provided for @landingLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get landingLoginButton;

  /// No description provided for @landingRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get landingRegisterButton;

  /// No description provided for @authFeatureResidenceCode.
  ///
  /// In en, this message translates to:
  /// **'Residence code required'**
  String get authFeatureResidenceCode;

  /// No description provided for @authFeatureAdminValidation.
  ///
  /// In en, this message translates to:
  /// **'Admin validation workflow'**
  String get authFeatureAdminValidation;

  /// No description provided for @authFeatureSecureAccess.
  ///
  /// In en, this message translates to:
  /// **'JWT + protected profile'**
  String get authFeatureSecureAccess;

  /// No description provided for @authSignInTab.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTab;

  /// No description provided for @authSignUpTab.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authSignUpTab;

  /// No description provided for @authLoginPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginPageTitle;

  /// No description provided for @authSignInHeading.
  ///
  /// In en, this message translates to:
  /// **'Connect to your residence'**
  String get authSignInHeading;

  /// No description provided for @authSignInDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the credentials already validated by the backend.'**
  String get authSignInDescription;

  /// No description provided for @authSignUpHeading.
  ///
  /// In en, this message translates to:
  /// **'Request access'**
  String get authSignUpHeading;

  /// No description provided for @authSignUpDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a resident account linked to a residence. Approval remains handled by the backend admin workflow.'**
  String get authSignUpDescription;

  /// No description provided for @authNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'No account?'**
  String get authNoAccountPrompt;

  /// No description provided for @authAlreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccountPrompt;

  /// No description provided for @authRegisterLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterLinkLabel;

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToLogin;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authResidenceCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Residence code'**
  String get authResidenceCodeLabel;

  /// No description provided for @authResidenceCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'This code is provided by your residence administrator'**
  String get authResidenceCodeHelp;

  /// No description provided for @authBuildingLabel.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get authBuildingLabel;

  /// No description provided for @authHousingLabel.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get authHousingLabel;

  /// No description provided for @authCaptchaLabel.
  ///
  /// In en, this message translates to:
  /// **'Security check'**
  String get authCaptchaLabel;

  /// No description provided for @authCaptchaDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete the Turnstile challenge before creating your account.'**
  String get authCaptchaDescription;

  /// No description provided for @authCaptchaMissingSiteKey.
  ///
  /// In en, this message translates to:
  /// **'Captcha is enabled on the backend, but the public site key is missing from app-config.'**
  String get authCaptchaMissingSiteKey;

  /// No description provided for @authCaptchaPending.
  ///
  /// In en, this message translates to:
  /// **'Complete the captcha challenge to continue.'**
  String get authCaptchaPending;

  /// No description provided for @authCaptchaReady.
  ///
  /// In en, this message translates to:
  /// **'Captcha verified. You can submit the registration form.'**
  String get authCaptchaReady;

  /// No description provided for @authLoadingConfig.
  ///
  /// In en, this message translates to:
  /// **'Loading public application configuration...'**
  String get authLoadingConfig;

  /// No description provided for @authConfigErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load registration configuration'**
  String get authConfigErrorTitle;

  /// No description provided for @authRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get authRetryButton;

  /// No description provided for @authSubmittingLabel.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get authSubmittingLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginButton;

  /// No description provided for @authLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authLogoutButton;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Create request'**
  String get authRegisterButton;

  /// No description provided for @authRegisterCta.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterCta;

  /// No description provided for @authRequiredFieldsMessage.
  ///
  /// In en, this message translates to:
  /// **'Fill in all required fields before continuing.'**
  String get authRequiredFieldsMessage;

  /// No description provided for @authInvalidEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authInvalidEmailMessage;

  /// No description provided for @authErrorTechnical.
  ///
  /// In en, this message translates to:
  /// **'A technical error occurred. Please try again.'**
  String get authErrorTechnical;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server. Check your connection.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server is taking too long to respond. Please try again.'**
  String get authErrorTimeout;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorAccountPending.
  ///
  /// In en, this message translates to:
  /// **'Your account is pending validation by a residence administrator.'**
  String get authErrorAccountPending;

  /// No description provided for @authErrorAccountRejected.
  ///
  /// In en, this message translates to:
  /// **'Your access request was rejected. Contact a residence administrator if needed.'**
  String get authErrorAccountRejected;

  /// No description provided for @authErrorEmailAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This email address is already in use.'**
  String get authErrorEmailAlreadyUsed;

  /// No description provided for @authErrorInvalidResidenceCode.
  ///
  /// In en, this message translates to:
  /// **'The residence code is invalid.'**
  String get authErrorInvalidResidenceCode;

  /// No description provided for @authErrorInvalidCaptcha.
  ///
  /// In en, this message translates to:
  /// **'The security verification failed. Please try again.'**
  String get authErrorInvalidCaptcha;

  /// No description provided for @authErrorInvalidRequest.
  ///
  /// In en, this message translates to:
  /// **'The submitted information is invalid. Check the form and try again.'**
  String get authErrorInvalidRequest;

  /// No description provided for @authErrorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Authentication is required. Please sign in again.'**
  String get authErrorUnauthorized;

  /// No description provided for @authPasswordMismatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordMismatchMessage;

  /// No description provided for @authLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Authentication successful. Your profile has been loaded from the backend.'**
  String get authLoginSuccess;

  /// No description provided for @authRegisterPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterPageTitle;

  /// No description provided for @authRegisterSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created'**
  String get authRegisterSuccessTitle;

  /// No description provided for @authRegisterSuccessPending.
  ///
  /// In en, this message translates to:
  /// **'Your request has been created. An administrator must validate your account before you can sign in.'**
  String get authRegisterSuccessPending;

  /// No description provided for @authRegisterSuccessGeneric.
  ///
  /// In en, this message translates to:
  /// **'Registration request sent successfully.'**
  String get authRegisterSuccessGeneric;

  /// No description provided for @authCurrentUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Current backend profile'**
  String get authCurrentUserTitle;

  /// No description provided for @authRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get authRoleLabel;

  /// No description provided for @authStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get authStatusLabel;

  /// No description provided for @authResidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Residence'**
  String get authResidenceLabel;

  /// No description provided for @authRoleSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super admin'**
  String get authRoleSuperAdmin;

  /// No description provided for @authRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get authRoleAdmin;

  /// No description provided for @authRoleUser.
  ///
  /// In en, this message translates to:
  /// **'Resident'**
  String get authRoleUser;

  /// No description provided for @authStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending validation'**
  String get authStatusPending;

  /// No description provided for @authStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get authStatusActive;

  /// No description provided for @authStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get authStatusRejected;

  /// No description provided for @sessionLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking your session...'**
  String get sessionLoadingTitle;

  /// No description provided for @accountStatusRejectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your access is currently rejected. Contact a residence administrator if you believe this is a mistake.'**
  String get accountStatusRejectedDescription;

  /// No description provided for @accountStatusBackToLanding.
  ///
  /// In en, this message translates to:
  /// **'Back to landing'**
  String get accountStatusBackToLanding;

  /// No description provided for @modulePaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get modulePaymentTitle;

  /// No description provided for @modulePaymentDescription.
  ///
  /// In en, this message translates to:
  /// **'Payment module foundation.'**
  String get modulePaymentDescription;

  /// No description provided for @modulePaymentScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Entry point for the payment module. API integrations will only be wired to existing backend endpoints in the relevant tasks.'**
  String get modulePaymentScreenDescription;

  /// No description provided for @paymentModeSelectorLabel.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get paymentModeSelectorLabel;

  /// No description provided for @paymentModeSelectorDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose which payments to consult from this single screen.'**
  String get paymentModeSelectorDescription;

  /// No description provided for @paymentModeMine.
  ///
  /// In en, this message translates to:
  /// **'My payments'**
  String get paymentModeMine;

  /// No description provided for @paymentModeResident.
  ///
  /// In en, this message translates to:
  /// **'Resident'**
  String get paymentModeResident;

  /// No description provided for @paymentModePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentModePending;

  /// No description provided for @paymentResidentSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Consult a resident'**
  String get paymentResidentSearchTitle;

  /// No description provided for @paymentResidentSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Search for a resident in your residence by email to load the same payment tracking.'**
  String get paymentResidentSearchBody;

  /// No description provided for @paymentResidentEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Resident email'**
  String get paymentResidentEmailLabel;

  /// No description provided for @paymentResidentSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get paymentResidentSearchButton;

  /// No description provided for @paymentResidentSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an email address, then run the search.'**
  String get paymentResidentSearchHint;

  /// No description provided for @paymentResidentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No search started'**
  String get paymentResidentEmptyTitle;

  /// No description provided for @paymentResidentEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Enter a resident email to display status, pending payment, monthly tracking and history.'**
  String get paymentResidentEmptyBody;

  /// No description provided for @paymentResidentViewing.
  ///
  /// In en, this message translates to:
  /// **'Viewing resident {email}'**
  String paymentResidentViewing(String email);

  /// No description provided for @paymentResidentViewingDescription.
  ///
  /// In en, this message translates to:
  /// **'The displayed data belongs to the searched resident.'**
  String get paymentResidentViewingDescription;

  /// No description provided for @paymentResidentForbiddenError.
  ///
  /// In en, this message translates to:
  /// **'Access to this resident is forbidden.'**
  String get paymentResidentForbiddenError;

  /// No description provided for @paymentStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get paymentStatusOverdue;

  /// No description provided for @paymentStatusUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get paymentStatusUpToDate;

  /// No description provided for @paymentStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get paymentStatusUnknown;

  /// No description provided for @paymentHeroLateTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment is overdue'**
  String get paymentHeroLateTitle;

  /// No description provided for @paymentHeroLateBody.
  ///
  /// In en, this message translates to:
  /// **'Your payment has expired since {date}.'**
  String paymentHeroLateBody(String date);

  /// No description provided for @paymentHeroHealthyTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment status looks healthy'**
  String get paymentHeroHealthyTitle;

  /// No description provided for @paymentHeroHealthyBody.
  ///
  /// In en, this message translates to:
  /// **'You are up to date until {date}.'**
  String paymentHeroHealthyBody(String date);

  /// No description provided for @paymentHeroFallbackBody.
  ///
  /// In en, this message translates to:
  /// **'Payment status is not available yet.'**
  String get paymentHeroFallbackBody;

  /// No description provided for @paymentDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Your payment is approaching its due date.'**
  String get paymentDueSoon;

  /// No description provided for @paymentPrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Start a payment'**
  String get paymentPrimaryAction;

  /// No description provided for @paymentPendingLocksCreation.
  ///
  /// In en, this message translates to:
  /// **'A payment is already pending. You cannot start another one until it has been processed.'**
  String get paymentPendingLocksCreation;

  /// No description provided for @paymentPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending payment'**
  String get paymentPendingTitle;

  /// No description provided for @paymentPendingBody.
  ///
  /// In en, this message translates to:
  /// **'This payment is still waiting for validation from a residence administrator.'**
  String get paymentPendingBody;

  /// No description provided for @paymentPendingAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentPendingAmount;

  /// No description provided for @paymentPendingMonths.
  ///
  /// In en, this message translates to:
  /// **'Number of months'**
  String get paymentPendingMonths;

  /// No description provided for @paymentPendingMonthsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String paymentPendingMonthsValue(int count);

  /// No description provided for @paymentPendingHint.
  ///
  /// In en, this message translates to:
  /// **'Please validate the payment with a residence administrator.'**
  String get paymentPendingHint;

  /// No description provided for @paymentPendingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending payment'**
  String get paymentPendingEmptyTitle;

  /// No description provided for @paymentPendingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'You can start a new payment as soon as a new period needs to be covered.'**
  String get paymentPendingEmptyBody;

  /// No description provided for @paymentDeletePending.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get paymentDeletePending;

  /// No description provided for @paymentDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the pending payment?'**
  String get paymentDeleteConfirmTitle;

  /// No description provided for @paymentDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This action only removes the payment that is still waiting for validation.'**
  String get paymentDeleteConfirmBody;

  /// No description provided for @paymentDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'The pending payment has been deleted.'**
  String get paymentDeleteSuccess;

  /// No description provided for @paymentTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly tracking'**
  String get paymentTimelineTitle;

  /// No description provided for @paymentTimelineBody.
  ///
  /// In en, this message translates to:
  /// **'Unpaid months appear first. If everything is settled, the last three paid months stay visible.'**
  String get paymentTimelineBody;

  /// No description provided for @paymentTimelineEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No months to display'**
  String get paymentTimelineEmptyTitle;

  /// No description provided for @paymentTimelineEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'The backend did not return any month tracking yet.'**
  String get paymentTimelineEmptyBody;

  /// No description provided for @paymentMonthPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentMonthPaid;

  /// No description provided for @paymentMonthUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get paymentMonthUnpaid;

  /// No description provided for @paymentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get paymentHistoryTitle;

  /// No description provided for @paymentHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Review the latest validated payments and their covered period.'**
  String get paymentHistoryBody;

  /// No description provided for @paymentHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No history available'**
  String get paymentHistoryEmptyTitle;

  /// No description provided for @paymentHistoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Validated payments will appear here once they have been confirmed.'**
  String get paymentHistoryEmptyBody;

  /// No description provided for @paymentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a payment'**
  String get paymentDialogTitle;

  /// No description provided for @paymentDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a start month and how many months to pay. The backend will validate overlaps before creating the payment.'**
  String get paymentDialogBody;

  /// No description provided for @paymentDialogStartMonth.
  ///
  /// In en, this message translates to:
  /// **'Start month'**
  String get paymentDialogStartMonth;

  /// No description provided for @paymentDialogMonthCount.
  ///
  /// In en, this message translates to:
  /// **'Number of months'**
  String get paymentDialogMonthCount;

  /// No description provided for @paymentDialogMonthCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String paymentDialogMonthCountValue(int count);

  /// No description provided for @paymentDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get paymentDialogCancel;

  /// No description provided for @paymentDialogSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm request'**
  String get paymentDialogSubmit;

  /// No description provided for @paymentCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'The payment has been created and is now waiting for validation.'**
  String get paymentCreateSuccess;

  /// No description provided for @paymentErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the payment view.'**
  String get paymentErrorTitle;

  /// No description provided for @paymentNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'The requested payment could not be found.'**
  String get paymentNotFoundError;

  /// No description provided for @paymentDateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Date unavailable'**
  String get paymentDateUnavailable;

  /// No description provided for @paymentRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh the payment page'**
  String get paymentRefreshTooltip;

  /// No description provided for @paymentAdminPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending payments'**
  String get paymentAdminPendingTitle;

  /// No description provided for @paymentAdminPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Review and process resident payment requests that are still waiting for validation.'**
  String get paymentAdminPendingBody;

  /// No description provided for @paymentAdminPendingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending payments'**
  String get paymentAdminPendingEmptyTitle;

  /// No description provided for @paymentAdminPendingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New resident requests will appear here as soon as they are created.'**
  String get paymentAdminPendingEmptyBody;

  /// No description provided for @paymentAdminResidentEmail.
  ///
  /// In en, this message translates to:
  /// **'Resident'**
  String get paymentAdminResidentEmail;

  /// No description provided for @paymentAdminPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get paymentAdminPeriod;

  /// No description provided for @paymentAdminStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get paymentAdminStatusPending;

  /// No description provided for @paymentAdminValidate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get paymentAdminValidate;

  /// No description provided for @paymentAdminReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get paymentAdminReject;

  /// No description provided for @paymentAdminValidateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Validate this payment?'**
  String get paymentAdminValidateConfirmTitle;

  /// No description provided for @paymentAdminValidateConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm that you have collected this payment? This action will update the residence fund.'**
  String get paymentAdminValidateConfirmBody;

  /// No description provided for @paymentAdminValidateSuccess.
  ///
  /// In en, this message translates to:
  /// **'The payment has been validated.'**
  String get paymentAdminValidateSuccess;

  /// No description provided for @paymentAdminRejectSuccess.
  ///
  /// In en, this message translates to:
  /// **'The payment has been rejected.'**
  String get paymentAdminRejectSuccess;

  /// No description provided for @moduleExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get moduleExpenseTitle;

  /// No description provided for @moduleExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Expense module foundation.'**
  String get moduleExpenseDescription;

  /// No description provided for @moduleExpenseScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Entry point for the expense module. Application logic is intentionally absent at this stage.'**
  String get moduleExpenseScreenDescription;

  /// No description provided for @moduleVoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get moduleVoteTitle;

  /// No description provided for @moduleVoteDescription.
  ///
  /// In en, this message translates to:
  /// **'Vote module foundation.'**
  String get moduleVoteDescription;

  /// No description provided for @moduleVoteScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Entry point for the vote module, with a UI skeleton meant only to validate the architecture.'**
  String get moduleVoteScreenDescription;

  /// No description provided for @moduleSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get moduleSettingsTitle;

  /// No description provided for @moduleSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Access the residence residents.'**
  String get moduleSettingsDescription;

  /// No description provided for @moduleSettingsScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Entry point for the users module.'**
  String get moduleSettingsScreenDescription;

  /// No description provided for @moduleUsersAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Resident management'**
  String get moduleUsersAdminTitle;

  /// No description provided for @moduleUsersAdminDescription.
  ///
  /// In en, this message translates to:
  /// **'Administrators can manage residence residents.'**
  String get moduleUsersAdminDescription;

  /// No description provided for @moduleUsersAdminBody.
  ///
  /// In en, this message translates to:
  /// **'Review residents, track their status, and host future administration actions here without changing the backend contract.'**
  String get moduleUsersAdminBody;

  /// No description provided for @moduleUsersUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Resident directory'**
  String get moduleUsersUserTitle;

  /// No description provided for @moduleUsersUserDescription.
  ///
  /// In en, this message translates to:
  /// **'Users can consult the residence residents.'**
  String get moduleUsersUserDescription;

  /// No description provided for @moduleUsersUserBody.
  ///
  /// In en, this message translates to:
  /// **'Browse the resident list and useful residence information from a single entry point.'**
  String get moduleUsersUserBody;

  /// No description provided for @moduleResidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Residence'**
  String get moduleResidenceTitle;

  /// No description provided for @moduleResidenceDescription.
  ///
  /// In en, this message translates to:
  /// **'Residence module foundation.'**
  String get moduleResidenceDescription;

  /// No description provided for @moduleResidenceScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Entry point for the residence module. Future screens will rely on the real backend API without shifting business logic to the frontend.'**
  String get moduleResidenceScreenDescription;

  /// No description provided for @languageSwitcherTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get languageSwitcherTooltip;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

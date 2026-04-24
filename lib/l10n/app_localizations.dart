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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
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
  String dashboardGreeting(Object name);

  /// No description provided for @dashboardGreetingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get dashboardGreetingGeneric;

  /// No description provided for @dashboardWelcomeResidence.
  ///
  /// In en, this message translates to:
  /// **'Here is what matters in {residenceName} today.'**
  String dashboardWelcomeResidence(Object residenceName);

  /// No description provided for @dashboardWelcomeResidenceFallback.
  ///
  /// In en, this message translates to:
  /// **'Here is what matters in your residence today.'**
  String get dashboardWelcomeResidenceFallback;

  /// No description provided for @dashboardWelcomeResidenceCompact.
  ///
  /// In en, this message translates to:
  /// **'Here is what matters in residence {residenceName} today'**
  String dashboardWelcomeResidenceCompact(Object residenceName);

  /// No description provided for @dashboardWelcomeResidenceCompactFallback.
  ///
  /// In en, this message translates to:
  /// **'Here is what matters in your residence today'**
  String get dashboardWelcomeResidenceCompactFallback;

  /// No description provided for @dashboardCurrentHousingLabel.
  ///
  /// In en, this message translates to:
  /// **'Your housing'**
  String get dashboardCurrentHousingLabel;

  /// No description provided for @dashboardCurrentHousingType.
  ///
  /// In en, this message translates to:
  /// **'Housing type'**
  String get dashboardCurrentHousingType;

  /// No description provided for @dashboardCurrentHousingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Housing not assigned'**
  String get dashboardCurrentHousingUnavailable;

  /// No description provided for @dashboardCurrentHousingActive.
  ///
  /// In en, this message translates to:
  /// **'Housing active'**
  String get dashboardCurrentHousingActive;

  /// No description provided for @dashboardCurrentHousingPending.
  ///
  /// In en, this message translates to:
  /// **'Activation pending'**
  String get dashboardCurrentHousingPending;

  /// No description provided for @dashboardCurrentHousingDescription.
  ///
  /// In en, this message translates to:
  /// **'This housing information is used as the pivot for your space.'**
  String get dashboardCurrentHousingDescription;

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
  String dashboardChartSinglePointBody(Object month, Object balance);

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
  /// **'Late housing'**
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

  /// No description provided for @headerResidenceBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Residence balance:'**
  String get headerResidenceBalanceLabel;

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

  /// No description provided for @authRegisterStepHousingIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose your housing carefully. It is very important to select the correct one. Your registration request will be validated by an administrator.'**
  String get authRegisterStepHousingIntro;

  /// No description provided for @authRegisterStepHousingSearch.
  ///
  /// In en, this message translates to:
  /// **'Show housing'**
  String get authRegisterStepHousingSearch;

  /// No description provided for @authRegisterStepHousingTitle.
  ///
  /// In en, this message translates to:
  /// **'Select your housing'**
  String get authRegisterStepHousingTitle;

  /// No description provided for @authRegisterStepHousingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No housing is available for this residence code.'**
  String get authRegisterStepHousingEmpty;

  /// No description provided for @authRegisterStepHousingFull.
  ///
  /// In en, this message translates to:
  /// **'This housing has already reached its maximum capacity of {maxOccupants} residents. You cannot continue.'**
  String authRegisterStepHousingFull(Object maxOccupants);

  /// No description provided for @authRegisterStepHousingFirstResident.
  ///
  /// In en, this message translates to:
  /// **'You will be the first resident registered for this housing. This registration will still require admin validation.'**
  String get authRegisterStepHousingFirstResident;

  /// No description provided for @authRegisterStepHousingOccupied.
  ///
  /// In en, this message translates to:
  /// **'{occupiedCount} resident(s) are already registered for this housing. This registration will still require admin validation.'**
  String authRegisterStepHousingOccupied(Object occupiedCount);

  /// No description provided for @authRegisterStepNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get authRegisterStepNext;

  /// No description provided for @authRegisterStepBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authRegisterStepBack;

  /// No description provided for @authRegisterHousingOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Occupants: {occupiedCount}/{maxOccupants}'**
  String authRegisterHousingOccupancy(Object occupiedCount, Object maxOccupants);

  /// No description provided for @authRegisterHousingEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get authRegisterHousingEdit;

  /// No description provided for @authRegisterHousingCode.
  ///
  /// In en, this message translates to:
  /// **'Internal code'**
  String get authRegisterHousingCode;

  /// No description provided for @authRegisterHousingStageTitle.
  ///
  /// In en, this message translates to:
  /// **'Step 1 • Housing'**
  String get authRegisterHousingStageTitle;

  /// No description provided for @authRegisterProfileStageTitle.
  ///
  /// In en, this message translates to:
  /// **'Step 2 • Details'**
  String get authRegisterProfileStageTitle;

  /// No description provided for @authRegisterHousingStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get authRegisterHousingStatusAvailable;

  /// No description provided for @authRegisterHousingStatusFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get authRegisterHousingStatusFull;

  /// No description provided for @authRegisterHousingStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get authRegisterHousingStatusActive;

  /// No description provided for @authRegisterHousingStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get authRegisterHousingStatusPending;

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
  /// **'Payments'**
  String get paymentModeMine;

  /// No description provided for @paymentModeResident.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get paymentModeResident;

  /// No description provided for @paymentModePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentModePending;

  /// No description provided for @paymentResidentSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Consult a housing'**
  String get paymentResidentSearchTitle;

  /// No description provided for @paymentResidentSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Select a housing unit in your residence to load its payment tracking, pending payment and history.'**
  String get paymentResidentSearchBody;

  /// No description provided for @paymentResidentEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get paymentResidentEmailLabel;

  /// No description provided for @paymentResidentSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get paymentResidentSearchButton;

  /// No description provided for @paymentResidentSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a housing unit to display its payment tracking.'**
  String get paymentResidentSearchHint;

  /// No description provided for @paymentResidentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No housing selected'**
  String get paymentResidentEmptyTitle;

  /// No description provided for @paymentResidentEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Select a housing unit to display status, pending payment, monthly tracking and history.'**
  String get paymentResidentEmptyBody;

  /// No description provided for @paymentResidentViewing.
  ///
  /// In en, this message translates to:
  /// **'Viewing housing {email}'**
  String paymentResidentViewing(Object email);

  /// No description provided for @paymentResidentViewingDescription.
  ///
  /// In en, this message translates to:
  /// **'The displayed data belongs to the selected housing unit.'**
  String get paymentResidentViewingDescription;

  /// No description provided for @paymentResidentForbiddenError.
  ///
  /// In en, this message translates to:
  /// **'Access to this housing unit is forbidden.'**
  String get paymentResidentForbiddenError;

  /// No description provided for @paymentHousingLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load housing units'**
  String get paymentHousingLoadErrorTitle;

  /// No description provided for @paymentHousingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No housing available'**
  String get paymentHousingEmptyTitle;

  /// No description provided for @paymentHousingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No housing unit is available for this residence.'**
  String get paymentHousingEmptyBody;

  /// No description provided for @paymentHousingStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get paymentHousingStatusActive;

  /// No description provided for @paymentHousingStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get paymentHousingStatusInactive;

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
  String paymentHeroLateBody(Object date);

  /// No description provided for @paymentHeroHealthyTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment status looks healthy'**
  String get paymentHeroHealthyTitle;

  /// No description provided for @paymentHeroHealthyBody.
  ///
  /// In en, this message translates to:
  /// **'You are up to date until {date}.'**
  String paymentHeroHealthyBody(Object date);

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

  /// No description provided for @paymentOverdueCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment overdue alert'**
  String get paymentOverdueCardTitle;

  /// No description provided for @paymentOverdueCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The latest unpaid months are shown below.'**
  String get paymentOverdueCardSubtitle;

  /// No description provided for @paymentOverdueMonthsLabel.
  ///
  /// In en, this message translates to:
  /// **'3 latest overdue months'**
  String get paymentOverdueMonthsLabel;

  /// No description provided for @paymentOverdueManyMonthsMessage.
  ///
  /// In en, this message translates to:
  /// **'You have {count} overdue months. Please regularize your situation as quickly as possible.'**
  String paymentOverdueManyMonthsMessage(Object count);

  /// No description provided for @paymentOverdueRegularizeSoon.
  ///
  /// In en, this message translates to:
  /// **'Please regularize your situation as quickly as possible.'**
  String get paymentOverdueRegularizeSoon;

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

  /// No description provided for @paymentPendingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get paymentPendingPeriod;

  /// No description provided for @paymentPendingMonthsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String paymentPendingMonthsValue(Object count);

  /// No description provided for @paymentPendingHint.
  ///
  /// In en, this message translates to:
  /// **'Please have this payment validated by a residence administrator.'**
  String get paymentPendingHint;

  /// No description provided for @paymentPendingSelfHint.
  ///
  /// In en, this message translates to:
  /// **'This payment will also appear in the pending payments list so you can validate it yourself.'**
  String get paymentPendingSelfHint;

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

  /// No description provided for @paymentTimelineShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get paymentTimelineShowMore;

  /// No description provided for @paymentTimelineTooManyUnpaid.
  ///
  /// In en, this message translates to:
  /// **'You have a total of {count} unpaid months'**
  String paymentTimelineTooManyUnpaid(Object count);

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

  /// No description provided for @paymentDialogBodyForResident.
  ///
  /// In en, this message translates to:
  /// **'You are about to start a payment for housing {email}. Choose a start month and how many months to pay. The backend will validate overlaps before creating the payment.'**
  String paymentDialogBodyForResident(Object email);

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
  String paymentDialogMonthCountValue(Object count);

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

  /// No description provided for @paymentCreateSuccessForResident.
  ///
  /// In en, this message translates to:
  /// **'The payment for housing {email} has been created and is now waiting for validation.'**
  String paymentCreateSuccessForResident(Object email);

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
  /// **'Review and process housing payment requests that are still waiting for validation.'**
  String get paymentAdminPendingBody;

  /// No description provided for @paymentAdminPendingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending payments'**
  String get paymentAdminPendingEmptyTitle;

  /// No description provided for @paymentAdminPendingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'There are no payments pending validation for shared expenses.'**
  String get paymentAdminPendingEmptyBody;

  /// No description provided for @paymentAdminResidentEmail.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
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
  /// **'Expense view connected to the residence real backend endpoints.'**
  String get moduleExpenseScreenDescription;

  /// No description provided for @expenseModeSelectorLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense types'**
  String get expenseModeSelectorLabel;

  /// No description provided for @expenseModeSelectorDescription.
  ///
  /// In en, this message translates to:
  /// **'Review fund-backed expenses here. The other tabs will stay available later.'**
  String get expenseModeSelectorDescription;

  /// No description provided for @expenseModeCagnotte.
  ///
  /// In en, this message translates to:
  /// **'Fund'**
  String get expenseModeCagnotte;

  /// No description provided for @expenseModeShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get expenseModeShared;

  /// No description provided for @expenseModePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get expenseModePending;

  /// No description provided for @expenseModeSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get expenseModeSoon;

  /// No description provided for @expenseCagnotteTitle.
  ///
  /// In en, this message translates to:
  /// **'Approved fund expenses'**
  String get expenseCagnotteTitle;

  /// No description provided for @expenseCagnotteDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the expenses already validated and funded by the residence pot, with a quick category filter.'**
  String get expenseCagnotteDescription;

  /// No description provided for @expenseSharedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared expenses'**
  String get expenseSharedTitle;

  /// No description provided for @expenseSharedDescription.
  ///
  /// In en, this message translates to:
  /// **'Track approved shared expenses, already paid amounts, and housing-by-housing contribution details.'**
  String get expenseSharedDescription;

  /// No description provided for @expenseSharedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No approved shared expense is available.'**
  String get expenseSharedEmptyBody;

  /// No description provided for @expenseSharedPaidAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid amount'**
  String get expenseSharedPaidAmountLabel;

  /// No description provided for @expenseSharedAmountPerPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Per housing'**
  String get expenseSharedAmountPerPersonLabel;

  /// No description provided for @expenseSharedRemainingResidentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Unpaid housing units left'**
  String get expenseSharedRemainingResidentsLabel;

  /// No description provided for @expenseSharedStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get expenseSharedStatusUnpaid;

  /// No description provided for @expenseSharedStatusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially paid'**
  String get expenseSharedStatusPartiallyPaid;

  /// No description provided for @expenseSharedStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get expenseSharedStatusPaid;

  /// No description provided for @expenseSharedUnknownCreator.
  ///
  /// In en, this message translates to:
  /// **'Unknown admin'**
  String get expenseSharedUnknownCreator;

  /// No description provided for @expenseSharedShowParticipants.
  ///
  /// In en, this message translates to:
  /// **'Show housing units'**
  String get expenseSharedShowParticipants;

  /// No description provided for @expenseSharedHideParticipants.
  ///
  /// In en, this message translates to:
  /// **'Hide housing units'**
  String get expenseSharedHideParticipants;

  /// No description provided for @expenseSharedCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by: {name}'**
  String expenseSharedCreatedBy(Object name);

  /// No description provided for @expenseSharedParticipantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} housing units'**
  String expenseSharedParticipantsCount(Object count);

  /// No description provided for @expenseSharedParticipantAmountSummary.
  ///
  /// In en, this message translates to:
  /// **'{paid} paid out of {due}'**
  String expenseSharedParticipantAmountSummary(Object paid, Object due);

  /// No description provided for @expenseCategoryFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get expenseCategoryFilterLabel;

  /// No description provided for @expenseCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get expenseCategoryAll;

  /// No description provided for @expenseCategoryUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unspecified category'**
  String get expenseCategoryUnknown;

  /// No description provided for @expenseCreatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get expenseCreatedAtLabel;

  /// No description provided for @expenseValidatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Validated'**
  String get expenseValidatedAtLabel;

  /// No description provided for @expenseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses available'**
  String get expenseEmptyTitle;

  /// No description provided for @expenseEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No approved fund expense is available.'**
  String get expenseEmptyBody;

  /// No description provided for @expenseErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the expense view.'**
  String get expenseErrorTitle;

  /// No description provided for @expenseForbiddenError.
  ///
  /// In en, this message translates to:
  /// **'Access to this residence expenses is forbidden.'**
  String get expenseForbiddenError;

  /// No description provided for @expenseNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'The requested expense resource could not be found.'**
  String get expenseNotFoundError;

  /// No description provided for @expenseRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh the expense page'**
  String get expenseRefreshTooltip;

  /// No description provided for @expenseCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create an expense'**
  String get expenseCreateAction;

  /// No description provided for @expenseCreateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New fund expense'**
  String get expenseCreateDialogTitle;

  /// No description provided for @expenseCreateDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Provide the category, amount, and a description. The expense will be created as pending.'**
  String get expenseCreateDialogBody;

  /// No description provided for @expenseCreateCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCreateCategoryLabel;

  /// No description provided for @expenseCreateCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Select a category.'**
  String get expenseCreateCategoryError;

  /// No description provided for @expenseCreateAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseCreateAmountLabel;

  /// No description provided for @expenseCreateAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get expenseCreateAmountError;

  /// No description provided for @expenseCreateDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get expenseCreateDescriptionLabel;

  /// No description provided for @expenseCreateDescriptionError.
  ///
  /// In en, this message translates to:
  /// **'Enter a description.'**
  String get expenseCreateDescriptionError;

  /// No description provided for @expenseCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create expense'**
  String get expenseCreateSubmit;

  /// No description provided for @expenseCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'The expense has been created as pending.'**
  String get expenseCreateSuccess;

  /// No description provided for @expenseSharedCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create a shared expense'**
  String get expenseSharedCreateAction;

  /// No description provided for @expenseSharedCreateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New shared expense'**
  String get expenseSharedCreateDialogTitle;

  /// No description provided for @expenseSharedCreateDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This shared expense will not be funded by the residence fund. Active housing units of the residence will have to contribute to cover it. The expense will be created as pending.'**
  String get expenseSharedCreateDialogBody;

  /// No description provided for @expenseSharedParticipantsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active housing units'**
  String get expenseSharedParticipantsLabel;

  /// No description provided for @expenseSharedTotalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total expense amount'**
  String get expenseSharedTotalAmountLabel;

  /// No description provided for @expenseSharedEstimatedAmountPerPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated amount per housing'**
  String get expenseSharedEstimatedAmountPerPersonLabel;

  /// No description provided for @expenseSharedEstimatedAmountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter the total amount'**
  String get expenseSharedEstimatedAmountPlaceholder;

  /// No description provided for @expenseSharedCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create shared expense'**
  String get expenseSharedCreateSubmit;

  /// No description provided for @expenseSharedCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'The shared expense has been created as pending.'**
  String get expenseSharedCreateSuccess;

  /// No description provided for @moduleVoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get moduleVoteTitle;

  /// No description provided for @moduleVoteDescription.
  ///
  /// In en, this message translates to:
  /// **'Residence vote management.'**
  String get moduleVoteDescription;

  /// No description provided for @moduleVoteScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Review residence votes, track live participation, and let each occupant submit a choice from a clear modern screen.'**
  String get moduleVoteScreenDescription;

  /// No description provided for @voteRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh the votes view'**
  String get voteRefreshTooltip;

  /// No description provided for @voteInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Residence votes'**
  String get voteInfoTitle;

  /// No description provided for @voteInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Votes are created by administrators. Every active resident can vote and live results remain visible without ever exposing individual housing choices.'**
  String get voteInfoBody;

  /// No description provided for @voteInfoAdminCreated.
  ///
  /// In en, this message translates to:
  /// **'Admin creation'**
  String get voteInfoAdminCreated;

  /// No description provided for @voteInfoResidentVotes.
  ///
  /// In en, this message translates to:
  /// **'Resident participation'**
  String get voteInfoResidentVotes;

  /// No description provided for @voteInfoVisibleResults.
  ///
  /// In en, this message translates to:
  /// **'Visible results'**
  String get voteInfoVisibleResults;

  /// No description provided for @voteCreateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create a vote'**
  String get voteCreateTooltip;

  /// No description provided for @voteStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get voteStatusOpen;

  /// No description provided for @voteStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get voteStatusClosed;

  /// No description provided for @voteEstimatedAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated amount'**
  String get voteEstimatedAmountLabel;

  /// No description provided for @voteStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get voteStartDateLabel;

  /// No description provided for @voteEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get voteEndDateLabel;

  /// No description provided for @voteCreatedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get voteCreatedByLabel;

  /// No description provided for @voteResultsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Live result'**
  String get voteResultsSectionTitle;

  /// No description provided for @voteParticipantsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total} voters'**
  String voteParticipantsSummary(Object count, Object total);

  /// No description provided for @voteTurnoutLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} vote(s) recorded out of {total} eligible voters'**
  String voteTurnoutLabel(Object count, Object total);

  /// No description provided for @voteLeadingPour.
  ///
  /// In en, this message translates to:
  /// **'Yes is leading with {count} vote(s).'**
  String voteLeadingPour(Object count);

  /// No description provided for @voteLeadingContre.
  ///
  /// In en, this message translates to:
  /// **'No is leading with {count} vote(s).'**
  String voteLeadingContre(Object count);

  /// No description provided for @voteLeadingNeutre.
  ///
  /// In en, this message translates to:
  /// **'Neutral is leading with {count} vote(s).'**
  String voteLeadingNeutre(Object count);

  /// No description provided for @voteLeadingTie.
  ///
  /// In en, this message translates to:
  /// **'The main options are currently tied.'**
  String get voteLeadingTie;

  /// No description provided for @voteLeadingNone.
  ///
  /// In en, this message translates to:
  /// **'No vote has been recorded yet.'**
  String get voteLeadingNone;

  /// No description provided for @voteChoicePour.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get voteChoicePour;

  /// No description provided for @voteChoiceContre.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get voteChoiceContre;

  /// No description provided for @voteChoiceNeutre.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get voteChoiceNeutre;

  /// No description provided for @voteChoiceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get voteChoiceUnknown;

  /// No description provided for @voteActionPour.
  ///
  /// In en, this message translates to:
  /// **'Vote yes'**
  String get voteActionPour;

  /// No description provided for @voteActionContre.
  ///
  /// In en, this message translates to:
  /// **'Vote no'**
  String get voteActionContre;

  /// No description provided for @voteActionNeutre.
  ///
  /// In en, this message translates to:
  /// **'Vote neutral'**
  String get voteActionNeutre;

  /// No description provided for @voteAlreadyVoted.
  ///
  /// In en, this message translates to:
  /// **'Your vote has already been recorded: {choice}.'**
  String voteAlreadyVoted(Object choice);

  /// No description provided for @voteClosedMessage.
  ///
  /// In en, this message translates to:
  /// **'This vote is closed. Results remain visible.'**
  String get voteClosedMessage;

  /// No description provided for @voteHousingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Housing participation'**
  String get voteHousingSectionTitle;

  /// No description provided for @voteHousingSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} housing unit(s) tracked'**
  String voteHousingSectionSubtitle(Object count);

  /// No description provided for @voteHousingVoted.
  ///
  /// In en, this message translates to:
  /// **'Vote recorded'**
  String get voteHousingVoted;

  /// No description provided for @voteHousingNotVoted.
  ///
  /// In en, this message translates to:
  /// **'No vote recorded'**
  String get voteHousingNotVoted;

  /// No description provided for @voteHousingParticipationValue.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total}'**
  String voteHousingParticipationValue(Object count, Object total);

  /// No description provided for @voteEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No vote available'**
  String get voteEmptyTitle;

  /// No description provided for @voteEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Votes created by administrators will appear here as soon as they are published.'**
  String get voteEmptyBody;

  /// No description provided for @voteErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the votes view.'**
  String get voteErrorTitle;

  /// No description provided for @voteRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get voteRetryAction;

  /// No description provided for @voteForbiddenError.
  ///
  /// In en, this message translates to:
  /// **'Access to this residence votes is forbidden.'**
  String get voteForbiddenError;

  /// No description provided for @voteNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'The requested vote could not be found.'**
  String get voteNotFoundError;

  /// No description provided for @voteCreateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a vote'**
  String get voteCreateDialogTitle;

  /// No description provided for @voteCreateDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Provide a title, a short description, an estimated amount and the voting period. The vote will become visible to the residence right away.'**
  String get voteCreateDialogBody;

  /// No description provided for @voteFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get voteFieldTitle;

  /// No description provided for @voteFieldTitleError.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get voteFieldTitleError;

  /// No description provided for @voteFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Short description'**
  String get voteFieldDescription;

  /// No description provided for @voteFieldDescriptionError.
  ///
  /// In en, this message translates to:
  /// **'Enter a description.'**
  String get voteFieldDescriptionError;

  /// No description provided for @voteFieldEstimatedAmount.
  ///
  /// In en, this message translates to:
  /// **'Estimated amount'**
  String get voteFieldEstimatedAmount;

  /// No description provided for @voteFieldStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get voteFieldStartDate;

  /// No description provided for @voteFieldEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get voteFieldEndDate;

  /// No description provided for @voteDateRangeError.
  ///
  /// In en, this message translates to:
  /// **'The end date must be after the start date.'**
  String get voteDateRangeError;

  /// No description provided for @voteCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get voteCancelAction;

  /// No description provided for @voteCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get voteCreateAction;

  /// No description provided for @voteCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'The vote has been created successfully.'**
  String get voteCreateSuccess;

  /// No description provided for @voteSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your vote has been recorded.'**
  String get voteSubmitSuccess;

  /// No description provided for @voteCreateExpenseAction.
  ///
  /// In en, this message translates to:
  /// **'Create an expense'**
  String get voteCreateExpenseAction;

  /// No description provided for @voteExpenseConfirmDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm expense creation'**
  String get voteExpenseConfirmDialogTitle;

  /// No description provided for @voteExpenseConfirmDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to create a pending expense from this vote?'**
  String get voteExpenseConfirmDialogBody;

  /// No description provided for @voteExpenseCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'The expense has been created as pending from this vote.'**
  String get voteExpenseCreateSuccess;

  /// No description provided for @voteExpenseAlreadyCreated.
  ///
  /// In en, this message translates to:
  /// **'Expense already created'**
  String get voteExpenseAlreadyCreated;

  /// No description provided for @voteEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'Warning: voting ends in {days} day(s).'**
  String voteEndingSoon(Object days);

  /// No description provided for @voteCommentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get voteCommentDialogTitle;

  /// No description provided for @voteCommentDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to enter a comment? If not, leave the field empty.'**
  String get voteCommentDialogBody;

  /// No description provided for @voteCommentFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional comment'**
  String get voteCommentFieldLabel;

  /// No description provided for @voteCommentSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit vote'**
  String get voteCommentSubmitAction;

  /// No description provided for @voteCommentRemainingCharacters.
  ///
  /// In en, this message translates to:
  /// **'{count} character(s) remaining'**
  String voteCommentRemainingCharacters(int count);

  /// No description provided for @voteCurrentUserCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Your comment'**
  String get voteCurrentUserCommentLabel;

  /// No description provided for @voteAdminCommentsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get voteAdminCommentsSectionTitle;

  /// No description provided for @voteAdminCommentsVisible.
  ///
  /// In en, this message translates to:
  /// **'comments visible'**
  String get voteAdminCommentsVisible;

  /// No description provided for @voteAdminCommentsLoading.
  ///
  /// In en, this message translates to:
  /// **'loading comments'**
  String get voteAdminCommentsLoading;

  /// No description provided for @moduleSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Residence'**
  String get moduleSettingsTitle;

  /// No description provided for @moduleSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Housing-centered residence view.'**
  String get moduleSettingsDescription;

  /// No description provided for @moduleSettingsScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Entry point for the residence view powered by the aggregated backend endpoint.'**
  String get moduleSettingsScreenDescription;

  /// No description provided for @moduleUsersAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin residence view'**
  String get moduleUsersAdminTitle;

  /// No description provided for @moduleUsersAdminDescription.
  ///
  /// In en, this message translates to:
  /// **'Administrators manage housing units, occupants, and pending requests.'**
  String get moduleUsersAdminDescription;

  /// No description provided for @moduleUsersAdminBody.
  ///
  /// In en, this message translates to:
  /// **'Review the residence summary, housing cards, occupants, payment status, and pending requests without rebuilding business logic on the mobile side.'**
  String get moduleUsersAdminBody;

  /// No description provided for @moduleUsersUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Residence view'**
  String get moduleUsersUserTitle;

  /// No description provided for @moduleUsersUserDescription.
  ///
  /// In en, this message translates to:
  /// **'Users consult the residence through housing units.'**
  String get moduleUsersUserDescription;

  /// No description provided for @moduleUsersUserBody.
  ///
  /// In en, this message translates to:
  /// **'Browse a simple modern residence view built around housing units, occupants, activation, and payment status.'**
  String get moduleUsersUserBody;

  /// No description provided for @usersRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh the residents view'**
  String get usersRefreshTooltip;

  /// No description provided for @usersEditProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Edit my profile'**
  String get usersEditProfileAction;

  /// No description provided for @usersAdminViewLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin view'**
  String get usersAdminViewLabel;

  /// No description provided for @usersResidentsTab.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get usersResidentsTab;

  /// No description provided for @usersPendingTab.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get usersPendingTab;

  /// No description provided for @usersSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Housing search'**
  String get usersSearchLabel;

  /// No description provided for @usersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by number, building, internal code, or address'**
  String get usersSearchHint;

  /// No description provided for @usersLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load residents.'**
  String get usersLoadErrorTitle;

  /// No description provided for @usersResidentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No housing to display'**
  String get usersResidentsEmptyTitle;

  /// No description provided for @usersResidentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No housing unit matches the current search.'**
  String get usersResidentsEmptyBody;

  /// No description provided for @usersPendingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get usersPendingEmptyTitle;

  /// No description provided for @usersPendingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New registration requests will appear here grouped by housing unit.'**
  String get usersPendingEmptyBody;

  /// No description provided for @usersCurrentSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your housing'**
  String get usersCurrentSectionTitle;

  /// No description provided for @usersAdminsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin housing'**
  String get usersAdminsSectionTitle;

  /// No description provided for @usersLateSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Late housing'**
  String get usersLateSectionTitle;

  /// No description provided for @usersOthersSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Other housing'**
  String get usersOthersSectionTitle;

  /// No description provided for @usersResidenceEntryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Residence entry date'**
  String get usersResidenceEntryDateLabel;

  /// No description provided for @usersActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Resident actions'**
  String get usersActionsTooltip;

  /// No description provided for @usersEditDateAction.
  ///
  /// In en, this message translates to:
  /// **'Edit entry date'**
  String get usersEditDateAction;

  /// No description provided for @usersPromoteToAdminAction.
  ///
  /// In en, this message translates to:
  /// **'Promote to admin'**
  String get usersPromoteToAdminAction;

  /// No description provided for @usersDemoteToUserAction.
  ///
  /// In en, this message translates to:
  /// **'Set as resident'**
  String get usersDemoteToUserAction;

  /// No description provided for @usersDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get usersDeleteAction;

  /// No description provided for @usersPendingCardBody.
  ///
  /// In en, this message translates to:
  /// **'This account is still waiting for validation from a residence administrator.'**
  String get usersPendingCardBody;

  /// No description provided for @usersCreatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Created on'**
  String get usersCreatedAtLabel;

  /// No description provided for @usersApproveAction.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get usersApproveAction;

  /// No description provided for @usersRejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get usersRejectAction;

  /// No description provided for @usersApproveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve this user?'**
  String get usersApproveConfirmTitle;

  /// No description provided for @usersApproveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm the validation of this user?'**
  String get usersApproveConfirmBody;

  /// No description provided for @usersApproveSuccess.
  ///
  /// In en, this message translates to:
  /// **'The user has been approved.'**
  String get usersApproveSuccess;

  /// No description provided for @usersRejectSuccess.
  ///
  /// In en, this message translates to:
  /// **'The user has been rejected.'**
  String get usersRejectSuccess;

  /// No description provided for @usersDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this user?'**
  String get usersDeleteConfirmTitle;

  /// No description provided for @usersDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Account {email} will be removed from the residence.'**
  String usersDeleteConfirmBody(Object email);

  /// No description provided for @usersDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'The user has been deleted.'**
  String get usersDeleteSuccess;

  /// No description provided for @usersRoleChangeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Change this user role?'**
  String get usersRoleChangeConfirmTitle;

  /// No description provided for @usersRoleChangeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{email} will be assigned the {roleLabel} role.'**
  String usersRoleChangeConfirmBody(Object email, Object roleLabel);

  /// No description provided for @usersRoleUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The user role has been updated.'**
  String get usersRoleUpdatedSuccess;

  /// No description provided for @usersEditProfileDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit my profile'**
  String get usersEditProfileDialogTitle;

  /// No description provided for @usersFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get usersFirstNameLabel;

  /// No description provided for @usersLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get usersLastNameLabel;

  /// No description provided for @usersSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get usersSaveAction;

  /// No description provided for @usersProfileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The profile has been updated.'**
  String get usersProfileUpdatedSuccess;

  /// No description provided for @usersDateUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The residence entry date has been updated.'**
  String get usersDateUpdatedSuccess;

  /// No description provided for @usersOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Residence summary'**
  String get usersOverviewTitle;

  /// No description provided for @usersSummaryCurrentFund.
  ///
  /// In en, this message translates to:
  /// **'Fund status'**
  String get usersSummaryCurrentFund;

  /// No description provided for @usersSummaryTotalHousing.
  ///
  /// In en, this message translates to:
  /// **'Total housing'**
  String get usersSummaryTotalHousing;

  /// No description provided for @usersSummaryActiveHousing.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get usersSummaryActiveHousing;

  /// No description provided for @usersSummaryInactiveHousing.
  ///
  /// In en, this message translates to:
  /// **'inactive'**
  String get usersSummaryInactiveHousing;

  /// No description provided for @usersSummaryResidents.
  ///
  /// In en, this message translates to:
  /// **'Linked residents'**
  String get usersSummaryResidents;

  /// No description provided for @usersSummaryAdminSplit.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get usersSummaryAdminSplit;

  /// No description provided for @usersSummaryPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Up-to-date housing'**
  String get usersSummaryPaymentStatus;

  /// No description provided for @usersSummaryLateHousing.
  ///
  /// In en, this message translates to:
  /// **'late'**
  String get usersSummaryLateHousing;

  /// No description provided for @usersFundPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive fund'**
  String get usersFundPositive;

  /// No description provided for @usersFundNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative fund'**
  String get usersFundNegative;

  /// No description provided for @usersFundNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral fund'**
  String get usersFundNeutral;

  /// No description provided for @usersPaymentStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get usersPaymentStatusInactive;

  /// No description provided for @usersHousingOccupancyValue.
  ///
  /// In en, this message translates to:
  /// **'{occupied}/{max}'**
  String usersHousingOccupancyValue(Object occupied, Object max);

  /// No description provided for @usersHousingTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Housing type'**
  String get usersHousingTypeLabel;

  /// No description provided for @usersHousingFloorLabel.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get usersHousingFloorLabel;

  /// No description provided for @usersHousingPaymentUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Covered until'**
  String get usersHousingPaymentUntilLabel;

  /// No description provided for @usersHousingOverdueMonthsLabel.
  ///
  /// In en, this message translates to:
  /// **'Overdue months'**
  String get usersHousingOverdueMonthsLabel;

  /// No description provided for @usersHousingResidentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} occupant(s) displayed'**
  String usersHousingResidentsSubtitle(Object count);

  /// No description provided for @usersHousingResidentsSection.
  ///
  /// In en, this message translates to:
  /// **'Housing occupants'**
  String get usersHousingResidentsSection;

  /// No description provided for @usersHousingExistingResidentsSection.
  ///
  /// In en, this message translates to:
  /// **'Existing occupants'**
  String get usersHousingExistingResidentsSection;

  /// No description provided for @usersHousingPendingResidentsSection.
  ///
  /// In en, this message translates to:
  /// **'Pending new users'**
  String get usersHousingPendingResidentsSection;

  /// No description provided for @usersHousingNoResidentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No active occupants'**
  String get usersHousingNoResidentsTitle;

  /// No description provided for @usersHousingNoResidentsBody.
  ///
  /// In en, this message translates to:
  /// **'No active resident is attached to this housing unit yet.'**
  String get usersHousingNoResidentsBody;

  /// No description provided for @usersPendingPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending payment'**
  String get usersPendingPaymentLabel;

  /// No description provided for @usersCurrentResidentTag.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get usersCurrentResidentTag;

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

  /// No description provided for @cagnotteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Fund transactions details'**
  String get cagnotteDialogTitle;

  /// No description provided for @cagnotteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Latest transactions are displayed first.'**
  String get cagnotteDialogBody;

  /// No description provided for @cagnotteDialogLegendContribution.
  ///
  /// In en, this message translates to:
  /// **'Contribution'**
  String get cagnotteDialogLegendContribution;

  /// No description provided for @cagnotteDialogLegendExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get cagnotteDialogLegendExpense;

  /// No description provided for @cagnotteDialogErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load fund transactions'**
  String get cagnotteDialogErrorTitle;

  /// No description provided for @cagnotteDialogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No fund transactions'**
  String get cagnotteDialogEmptyTitle;

  /// No description provided for @cagnotteDialogEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No transaction is available for this residence.'**
  String get cagnotteDialogEmptyBody;

  /// No description provided for @cagnotteDialogHousingColumn.
  ///
  /// In en, this message translates to:
  /// **'Housing (internal code)'**
  String get cagnotteDialogHousingColumn;

  /// No description provided for @cagnotteDialogTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get cagnotteDialogTypeColumn;

  /// No description provided for @cagnotteDialogAmountColumn.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get cagnotteDialogAmountColumn;

  /// No description provided for @cagnotteDialogDateColumn.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get cagnotteDialogDateColumn;

  /// No description provided for @cagnotteDialogHousingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get cagnotteDialogHousingUnavailable;

  /// No description provided for @accountMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open account menu'**
  String get accountMenuTooltip;

  /// No description provided for @accountMenuProfile.
  ///
  /// In en, this message translates to:
  /// **'My personal data'**
  String get accountMenuProfile;

  /// No description provided for @accountMenuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get accountMenuLanguage;

  /// No description provided for @accountMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connected as {name}'**
  String accountMenuSubtitle(Object name);

  /// No description provided for @accountMenuSubtitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Manage your account and app language'**
  String get accountMenuSubtitleFallback;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My personal data'**
  String get accountSettingsTitle;

  /// No description provided for @accountSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your visible profile details and optionally change your password from the same dialog.'**
  String get accountSettingsSubtitle;

  /// No description provided for @accountSettingsIdentitySection.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get accountSettingsIdentitySection;

  /// No description provided for @accountSettingsPasswordSection.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountSettingsPasswordSection;

  /// No description provided for @accountSettingsPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Leave the password fields empty if you do not want to change it.'**
  String get accountSettingsPasswordHint;

  /// No description provided for @accountSettingsCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get accountSettingsCurrentPassword;

  /// No description provided for @accountSettingsNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get accountSettingsNewPassword;

  /// No description provided for @accountSettingsPasswordRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in current password, new password, and confirmation to change your password.'**
  String get accountSettingsPasswordRequiredFields;

  /// No description provided for @accountSettingsPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get accountSettingsPasswordMinLength;

  /// No description provided for @accountSettingsPasswordUppercase.
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter'**
  String get accountSettingsPasswordUppercase;

  /// No description provided for @accountSettingsPasswordLowercase.
  ///
  /// In en, this message translates to:
  /// **'At least one lowercase letter'**
  String get accountSettingsPasswordLowercase;

  /// No description provided for @accountSettingsPasswordSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'At least one special character'**
  String get accountSettingsPasswordSpecialCharacter;

  /// No description provided for @accountSettingsPasswordConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get accountSettingsPasswordConfirmation;

  /// No description provided for @accountLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get accountLanguageTitle;

  /// No description provided for @accountLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only languages already supported by the app are available here.'**
  String get accountLanguageSubtitle;

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

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

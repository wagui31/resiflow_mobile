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
  /// **'Mobile architecture'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter feature-based foundation aligned with the project context: Riverpod, Dio, go_router, and a clear core/features split.'**
  String get dashboardSubtitle;

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

  /// No description provided for @authResidenceCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Residence code'**
  String get authResidenceCodeLabel;

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

  /// No description provided for @authRequiredFieldsMessage.
  ///
  /// In en, this message translates to:
  /// **'Fill in all required fields before continuing.'**
  String get authRequiredFieldsMessage;

  /// No description provided for @authLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Authentication successful. Your profile has been loaded from the backend.'**
  String get authLoginSuccess;

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

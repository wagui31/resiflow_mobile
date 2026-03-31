// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'ResiFlow';

  @override
  String get dashboardTitle => 'Architecture mobile';

  @override
  String get dashboardSubtitle => 'Socle Flutter feature-based conforme au contexte projet : Riverpod, Dio, go_router et separation core/features.';

  @override
  String get moduleAuthTitle => 'Authentification';

  @override
  String get moduleAuthDescription => 'Structure du module auth.';

  @override
  String get moduleAuthScreenDescription => 'Espace reserve au parcours de connexion et d inscription, sans logique metier implemente a ce stade.';

  @override
  String get authHeroEyebrow => 'Acces residence';

  @override
  String get authHeroTitle => 'Un point d entree propre pour chaque residence.';

  @override
  String get authHeroDescription => 'Connectez-vous avec un compte existant ou demandez un acces avec le code de votre residence. Le frontend consomme uniquement le contrat backend reel.';

  @override
  String get authFeatureResidenceCode => 'Code residence obligatoire';

  @override
  String get authFeatureAdminValidation => 'Validation admin geree';

  @override
  String get authFeatureSecureAccess => 'JWT + profil protege';

  @override
  String get authSignInTab => 'Connexion';

  @override
  String get authSignUpTab => 'Inscription';

  @override
  String get authSignInHeading => 'Connectez-vous a votre residence';

  @override
  String get authSignInDescription => 'Utilisez les identifiants deja valides par le backend.';

  @override
  String get authSignUpHeading => 'Demander un acces';

  @override
  String get authSignUpDescription => 'Creez un compte resident lie a une residence. La validation reste geree par le workflow admin du backend.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authResidenceCodeLabel => 'Code residence';

  @override
  String get authBuildingLabel => 'Immeuble';

  @override
  String get authHousingLabel => 'Logement';

  @override
  String get authCaptchaLabel => 'Verification de securite';

  @override
  String get authCaptchaDescription => 'Validez le challenge Turnstile avant de creer votre compte.';

  @override
  String get authCaptchaMissingSiteKey => 'Le captcha est actif cote backend, mais la site key publique manque dans app-config.';

  @override
  String get authCaptchaPending => 'Completez le captcha pour continuer.';

  @override
  String get authCaptchaReady => 'Captcha valide. Vous pouvez envoyer le formulaire.';

  @override
  String get authLoadingConfig => 'Chargement de la configuration publique...';

  @override
  String get authConfigErrorTitle => 'Impossible de charger la configuration d inscription';

  @override
  String get authRetryButton => 'Reessayer';

  @override
  String get authSubmittingLabel => 'Veuillez patienter...';

  @override
  String get authLoginButton => 'Se connecter';

  @override
  String get authLogoutButton => 'Se deconnecter';

  @override
  String get authRegisterButton => 'Creer la demande';

  @override
  String get authRequiredFieldsMessage => 'Renseignez tous les champs obligatoires avant de continuer.';

  @override
  String get authLoginSuccess => 'Connexion reussie. Votre profil a ete charge depuis le backend.';

  @override
  String get authRegisterSuccessPending => 'Votre demande a ete creee. Un administrateur doit valider votre compte avant la connexion.';

  @override
  String get authRegisterSuccessGeneric => 'Demande d inscription envoyee avec succes.';

  @override
  String get authCurrentUserTitle => 'Profil backend courant';

  @override
  String get authRoleLabel => 'Role';

  @override
  String get authStatusLabel => 'Statut';

  @override
  String get authResidenceLabel => 'Residence';

  @override
  String get authRoleSuperAdmin => 'Super admin';

  @override
  String get authRoleAdmin => 'Admin';

  @override
  String get authRoleUser => 'Resident';

  @override
  String get authStatusPending => 'En attente de validation';

  @override
  String get authStatusActive => 'Actif';

  @override
  String get authStatusRejected => 'Refuse';

  @override
  String get sessionLoadingTitle => 'Verification de votre session...';

  @override
  String get accountStatusRejectedDescription => 'Votre acces est actuellement refuse. Contactez un administrateur de votre residence si vous pensez qu il s agit d une erreur.';

  @override
  String get accountStatusBackToLanding => 'Retour a l accueil';

  @override
  String get modulePaymentTitle => 'Paiement';

  @override
  String get modulePaymentDescription => 'Base du module paiement.';

  @override
  String get modulePaymentScreenDescription => 'Point d entree du module paiement. Les integrations API seront branchees uniquement sur les endpoints backend existants lors des taches concernees.';

  @override
  String get moduleExpenseTitle => 'Depense';

  @override
  String get moduleExpenseDescription => 'Base du module depense.';

  @override
  String get moduleExpenseScreenDescription => 'Point d entree du module depense. La logique applicative reste volontairement absente a ce stade.';

  @override
  String get moduleVoteTitle => 'Vote';

  @override
  String get moduleVoteDescription => 'Base du module vote.';

  @override
  String get moduleVoteScreenDescription => 'Point d entree du module vote, avec un squelette d interface uniquement destine a valider l architecture.';

  @override
  String get moduleResidenceTitle => 'Residence';

  @override
  String get moduleResidenceDescription => 'Base du module residence.';

  @override
  String get moduleResidenceScreenDescription => 'Point d entree du module residence. Les futurs ecrans utiliseront l API backend reelle sans deplacer la logique metier cote frontend.';

  @override
  String get languageSwitcherTooltip => 'Changer la langue';

  @override
  String get languageFrench => 'Francais';

  @override
  String get languageEnglish => 'Anglais';
}

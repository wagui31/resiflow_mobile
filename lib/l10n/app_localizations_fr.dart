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
  String get dashboardTitle => 'Accueil';

  @override
  String get dashboardSubtitle =>
      'Une vue claire, utile et connectee aux vraies donnees de votre residence.';

  @override
  String dashboardGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get dashboardGreetingGeneric => 'Bonjour';

  @override
  String dashboardWelcomeResidence(String residenceName) {
    return 'Voici l essentiel de $residenceName aujourd hui.';
  }

  @override
  String get dashboardWelcomeResidenceFallback =>
      'Voici l essentiel de votre residence aujourd hui.';

  @override
  String dashboardWelcomeResidenceCompact(String residenceName) {
    return 'Voici l essentiel de la residence $residenceName aujourd hui';
  }

  @override
  String get dashboardWelcomeResidenceCompactFallback =>
      'Voici l essentiel de votre residence aujourd hui';

  @override
  String get dashboardMetaResidenceCode => 'Code residence';

  @override
  String get dashboardMetaPaymentStatus => 'Statut paiement';

  @override
  String get dashboardPaymentStatusUpToDate => 'A jour';

  @override
  String get dashboardPaymentStatusLate => 'En retard';

  @override
  String get dashboardPaymentStatusUnknown => 'Inconnu';

  @override
  String get dashboardPaymentStatusTooltipUpToDate =>
      'Statut de paiement a jour';

  @override
  String get dashboardPaymentStatusTooltipLate =>
      'Statut de paiement en retard';

  @override
  String get dashboardPaymentStatusTooltipUnknown =>
      'Statut de paiement indisponible';

  @override
  String get dashboardChartTitle => 'Evolution de la cagnotte';

  @override
  String get dashboardChartSubtitle =>
      'Solde cumule mois par mois a partir des transactions backend.';

  @override
  String get dashboardChartLegendCurrent => 'Solde';

  @override
  String get dashboardChartEmpty =>
      'Pas encore assez de donnees pour afficher l evolution.';

  @override
  String get dashboardChartEmptyNoData =>
      'Aucune transaction disponible pour afficher une evolution.';

  @override
  String get dashboardChartSinglePointTitle =>
      'Une seule periode est disponible pour le moment.';

  @override
  String dashboardChartSinglePointBody(String month, String balance) {
    return 'Dernier solde connu pour $month : $balance. Le graphique apparaitra des que plusieurs periodes seront disponibles.';
  }

  @override
  String get dashboardCardBalance => 'Solde actuel';

  @override
  String get dashboardCardContributions => 'Total contributions';

  @override
  String get dashboardCardExpenses => 'Total depenses';

  @override
  String get dashboardCardLateResidents => 'Residents en retard';

  @override
  String get dashboardCardResidents => 'Residents';

  @override
  String get dashboardActionsTitle => 'Acces rapide';

  @override
  String get dashboardActionsSubtitle =>
      'Raccourcis vers les modules relies au budget et a la residence.';

  @override
  String get dashboardActivityTitle => 'Votes recents';

  @override
  String get dashboardActivitySubtitle =>
      'Derniers votes exposes par le backend.';

  @override
  String get dashboardActivityEmpty => 'Aucun vote recent disponible.';

  @override
  String get dashboardEstimatedAmount => 'Montant estime';

  @override
  String get dashboardErrorTitle => 'Impossible de charger le dashboard.';

  @override
  String get dashboardVoteStatusOpen => 'Ouvert';

  @override
  String get dashboardVoteStatusValidated => 'Valide';

  @override
  String get dashboardVoteStatusRejected => 'Rejete';

  @override
  String get moduleAuthTitle => 'Authentification';

  @override
  String get moduleAuthDescription => 'Structure du module auth.';

  @override
  String get moduleAuthScreenDescription =>
      'Espace reserve au parcours de connexion et d inscription, sans logique metier implemente a ce stade.';

  @override
  String get authHeroEyebrow => 'Acces residence';

  @override
  String get authHeroTitle => 'Un point d entree propre pour chaque residence.';

  @override
  String get authHeroDescription =>
      'Connectez-vous avec un compte existant ou demandez un acces avec le code de votre residence. Le frontend consomme uniquement le contrat backend reel.';

  @override
  String get landingBadge => 'Voisinage, budget et paiements';

  @override
  String get landingTitle =>
      'La vie de residence, claire des le premier ecran.';

  @override
  String get landingDescription =>
      'Retrouvez un acces simple a votre espace de copropriete pour suivre les echanges entre voisins, la gestion commune, la cagnotte et les paiements sans friction.';

  @override
  String get landingFeatureNeighbors => 'Echanges entre voisins';

  @override
  String get landingFeatureSharedManagement => 'Gestion commune';

  @override
  String get landingFeatureCagnotte => 'Cagnotte residence';

  @override
  String get landingFeaturePayments => 'Paiements simplifies';

  @override
  String get landingCtaTitle => 'Accedez a votre residence';

  @override
  String get landingCtaDescription =>
      'Connectez-vous pour retrouver votre espace, ou inscrivez-vous avec votre code residence pour envoyer une demande d acces.';

  @override
  String get landingLoginPrompt => 'Deja un compte ?';

  @override
  String get landingLoginButton => 'Se connecter';

  @override
  String get landingRegisterButton => 'S inscrire';

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
  String get authLoginPageTitle => 'Connexion';

  @override
  String get authSignInHeading => 'Connectez-vous a votre residence';

  @override
  String get authSignInDescription =>
      'Utilisez les identifiants deja valides par le backend.';

  @override
  String get authSignUpHeading => 'Demander un acces';

  @override
  String get authSignUpDescription =>
      'Creez un compte resident lie a une residence. La validation reste geree par le workflow admin du backend.';

  @override
  String get authNoAccountPrompt => 'Pas de compte ?';

  @override
  String get authAlreadyHaveAccountPrompt => 'Deja un compte ?';

  @override
  String get authRegisterLinkLabel => 'S inscrire';

  @override
  String get authBackToLogin => 'Retour a la connexion';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authConfirmPasswordLabel => 'Confirmation mot de passe';

  @override
  String get authResidenceCodeLabel => 'Code residence';

  @override
  String get authResidenceCodeHelp =>
      'Ce code vous est fourni par l administrateur de votre residence';

  @override
  String get authBuildingLabel => 'Immeuble';

  @override
  String get authHousingLabel => 'Logement';

  @override
  String get authCaptchaLabel => 'Verification de securite';

  @override
  String get authCaptchaDescription =>
      'Validez le challenge Turnstile avant de creer votre compte.';

  @override
  String get authCaptchaMissingSiteKey =>
      'Le captcha est actif cote backend, mais la site key publique manque dans app-config.';

  @override
  String get authCaptchaPending => 'Completez le captcha pour continuer.';

  @override
  String get authCaptchaReady =>
      'Captcha valide. Vous pouvez envoyer le formulaire.';

  @override
  String get authLoadingConfig => 'Chargement de la configuration publique...';

  @override
  String get authConfigErrorTitle =>
      'Impossible de charger la configuration d inscription';

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
  String get authRegisterCta => 'S inscrire';

  @override
  String get authRequiredFieldsMessage =>
      'Renseignez tous les champs obligatoires avant de continuer.';

  @override
  String get authInvalidEmailMessage =>
      'Veuillez renseigner une adresse email valide.';

  @override
  String get authErrorTechnical =>
      'Une erreur technique est survenue. Veuillez reessayer.';

  @override
  String get authErrorNetwork =>
      'Impossible de joindre le serveur. Verifiez votre connexion.';

  @override
  String get authErrorTimeout =>
      'Le serveur met trop de temps a repondre. Veuillez reessayer.';

  @override
  String get authErrorInvalidCredentials => 'Email ou mot de passe invalide.';

  @override
  String get authErrorAccountPending =>
      'Votre compte est en attente de validation par un administrateur.';

  @override
  String get authErrorAccountRejected =>
      'Votre demande d acces a ete refusee. Contactez un administrateur de votre residence.';

  @override
  String get authErrorEmailAlreadyUsed =>
      'Cette adresse email est deja utilisee.';

  @override
  String get authErrorInvalidResidenceCode => 'Le code residence est invalide.';

  @override
  String get authErrorInvalidCaptcha =>
      'La verification de securite a echoue. Veuillez recommencer.';

  @override
  String get authErrorInvalidRequest =>
      'Les informations saisies sont invalides. Verifiez le formulaire.';

  @override
  String get authErrorUnauthorized =>
      'Authentification requise. Veuillez vous reconnecter.';

  @override
  String get authPasswordMismatchMessage =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get authLoginSuccess =>
      'Connexion reussie. Votre profil a ete charge depuis le backend.';

  @override
  String get authRegisterPageTitle => 'Inscription';

  @override
  String get authRegisterSuccessTitle => 'Votre compte a ete cree';

  @override
  String get authRegisterSuccessPending =>
      'Votre demande a ete creee. Un administrateur doit valider votre compte avant la connexion.';

  @override
  String get authRegisterSuccessGeneric =>
      'Demande d inscription envoyee avec succes.';

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
  String get accountStatusRejectedDescription =>
      'Votre acces est actuellement refuse. Contactez un administrateur de votre residence si vous pensez qu il s agit d une erreur.';

  @override
  String get accountStatusBackToLanding => 'Retour a l accueil';

  @override
  String get modulePaymentTitle => 'Paiement';

  @override
  String get modulePaymentDescription => 'Base du module paiement.';

  @override
  String get modulePaymentScreenDescription =>
      'Point d entree du module paiement. Les integrations API seront branchees uniquement sur les endpoints backend existants lors des taches concernees.';

  @override
  String get paymentModeSelectorLabel => 'Affichage';

  @override
  String get paymentModeSelectorDescription =>
      'Choisissez les paiements a consulter depuis cette vue unique.';

  @override
  String get paymentModeMine => 'Mes paiements';

  @override
  String get paymentModeResident => 'Resident';

  @override
  String get paymentModePending => 'En attente';

  @override
  String get paymentResidentSearchTitle => 'Consulter un resident';

  @override
  String get paymentResidentSearchBody =>
      'Recherchez un resident de votre residence avec son email pour charger le meme suivi paiement.';

  @override
  String get paymentResidentEmailLabel => 'Email du resident';

  @override
  String get paymentResidentSearchButton => 'Rechercher';

  @override
  String get paymentResidentSearchHint =>
      'Saisissez un email puis lancez la recherche.';

  @override
  String get paymentResidentEmptyTitle => 'Aucune recherche lancee';

  @override
  String get paymentResidentEmptyBody =>
      'Entrez l email d un resident pour afficher son statut, son paiement en attente, son suivi mensuel et son historique.';

  @override
  String paymentResidentViewing(String email) {
    return 'Consultation du resident $email';
  }

  @override
  String get paymentResidentViewingDescription =>
      'Les donnees affichees correspondent au resident recherche.';

  @override
  String get paymentResidentForbiddenError => 'Acces interdit a ce resident.';

  @override
  String get paymentStatusOverdue => 'En retard';

  @override
  String get paymentStatusUpToDate => 'A jour';

  @override
  String get paymentStatusUnknown => 'Indisponible';

  @override
  String get paymentHeroLateTitle => 'Attention retard de paiement';

  @override
  String paymentHeroLateBody(String date) {
    return 'Votre paiement a expire depuis le $date.';
  }

  @override
  String get paymentHeroHealthyTitle => 'Situation paiement stable';

  @override
  String paymentHeroHealthyBody(String date) {
    return 'Vous etes a jour jusqu au $date.';
  }

  @override
  String get paymentHeroFallbackBody =>
      'Le statut paiement n est pas encore disponible.';

  @override
  String get paymentDueSoon => 'Votre paiement arrive bientot a echeance.';

  @override
  String get paymentPrimaryAction => 'Initier un paiement';

  @override
  String get paymentPendingLocksCreation =>
      'Un paiement est deja en attente. Vous ne pouvez pas en initier un autre tant qu il n a pas ete traite.';

  @override
  String get paymentPendingTitle => 'Paiement en attente';

  @override
  String get paymentPendingBody =>
      'Ce paiement attend encore la validation de l admin de la residence.';

  @override
  String get paymentPendingAmount => 'Montant';

  @override
  String get paymentPendingMonths => 'Nombre de mois';

  @override
  String paymentPendingMonthsValue(int count) {
    return '$count mois';
  }

  @override
  String get paymentPendingHint =>
      'Merci de valider le paiement avec un admin de la residence.';

  @override
  String get paymentPendingEmptyTitle => 'Aucun paiement en attente';

  @override
  String get paymentPendingEmptyBody =>
      'Vous pouvez initier un nouveau paiement des qu une nouvelle periode doit etre couverte.';

  @override
  String get paymentDeletePending => 'Supprimer';

  @override
  String get paymentDeleteConfirmTitle => 'Supprimer le paiement en attente ?';

  @override
  String get paymentDeleteConfirmBody =>
      'Cette action supprimera uniquement le paiement encore en attente de validation.';

  @override
  String get paymentDeleteSuccess => 'Le paiement en attente a ete supprime.';

  @override
  String get paymentTimelineTitle => 'Suivi mensuel';

  @override
  String get paymentTimelineBody =>
      'Les mois impayes apparaissent en premier. Si tout est regle, les trois derniers mois payes restent visibles.';

  @override
  String get paymentTimelineEmptyTitle => 'Aucun mois a afficher';

  @override
  String get paymentTimelineEmptyBody =>
      'Le backend n a retourne aucun mois de suivi pour le moment.';

  @override
  String get paymentMonthPaid => 'Paye';

  @override
  String get paymentMonthUnpaid => 'Non paye';

  @override
  String get paymentHistoryTitle => 'Historique';

  @override
  String get paymentHistoryBody =>
      'Retrouvez les derniers paiements valides et leur periode associee.';

  @override
  String get paymentHistoryEmptyTitle => 'Aucun historique disponible';

  @override
  String get paymentHistoryEmptyBody =>
      'Les paiements valides apparaitront ici des qu ils seront confirmes.';

  @override
  String get paymentDialogTitle => 'Initier un paiement';

  @override
  String get paymentDialogBody =>
      'Choisissez un mois de debut et le nombre de mois a payer. Le backend verifiera les chevauchements avant creation.';

  @override
  String get paymentDialogStartMonth => 'Mois de debut';

  @override
  String get paymentDialogMonthCount => 'Nombre de mois';

  @override
  String paymentDialogMonthCountValue(int count) {
    return '$count mois';
  }

  @override
  String get paymentDialogCancel => 'Annuler';

  @override
  String get paymentDialogSubmit => 'Confirmer la demande';

  @override
  String get paymentCreateSuccess =>
      'Le paiement a ete cree et attend maintenant une validation.';

  @override
  String get paymentErrorTitle => 'Impossible de charger la vue paiement.';

  @override
  String get paymentNotFoundError => 'Le paiement demande est introuvable.';

  @override
  String get paymentDateUnavailable => 'Date indisponible';

  @override
  String get paymentRefreshTooltip => 'Rafraichir la page paiement';

  @override
  String get paymentAdminPendingTitle => 'Paiements en attente';

  @override
  String get paymentAdminPendingBody =>
      'Consultez et traitez les demandes de paiement residents encore en attente de validation.';

  @override
  String get paymentAdminPendingEmptyTitle => 'Aucun paiement en attente';

  @override
  String get paymentAdminPendingEmptyBody =>
      'Les nouvelles demandes residents apparaitront ici des qu elles seront creees.';

  @override
  String get paymentAdminResidentEmail => 'Resident';

  @override
  String get paymentAdminPeriod => 'Periode';

  @override
  String get paymentAdminStatusPending => 'PENDING';

  @override
  String get paymentAdminValidate => 'Valider';

  @override
  String get paymentAdminReject => 'Rejeter';

  @override
  String get paymentAdminValidateConfirmTitle => 'Valider ce paiement ?';

  @override
  String get paymentAdminValidateConfirmBody =>
      'Confirmez-vous avoir bien encaisse ce paiement ? Cette action mettra a jour la cagnotte.';

  @override
  String get paymentAdminValidateSuccess => 'Le paiement a ete valide.';

  @override
  String get paymentAdminRejectSuccess => 'Le paiement a ete rejete.';

  @override
  String get moduleExpenseTitle => 'Depense';

  @override
  String get moduleExpenseDescription => 'Base du module depense.';

  @override
  String get moduleExpenseScreenDescription =>
      'Point d entree du module depense. La logique applicative reste volontairement absente a ce stade.';

  @override
  String get moduleVoteTitle => 'Vote';

  @override
  String get moduleVoteDescription => 'Base du module vote.';

  @override
  String get moduleVoteScreenDescription =>
      'Point d entree du module vote, avec un squelette d interface uniquement destine a valider l architecture.';

  @override
  String get moduleSettingsTitle => 'Users';

  @override
  String get moduleSettingsDescription =>
      'Acces aux residents de la residence.';

  @override
  String get moduleSettingsScreenDescription =>
      'Point d entree du module users.';

  @override
  String get moduleUsersAdminTitle => 'Gestion des residents';

  @override
  String get moduleUsersAdminDescription =>
      'Les administrateurs peuvent gerer les residents de la residence.';

  @override
  String get moduleUsersAdminBody =>
      'Consultez les residents, suivez leur statut et preparez ici les futures actions d administration sans modifier le contrat backend.';

  @override
  String get moduleUsersUserTitle => 'Consultation des residents';

  @override
  String get moduleUsersUserDescription =>
      'Les utilisateurs peuvent consulter les residents de la residence.';

  @override
  String get moduleUsersUserBody =>
      'Consultez la liste des residents et les informations utiles de votre residence depuis un point d entree unique.';

  @override
  String get moduleResidenceTitle => 'Residence';

  @override
  String get moduleResidenceDescription => 'Base du module residence.';

  @override
  String get moduleResidenceScreenDescription =>
      'Point d entree du module residence. Les futurs ecrans utiliseront l API backend reelle sans deplacer la logique metier cote frontend.';

  @override
  String get languageSwitcherTooltip => 'Changer la langue';

  @override
  String get languageFrench => 'Francais';

  @override
  String get languageEnglish => 'Anglais';
}

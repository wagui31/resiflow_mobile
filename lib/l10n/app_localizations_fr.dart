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
  String get dashboardSubtitle => 'Une vue claire, utile et connectee aux vraies donnees de votre residence.';

  @override
  String dashboardGreeting(Object name) {
    return 'Bonjour $name';
  }

  @override
  String get dashboardGreetingGeneric => 'Bonjour';

  @override
  String dashboardWelcomeResidence(Object residenceName) {
    return 'Voici l essentiel de $residenceName aujourd hui.';
  }

  @override
  String get dashboardWelcomeResidenceFallback => 'Voici l essentiel de votre residence aujourd hui.';

  @override
  String dashboardWelcomeResidenceCompact(Object residenceName) {
    return 'Voici l essentiel de la residence $residenceName aujourd hui';
  }

  @override
  String get dashboardWelcomeResidenceCompactFallback => 'Voici l essentiel de votre residence aujourd hui';

  @override
  String get dashboardCurrentHousingLabel => 'Votre logement';

  @override
  String get dashboardCurrentHousingType => 'Type logement';

  @override
  String get dashboardCurrentHousingUnavailable => 'Logement non renseigne';

  @override
  String get dashboardCurrentHousingActive => 'Logement actif';

  @override
  String get dashboardCurrentHousingPending => 'Activation en attente';

  @override
  String get dashboardCurrentHousingDescription => 'Les informations de ce logement sont utilisees comme pivot de votre espace.';

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
  String get dashboardPaymentStatusTooltipUpToDate => 'Statut de paiement a jour';

  @override
  String get dashboardPaymentStatusTooltipLate => 'Statut de paiement en retard';

  @override
  String get dashboardPaymentStatusTooltipUnknown => 'Statut de paiement indisponible';

  @override
  String get dashboardChartTitle => 'Evolution de la cagnotte';

  @override
  String get dashboardChartSubtitle => 'Solde cumule mois par mois a partir des transactions backend.';

  @override
  String get dashboardChartLegendCurrent => 'Solde';

  @override
  String get dashboardChartEmpty => 'Pas encore assez de donnees pour afficher l evolution.';

  @override
  String get dashboardChartEmptyNoData => 'Aucune transaction disponible pour afficher une evolution.';

  @override
  String get dashboardChartSinglePointTitle => 'Une seule periode est disponible pour le moment.';

  @override
  String dashboardChartSinglePointBody(Object month, Object balance) {
    return 'Dernier solde connu pour $month : $balance. Le graphique apparaitra des que plusieurs periodes seront disponibles.';
  }

  @override
  String get dashboardCardBalance => 'Solde actuel';

  @override
  String get dashboardCardContributions => 'Total contributions';

  @override
  String get dashboardCardExpenses => 'Total depenses';

  @override
  String get dashboardCardLateResidents => 'Logements en retard';

  @override
  String get dashboardCardResidents => 'Residents';

  @override
  String get dashboardActionsTitle => 'Acces rapide';

  @override
  String get dashboardActionsSubtitle => 'Raccourcis vers les modules relies au budget et a la residence.';

  @override
  String get dashboardActivityTitle => 'Votes recents';

  @override
  String get dashboardActivitySubtitle => 'Derniers votes exposes par le backend.';

  @override
  String get dashboardActivityEmpty => 'Aucun vote recent disponible.';

  @override
  String get dashboardEstimatedAmount => 'Montant estime';

  @override
  String get dashboardErrorTitle => 'Impossible de charger le dashboard.';

  @override
  String get headerResidenceBalanceLabel => 'Solde residence :';

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
  String get moduleAuthScreenDescription => 'Espace reserve au parcours de connexion et d inscription, sans logique metier implemente a ce stade.';

  @override
  String get authHeroEyebrow => 'Acces residence';

  @override
  String get authHeroTitle => 'Un point d entree propre pour chaque residence.';

  @override
  String get authHeroDescription => 'Connectez-vous avec un compte existant ou demandez un acces avec le code de votre residence. Le frontend consomme uniquement le contrat backend reel.';

  @override
  String get landingBadge => 'Voisinage, budget et paiements';

  @override
  String get landingTitle => 'La vie de residence, claire des le premier ecran.';

  @override
  String get landingDescription => 'Retrouvez un acces simple a votre espace de copropriete pour suivre les echanges entre voisins, la gestion commune, la cagnotte et les paiements sans friction.';

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
  String get landingCtaDescription => 'Connectez-vous pour retrouver votre espace, ou inscrivez-vous avec votre code residence pour envoyer une demande d acces.';

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
  String get authSignInDescription => 'Utilisez les identifiants deja valides par le backend.';

  @override
  String get authSignUpHeading => 'Demander un acces';

  @override
  String get authSignUpDescription => 'Creez un compte resident lie a une residence. La validation reste geree par le workflow admin du backend.';

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
  String get authResidenceCodeHelp => 'Ce code vous est fourni par l administrateur de votre residence';

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
  String get authRegisterCta => 'S inscrire';

  @override
  String get authRequiredFieldsMessage => 'Renseignez tous les champs obligatoires avant de continuer.';

  @override
  String get authInvalidEmailMessage => 'Veuillez renseigner une adresse email valide.';

  @override
  String get authErrorTechnical => 'Une erreur technique est survenue. Veuillez reessayer.';

  @override
  String get authErrorNetwork => 'Impossible de joindre le serveur. Verifiez votre connexion.';

  @override
  String get authErrorTimeout => 'Le serveur met trop de temps a repondre. Veuillez reessayer.';

  @override
  String get authErrorInvalidCredentials => 'Email ou mot de passe invalide.';

  @override
  String get authErrorAccountPending => 'Votre compte est en attente de validation par un administrateur.';

  @override
  String get authErrorAccountRejected => 'Votre demande d acces a ete refusee. Contactez un administrateur de votre residence.';

  @override
  String get authErrorAccountArchived => 'Votre compte est archive. Contactez un administrateur de votre residence pour le reactiver.';

  @override
  String get authErrorEmailAlreadyUsed => 'Cette adresse email est deja utilisee.';

  @override
  String get authErrorInvalidResidenceCode => 'Le code residence est invalide.';

  @override
  String get authErrorInvalidCaptcha => 'La verification de securite a echoue. Veuillez recommencer.';

  @override
  String get authErrorInvalidRequest => 'Les informations saisies sont invalides. Verifiez le formulaire.';

  @override
  String get authErrorUnauthorized => 'Authentification requise. Veuillez vous reconnecter.';

  @override
  String get authPasswordMismatchMessage => 'Les mots de passe ne correspondent pas.';

  @override
  String get authLoginSuccess => 'Connexion reussie. Votre profil a ete charge depuis le backend.';

  @override
  String get authRegisterPageTitle => 'Inscription';

  @override
  String get authRegisterSuccessTitle => 'Votre compte a ete cree';

  @override
  String get authRegisterSuccessPending => 'Votre demande a ete creee. Un administrateur doit valider votre compte avant la connexion.';

  @override
  String get authRegisterSuccessGeneric => 'Demande d inscription envoyee avec succes.';

  @override
  String get authRegisterStepHousingIntro => 'Choisissez votre logement avec attention. Il est tres important de ne pas vous tromper. Votre demande sera validee par un administrateur.';

  @override
  String get authRegisterStepHousingSearch => 'Afficher les logements';

  @override
  String get authRegisterStepHousingTitle => 'Selectionnez votre logement';

  @override
  String get authRegisterStepHousingEmpty => 'Aucun logement disponible pour ce code residence.';

  @override
  String authRegisterStepHousingFull(Object maxOccupants) {
    return 'Ce logement a deja atteint sa capacite maximale de $maxOccupants residents. Vous ne pouvez pas continuer.';
  }

  @override
  String get authRegisterStepHousingFirstResident => 'Vous serez le premier resident inscrit sur ce logement. Cette inscription restera soumise a validation admin.';

  @override
  String authRegisterStepHousingOccupied(Object occupiedCount) {
    return '$occupiedCount resident(s) sont deja inscrits sur ce logement. Cette inscription restera soumise a validation admin.';
  }

  @override
  String get authRegisterStepNext => 'Suivant';

  @override
  String get authRegisterStepBack => 'Retour';

  @override
  String authRegisterHousingOccupancy(Object occupiedCount, Object maxOccupants) {
    return 'Occupants : $occupiedCount/$maxOccupants';
  }

  @override
  String get authRegisterHousingEdit => 'Modifier';

  @override
  String get authRegisterHousingCode => 'Code interne';

  @override
  String get authRegisterHousingStageTitle => 'Etape 1 • Logement';

  @override
  String get authRegisterProfileStageTitle => 'Etape 2 • Informations';

  @override
  String get authRegisterHousingStatusAvailable => 'Disponible';

  @override
  String get authRegisterHousingStatusFull => 'Complet';

  @override
  String get authRegisterHousingStatusActive => 'Actif';

  @override
  String get authRegisterHousingStatusPending => 'En attente';

  @override
  String get authRegisterHousingApplyFilters => 'Filtrer';

  @override
  String get authRegisterHousingResetFilters => 'Reinitialiser';

  @override
  String get authRegisterHousingSliderHint => 'Faites glisser le slider ou utilisez les fleches pour parcourir les logements.';

  @override
  String get authRegisterHousingChoose => 'Choisir';

  @override
  String get authRegisterHousingSelected => 'Selectionne';

  @override
  String get authRegisterHousingMaisonNumberLabel => 'Numero maison';

  @override
  String get authRegisterHousingCompositionMaisonOnly => 'Residence avec maisons uniquement';

  @override
  String get authRegisterHousingCompositionAppartementOnly => 'Residence avec appartements uniquement';

  @override
  String get authRegisterHousingCompositionMixed => 'Residence mixte maisons et appartements';

  @override
  String get authRegisterHousingCompositionEmpty => 'Aucun logement configure';

  @override
  String get authRegisterHousingFilterModeMaison => 'Filtre par numero';

  @override
  String get authRegisterHousingFilterModeAppartement => 'Filtres par immeuble et numero';

  @override
  String get authRegisterStepHousingEmptyFiltered => 'Aucun logement ne correspond aux filtres saisis.';

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
  String get authStatusArchived => 'Archive';

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
  String get paymentModeSelectorLabel => 'Affichage';

  @override
  String get paymentModeSelectorDescription => 'Choisissez les paiements a consulter depuis cette vue unique.';

  @override
  String get paymentModeMine => 'Paiements';

  @override
  String get paymentModeResident => 'Logement';

  @override
  String get paymentModePending => 'En attente';

  @override
  String get paymentResidentSearchTitle => 'Consulter les paiements de :';

  @override
  String get paymentResidentSearchBody => 'Selectionnez un logement de votre residence pour charger son suivi paiement, son paiement en attente et son historique.';

  @override
  String get paymentResidentEmailLabel => 'Logement';

  @override
  String get paymentResidentSearchButton => 'Rechercher';

  @override
  String get paymentResidentSearchHint => 'Choisissez un logement pour afficher son suivi paiement.';

  @override
  String get paymentResidentEmptyTitle => 'Aucun logement selectionne';

  @override
  String get paymentResidentEmptyBody => 'Selectionnez un logement pour afficher son statut, son paiement en attente, son suivi mensuel et son historique.';

  @override
  String paymentResidentViewing(Object email) {
    return 'Consultation des paiements du logement $email';
  }

  @override
  String get paymentResidentViewingDescription => 'Les donnees affichees correspondent au logement selectionne.';

  @override
  String get paymentResidentForbiddenError => 'Acces interdit a ce logement.';

  @override
  String get paymentHousingLoadErrorTitle => 'Impossible de charger les logements';

  @override
  String get paymentHousingEmptyTitle => 'Aucun logement disponible';

  @override
  String get paymentHousingEmptyBody => 'Aucun logement n est disponible pour cette residence.';

  @override
  String get paymentHousingStatusActive => 'Actif';

  @override
  String get paymentHousingStatusInactive => 'Inactif';

  @override
  String get paymentStatusOverdue => 'En retard';

  @override
  String get paymentStatusUpToDate => 'A jour';

  @override
  String get paymentStatusUnknown => 'Indisponible';

  @override
  String get paymentHeroLateTitle => 'Attention retard de paiement';

  @override
  String paymentHeroLateBody(Object date) {
    return 'Votre paiement a expire depuis le $date.';
  }

  @override
  String get paymentHeroHealthyTitle => 'Situation paiement stable';

  @override
  String paymentHeroHealthyBody(Object date) {
    return 'Vous etes a jour jusqu au $date.';
  }

  @override
  String get paymentHeroFallbackBody => 'Le statut paiement n est pas encore disponible.';

  @override
  String get paymentDueSoon => 'Votre paiement arrive bientot a echeance.';

  @override
  String get paymentPrimaryAction => 'Initier un paiement';

  @override
  String get paymentPendingLocksCreation => 'Un paiement est deja en attente. Vous ne pouvez pas en initier un autre tant qu il n a pas ete traite.';

  @override
  String get paymentPendingTitle => 'Paiement en attente';

  @override
  String get paymentPendingBody => 'Ce paiement attend encore la validation de l admin de la residence.';

  @override
  String get paymentOverdueCardTitle => 'Attention retard de paiement';

  @override
  String get paymentOverdueCardSubtitle => '';

  @override
  String get paymentOverdueMonthsLabel => 'Les derniers mois en retard :';

  @override
  String paymentOverdueManyMonthsMessage(Object count) {
    return 'Vous avez $count mois en retard. Merci de regulariser votre situation le plus rapidement possible.';
  }

  @override
  String get paymentOverdueRegularizeSoon => 'Merci de regulariser votre situation le plus rapidement possible.';

  @override
  String get paymentPendingAmount => 'Montant';

  @override
  String get paymentPendingMonths => 'Nombre de mois';

  @override
  String get paymentPendingPeriod => 'Periode';

  @override
  String paymentPendingMonthsValue(Object count) {
    return '$count mois';
  }

  @override
  String get paymentPendingHint => 'Merci de faire valider ce paiement par un administrateur de la residence.';

  @override
  String get paymentPendingSelfHint => 'Ce paiement apparaitra aussi dans la liste des paiements en attente afin que vous puissiez le valider.';

  @override
  String get paymentPendingEmptyTitle => 'Aucun paiement en attente';

  @override
  String get paymentPendingEmptyBody => 'Vous pouvez initier un nouveau paiement des qu une nouvelle periode doit etre couverte.';

  @override
  String get paymentDeletePending => 'Supprimer';

  @override
  String get paymentDeleteConfirmTitle => 'Supprimer le paiement en attente ?';

  @override
  String get paymentDeleteConfirmBody => 'Cette action supprimera uniquement le paiement encore en attente de validation.';

  @override
  String get paymentDeleteSuccess => 'Le paiement en attente a ete supprime.';

  @override
  String get paymentTimelineTitle => 'Suivi mensuel';

  @override
  String get paymentTimelineBody => 'Les mois impayes apparaissent en premier. Si tout est regle, les trois derniers mois payes restent visibles.';

  @override
  String get paymentTimelineEmptyTitle => 'Aucun mois a afficher';

  @override
  String get paymentTimelineEmptyBody => 'Le backend n a retourne aucun mois de suivi pour le moment.';

  @override
  String get paymentTimelineShowMore => 'Afficher plus';

  @override
  String paymentTimelineTooManyUnpaid(Object count) {
    return 'Vous avez au total $count mois non payes';
  }

  @override
  String get paymentMonthPaid => 'Paye';

  @override
  String get paymentMonthUnpaid => 'Non paye';

  @override
  String get paymentHistoryTitle => 'Historique';

  @override
  String get paymentHistoryBody => 'Retrouvez les derniers paiements valides et leur periode associee.';

  @override
  String get paymentHistoryEmptyTitle => 'Aucun historique disponible';

  @override
  String get paymentHistoryEmptyBody => 'Les paiements valides apparaitront ici des qu ils seront confirmes.';

  @override
  String get paymentDialogTitle => 'Initier un paiement';

  @override
  String get paymentDialogBody => 'Choisissez un mois de debut et le nombre de mois a payer. Le backend verifiera les chevauchements avant creation.';

  @override
  String paymentDialogBodyForResident(Object email) {
    return 'Vous allez initier un paiement pour le logement $email. Choisissez un mois de debut et le nombre de mois a payer. Le backend verifiera les chevauchements avant creation.';
  }

  @override
  String get paymentDialogStartMonth => 'Mois de debut';

  @override
  String get paymentDialogMonthCount => 'Nombre de mois';

  @override
  String paymentDialogMonthCountValue(Object count) {
    return '$count mois';
  }

  @override
  String get paymentDialogCancel => 'Annuler';

  @override
  String get paymentDialogSubmit => 'Confirmer la demande';

  @override
  String get paymentCreateSuccess => 'Le paiement a ete cree et attend maintenant une validation.';

  @override
  String paymentCreateSuccessForResident(Object email) {
    return 'Le paiement pour le logement $email a ete cree et attend maintenant une validation.';
  }

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
  String get paymentAdminPendingBody => 'Consultez et traitez les demandes de paiement des logements encore en attente de validation.';

  @override
  String get paymentAdminPendingEmptyTitle => 'Aucun paiement en attente';

  @override
  String get paymentAdminPendingEmptyBody => 'Aucun paiement en attente de validation pour les depenses partagees.';

  @override
  String get paymentAdminResidentEmail => 'Logement';

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
  String get paymentAdminValidateConfirmBody => 'Confirmez-vous avoir bien encaisse ce paiement ? Cette action mettra a jour la cagnotte.';

  @override
  String get paymentAdminValidateSuccess => 'Le paiement a ete valide.';

  @override
  String get paymentAdminRejectSuccess => 'Le paiement a ete rejete.';

  @override
  String get moduleExpenseTitle => 'Depense';

  @override
  String get moduleExpenseDescription => 'Base du module depense.';

  @override
  String get moduleExpenseScreenDescription => 'Vue depenses reliee aux endpoints backend reels de la residence.';

  @override
  String get expenseModeSelectorLabel => 'Types de depenses';

  @override
  String get expenseModeSelectorDescription => 'Choisissez la vue des depenses.';

  @override
  String get expenseModeCagnotte => 'Cagnotte';

  @override
  String get expenseModeShared => 'Partagee';

  @override
  String get expenseModePending => 'En attente';

  @override
  String get expenseModeSoon => 'Bientot';

  @override
  String get expenseCagnotteTitle => 'Depenses cagnotte';

  @override
  String get expenseCagnotteDescription => 'Depenses validees et payees par la cagnotte.';

  @override
  String get expenseSharedTitle => 'Depenses partagees';

  @override
  String get expenseSharedDescription => 'Suivez les depenses partagees approuvees, les montants deja rembourses et le detail logement par logement.';

  @override
  String get expenseSharedEmptyBody => 'Aucune depense partagee approuvee disponible.';

  @override
  String get expenseSharedPaidAmountLabel => 'Montant paye';

  @override
  String get expenseSharedAmountPerPersonLabel => 'Par logement';

  @override
  String get expenseSharedRemainingResidentsLabel => 'Logements restants non payes';

  @override
  String get expenseSharedStatusUnpaid => 'Non paye';

  @override
  String get expenseSharedStatusPartiallyPaid => 'Partiellement paye';

  @override
  String get expenseSharedStatusPaid => 'Paye';

  @override
  String get expenseSharedUnknownCreator => 'Admin inconnu';

  @override
  String get expenseSharedShowParticipants => 'Afficher les logements';

  @override
  String get expenseSharedHideParticipants => 'Masquer les logements';

  @override
  String expenseSharedCreatedBy(Object name) {
    return 'Cree par : $name';
  }

  @override
  String expenseSharedParticipantsCount(Object count) {
    return '$count logements';
  }

  @override
  String expenseSharedParticipantAmountSummary(Object paid, Object due) {
    return '$paid paye sur $due';
  }

  @override
  String get expenseCategoryFilterLabel => 'Filtrer par categorie';

  @override
  String get expenseCategoryAll => 'Toutes les categories';

  @override
  String get expenseCategoryUnknown => 'Categorie non renseignee';

  @override
  String get expenseCreatedAtLabel => 'Creation';

  @override
  String get expenseValidatedAtLabel => 'Validation';

  @override
  String get expenseEmptyTitle => 'Aucune depense disponible';

  @override
  String get expenseEmptyBody => 'Aucune depense cagnotte approuvee disponible.';

  @override
  String get expenseErrorTitle => 'Impossible de charger la vue depenses.';

  @override
  String get expenseForbiddenError => 'Acces interdit aux depenses de cette residence.';

  @override
  String get expenseNotFoundError => 'La ressource depense demandee est introuvable.';

  @override
  String get expenseRefreshTooltip => 'Rafraichir la vue depenses';

  @override
  String get expenseCreateAction => 'Creer une depense';

  @override
  String get expenseCreateDialogTitle => 'Nouvelle depense cagnotte';

  @override
  String get expenseCreateDialogBody => 'Renseignez la categorie, le montant et une description. La depense sera creee en attente.';

  @override
  String get expenseCreateCategoryLabel => 'Categorie';

  @override
  String get expenseCreateCategoryError => 'Selectionnez une categorie.';

  @override
  String get expenseCreateAmountLabel => 'Montant';

  @override
  String get expenseCreateAmountError => 'Saisissez un montant valide.';

  @override
  String get expenseCreateDescriptionLabel => 'Description';

  @override
  String get expenseCreateDescriptionError => 'Saisissez une description.';

  @override
  String get expenseCreateSubmit => 'Creer la depense';

  @override
  String get expenseCreateSuccess => 'La depense a ete creee en attente.';

  @override
  String get expenseSharedCreateAction => 'Creer une depense partagee';

  @override
  String get expenseSharedCreateDialogTitle => 'Nouvelle depense partagee';

  @override
  String get expenseSharedCreateDialogBody => 'Cette depense partagee ne sera pas financee par la cagnotte. Les logements actifs de la residence devront cotiser pour la regler. La depense sera creee en attente.';

  @override
  String get expenseSharedParticipantsLabel => 'Nombre de logements actifs';

  @override
  String get expenseSharedTotalAmountLabel => 'Montant total de la depense';

  @override
  String get expenseSharedEstimatedAmountPerPersonLabel => 'Montant estime par logement';

  @override
  String get expenseSharedEstimatedAmountPlaceholder => 'Saisissez le montant total';

  @override
  String get expenseSharedCreateSubmit => 'Creer la depense partagee';

  @override
  String get expenseSharedCreateSuccess => 'La depense partagee a ete creee en attente.';

  @override
  String get moduleVoteTitle => 'Vote';

  @override
  String get moduleVoteDescription => 'Gestion des votes de la residence.';

  @override
  String get moduleVoteScreenDescription => 'Consultez les votes de la residence, suivez la participation en direct et laissez chaque occupant exprimer son choix.';

  @override
  String get voteRefreshTooltip => 'Rafraichir la vue votes';

  @override
  String get voteInfoTitle => 'Votes de la residence';

  @override
  String get voteInfoBody => 'Les votes sont crees par un administrateur. Chaque resident actif peut voter et les resultats restent visibles en temps reel sans jamais exposer le choix individuel par logement.';

  @override
  String get voteInfoAdminCreated => 'Creation admin';

  @override
  String get voteInfoResidentVotes => 'Participation residents';

  @override
  String get voteInfoVisibleResults => 'Resultats visibles';

  @override
  String get voteCreateTooltip => 'Creer un vote';

  @override
  String get voteStatusOpen => 'En cours';

  @override
  String get voteStatusClosed => 'Termine';

  @override
  String get voteEstimatedAmountLabel => 'Montant estime';

  @override
  String get voteStartDateLabel => 'Debut';

  @override
  String get voteEndDateLabel => 'Fin';

  @override
  String get voteCreatedByLabel => 'Cree par';

  @override
  String get voteResultsSectionTitle => 'Resultat en direct';

  @override
  String voteParticipantsSummary(Object count, Object total) {
    return '$count/$total votants';
  }

  @override
  String voteTurnoutLabel(Object count, Object total) {
    return '$count vote(s) enregistres sur $total votants eligibles';
  }

  @override
  String voteLeadingPour(Object count) {
    return 'Le oui mene avec $count vote(s).';
  }

  @override
  String voteLeadingContre(Object count) {
    return 'Le non mene avec $count vote(s).';
  }

  @override
  String voteLeadingNeutre(Object count) {
    return 'Le neutre mene avec $count vote(s).';
  }

  @override
  String get voteLeadingTie => 'Egalite pour le moment entre les options principales.';

  @override
  String get voteLeadingNone => 'Aucun vote n a encore ete enregistre.';

  @override
  String get voteChoicePour => 'Oui';

  @override
  String get voteChoiceContre => 'Non';

  @override
  String get voteChoiceNeutre => 'Neutre';

  @override
  String get voteChoiceUnknown => 'Inconnu';

  @override
  String get voteActionPour => 'Voter oui';

  @override
  String get voteActionContre => 'Voter non';

  @override
  String get voteActionNeutre => 'Voter neutre';

  @override
  String voteAlreadyVoted(Object choice) {
    return 'Votre vote a deja ete enregistre : $choice.';
  }

  @override
  String get voteClosedMessage => 'Ce vote est termine. Les resultats restent consultables.';

  @override
  String get voteHousingSectionTitle => 'Participation par logement';

  @override
  String voteHousingSectionSubtitle(Object count) {
    return '$count logement(s) suivis';
  }

  @override
  String get voteHousingVoted => 'Vote enregistre';

  @override
  String get voteHousingNotVoted => 'Aucun vote enregistre';

  @override
  String voteHousingParticipationValue(Object count, Object total) {
    return '$count/$total';
  }

  @override
  String get voteEmptyTitle => 'Aucun vote disponible';

  @override
  String get voteEmptyBody => 'Les votes crees par les administrateurs apparaitront ici des qu ils seront publies.';

  @override
  String get voteErrorTitle => 'Impossible de charger la vue votes.';

  @override
  String get voteRetryAction => 'Reessayer';

  @override
  String get voteForbiddenError => 'Acces interdit aux votes de cette residence.';

  @override
  String get voteNotFoundError => 'Le vote demande est introuvable.';

  @override
  String get voteCreateDialogTitle => 'Creer un vote';

  @override
  String get voteCreateDialogBody => 'Renseignez un titre, une description, un montant estime et la periode de vote. Le vote sera aussitot visible dans la residence.';

  @override
  String get voteFieldTitle => 'Titre';

  @override
  String get voteFieldTitleError => 'Saisissez un titre.';

  @override
  String get voteFieldDescription => 'Description courte';

  @override
  String get voteFieldDescriptionError => 'Saisissez une description.';

  @override
  String get voteFieldEstimatedAmount => 'Montant estime';

  @override
  String get voteFieldStartDate => 'Date de debut';

  @override
  String get voteFieldEndDate => 'Date de fin';

  @override
  String get voteDateRangeError => 'La date de fin doit etre apres la date de debut.';

  @override
  String get voteCancelAction => 'Annuler';

  @override
  String get voteCreateAction => 'Creer';

  @override
  String get voteCreateSuccess => 'Le vote a ete cree avec succes.';

  @override
  String get voteSubmitSuccess => 'Votre vote a ete enregistre.';

  @override
  String get voteCreateExpenseAction => 'Creer une depense';

  @override
  String get voteExpenseConfirmDialogTitle => 'Confirmer la creation de la depense';

  @override
  String get voteExpenseConfirmDialogBody => 'Voulez-vous vraiment creer une depense en attente a partir de ce vote ?';

  @override
  String get voteExpenseCreateSuccess => 'La depense a ete creee en attente a partir du vote.';

  @override
  String get voteExpenseAlreadyCreated => 'Depense deja creee';

  @override
  String voteEndingSoon(Object days) {
    return 'Attention fin des votes dans $days jour(s).';
  }

  @override
  String get voteCommentDialogTitle => 'Ajouter un commentaire';

  @override
  String get voteCommentDialogBody => 'Voulez-vous saisir un commentaire ? Si vous n\'en avez pas, laissez le champ vide.';

  @override
  String get voteCommentFieldLabel => 'Commentaire optionnel';

  @override
  String get voteCommentSubmitAction => 'Valider le vote';

  @override
  String voteCommentRemainingCharacters(int count) {
    return '$count caractere(s) restants';
  }

  @override
  String get voteCurrentUserCommentLabel => 'Votre commentaire';

  @override
  String get voteAdminCommentsSectionTitle => 'Commentaires';

  @override
  String get voteAdminCommentsVisible => 'commentaires visibles';

  @override
  String get voteAdminCommentsLoading => 'chargement des commentaires';

  @override
  String get moduleSettingsTitle => 'Residence';

  @override
  String get moduleSettingsDescription => 'Vue residence centree logement.';

  @override
  String get moduleSettingsScreenDescription => 'Point d entree de la vue residence, alimentee par l endpoint backend agrege.';

  @override
  String get moduleUsersAdminTitle => 'Vue residence admin';

  @override
  String get moduleUsersAdminDescription => 'Les administrateurs pilotent les logements, les occupants et les demandes en attente.';

  @override
  String get moduleUsersAdminBody => 'Consultez le resume de la residence, les cartes logement, les occupants, le statut paiement et les demandes en attente sans reconstruire la logique metier cote mobile.';

  @override
  String get moduleUsersUserTitle => 'Vue residence';

  @override
  String get moduleUsersUserDescription => 'Les utilisateurs consultent leur residence a travers les logements.';

  @override
  String get moduleUsersUserBody => 'Retrouvez une vue simple et moderne de la residence : logements, occupants, activations et statut paiement.';

  @override
  String get usersRefreshTooltip => 'Rafraichir la vue residents';

  @override
  String get usersEditProfileAction => 'Modifier mon profil';

  @override
  String get usersAdminViewLabel => 'Affichage admin';

  @override
  String get usersResidentsTab => 'Logements';

  @override
  String get usersPendingTab => 'En attente';

  @override
  String get usersSearchLabel => 'Recherche logement';

  @override
  String get usersSearchHint => 'Rechercher par numero, immeuble, code interne ou adresse';

  @override
  String get usersLoadErrorTitle => 'Impossible de charger les residents.';

  @override
  String get usersResidentsEmptyTitle => 'Aucun logement a afficher';

  @override
  String get usersResidentsEmptyBody => 'Aucun logement ne correspond a la recherche actuelle.';

  @override
  String get usersPendingEmptyTitle => 'Aucune demande en attente';

  @override
  String get usersPendingEmptyBody => 'Les nouvelles demandes d inscription apparaitront ici logement par logement.';

  @override
  String get usersCurrentSectionTitle => 'Votre logement';

  @override
  String get usersAdminsSectionTitle => 'Logements admin';

  @override
  String get usersLateSectionTitle => 'Logements en retard';

  @override
  String get usersOthersSectionTitle => 'Autres logements';

  @override
  String get usersResidenceEntryDateLabel => 'Entree dans la residence';

  @override
  String get usersActionsTooltip => 'Actions resident';

  @override
  String get usersEditDateAction => 'Modifier la date d entree';

  @override
  String get usersPromoteToAdminAction => 'Passer admin';

  @override
  String get usersDemoteToUserAction => 'Passer resident';

  @override
  String get usersDeleteAction => 'Supprimer';

  @override
  String get usersPendingCardBody => 'Ce compte attend encore la validation d un administrateur de la residence.';

  @override
  String get usersCreatedAtLabel => 'Cree le';

  @override
  String get usersApproveAction => 'Valider';

  @override
  String get usersRejectAction => 'Rejeter';

  @override
  String get usersApproveConfirmTitle => 'Valider cet utilisateur ?';

  @override
  String get usersApproveConfirmBody => 'Confirmez-vous la validation de cet utilisateur ?';

  @override
  String get usersApproveSuccess => 'L utilisateur a ete valide.';

  @override
  String get usersRejectSuccess => 'L utilisateur a ete rejete.';

  @override
  String get usersDeleteConfirmTitle => 'Supprimer cet utilisateur ?';

  @override
  String usersDeleteConfirmBody(Object email) {
    return 'Le compte $email sera supprime de la residence.';
  }

  @override
  String get usersDeleteSuccess => 'L utilisateur a ete supprime.';

  @override
  String get usersRoleChangeConfirmTitle => 'Modifier le role de cet utilisateur ?';

  @override
  String usersRoleChangeConfirmBody(Object email, Object roleLabel) {
    return '$email passera au role $roleLabel.';
  }

  @override
  String get usersRoleUpdatedSuccess => 'Le role de l utilisateur a ete mis a jour.';

  @override
  String get usersEditProfileDialogTitle => 'Modifier mon profil';

  @override
  String get usersFirstNameLabel => 'Prenom';

  @override
  String get usersLastNameLabel => 'Nom';

  @override
  String get usersSaveAction => 'Enregistrer';

  @override
  String get usersProfileUpdatedSuccess => 'Le profil a ete mis a jour.';

  @override
  String get usersDateUpdatedSuccess => 'La date d entree a ete mise a jour.';

  @override
  String get usersOverviewTitle => 'Résumé de la résidence';

  @override
  String get usersSummaryCurrentFund => 'Etat de la cagnotte';

  @override
  String get usersSummaryTotalHousing => 'Total logements';

  @override
  String get usersSummaryActiveHousing => 'actifs';

  @override
  String get usersSummaryInactiveHousing => 'inactifs';

  @override
  String get usersSummaryResidents => 'Residents lies';

  @override
  String get usersSummaryAdminSplit => 'Admins';

  @override
  String get usersSummaryPaymentStatus => 'Logements a jour';

  @override
  String get usersSummaryLateHousing => 'en retard';

  @override
  String get usersFundPositive => 'Cagnotte positive';

  @override
  String get usersFundNegative => 'Cagnotte negative';

  @override
  String get usersFundNeutral => 'Cagnotte neutre';

  @override
  String get usersPaymentStatusInactive => 'Inactif';

  @override
  String usersHousingOccupancyValue(Object occupied, Object max) {
    return '$occupied/$max';
  }

  @override
  String get usersHousingTypeLabel => 'Type logement';

  @override
  String get usersHousingFloorLabel => 'Etage';

  @override
  String get usersHousingPaymentUntilLabel => 'Paiement couvert jusqu au';

  @override
  String get usersHousingOverdueMonthsLabel => 'Mois en retard';

  @override
  String usersHousingResidentsSubtitle(Object count) {
    return '$count occupant(s) affiches';
  }

  @override
  String get usersHousingResidentsSection => 'Occupants du logement';

  @override
  String get usersHousingExistingResidentsSection => 'Occupants deja inscrits';

  @override
  String get usersHousingPendingResidentsSection => 'Nouveaux usagers en attente';

  @override
  String get usersHousingNoResidentsTitle => 'Aucun occupant actif';

  @override
  String get usersHousingNoResidentsBody => 'Aucun resident actif n est encore rattache a ce logement.';

  @override
  String get usersPendingPaymentLabel => 'Paiement en attente';

  @override
  String get usersCurrentResidentTag => 'Vous';

  @override
  String get moduleResidenceTitle => 'Residence';

  @override
  String get moduleResidenceDescription => 'Base du module residence.';

  @override
  String get moduleResidenceScreenDescription => 'Point d entree du module residence. Les futurs ecrans utiliseront l API backend reelle sans deplacer la logique metier cote frontend.';

  @override
  String get cagnotteDialogTitle => 'Detail des mouvements de cagnotte';

  @override
  String get cagnotteDialogBody => 'Les derniers mouvements sont affiches en premier.';

  @override
  String get cagnotteDialogLegendContribution => 'Contribution';

  @override
  String get cagnotteDialogLegendExpense => 'Depense';

  @override
  String get cagnotteDialogErrorTitle => 'Impossible de charger la cagnotte';

  @override
  String get cagnotteDialogEmptyTitle => 'Aucun mouvement de cagnotte';

  @override
  String get cagnotteDialogEmptyBody => 'Aucun mouvement n est disponible pour cette residence.';

  @override
  String get cagnotteDialogHousingColumn => 'Logement (code interne)';

  @override
  String get cagnotteDialogTypeColumn => 'Type';

  @override
  String get cagnotteDialogAmountColumn => 'Montant';

  @override
  String get cagnotteDialogDateColumn => 'Date';

  @override
  String get cagnotteDialogHousingUnavailable => '-';

  @override
  String get accountMenuTooltip => 'Ouvrir le menu du compte';

  @override
  String get accountMenuProfile => 'Mes donnees personnelles';

  @override
  String get accountMenuResidenceData => 'Donnees de la residence';

  @override
  String get accountMenuManageUsers => 'Gerer les utilisateurs';

  @override
  String get accountMenuLanguage => 'Langue';

  @override
  String accountMenuSubtitle(Object name) {
    return 'Connecte en tant que $name';
  }

  @override
  String get accountMenuSubtitleFallback => 'Gerez votre compte et la langue de l application';

  @override
  String get accountSettingsTitle => 'Mes donnees personnelles';

  @override
  String get accountSettingsSubtitle => 'Mettez a jour les informations visibles de votre profil et changez votre mot de passe si besoin depuis cette meme fenetre.';

  @override
  String get accountSettingsIdentitySection => 'Identite';

  @override
  String get accountSettingsPasswordSection => 'Mot de passe';

  @override
  String get accountSettingsPasswordHint => 'Laissez les champs mot de passe vides si vous ne souhaitez pas le modifier.';

  @override
  String get accountSettingsCurrentPassword => 'Mot de passe actuel';

  @override
  String get accountSettingsNewPassword => 'Nouveau mot de passe';

  @override
  String get accountSettingsPasswordRequiredFields => 'Renseignez le mot de passe actuel, le nouveau mot de passe et la confirmation pour changer votre mot de passe.';

  @override
  String get accountSettingsPasswordMinLength => 'Au moins 8 caracteres';

  @override
  String get accountSettingsPasswordUppercase => 'Au moins une majuscule';

  @override
  String get accountSettingsPasswordLowercase => 'Au moins une minuscule';

  @override
  String get accountSettingsPasswordSpecialCharacter => 'Au moins un caractere special';

  @override
  String get accountSettingsPasswordConfirmation => 'Les mots de passe correspondent';

  @override
  String get userRecoveryDialogSubtitle => 'Retrouvez les comptes refuses ou archives et reactivez-les en un clic. Chaque reactivation repasse le compte en actif et declenche l email d information backend.';

  @override
  String get userRecoveryRejectedTab => 'Rejected';

  @override
  String get userRecoveryArchivedTab => 'Archived';

  @override
  String get userRecoveryReactivateAction => 'Reactiver';

  @override
  String get userRecoveryReactivateConfirmTitle => 'Reactiver cet utilisateur ?';

  @override
  String userRecoveryReactivateConfirmBody(Object email) {
    return 'Le compte $email repassera en actif et recevra un email d information.';
  }

  @override
  String get userRecoveryReactivateSuccess => 'L utilisateur a ete reactive.';

  @override
  String get userRecoveryHousingUnknown => 'Logement non renseigne';

  @override
  String get userRecoveryRejectedEmptyTitle => 'Aucun compte rejected';

  @override
  String get userRecoveryRejectedEmptyBody => 'Aucun utilisateur refuse n attend une reactivation pour le moment.';

  @override
  String get userRecoveryArchivedEmptyTitle => 'Aucun compte archived';

  @override
  String get userRecoveryArchivedEmptyBody => 'Aucun utilisateur archive n attend une reactivation pour le moment.';

  @override
  String get userRecoveryLoadErrorTitle => 'Impossible de charger les comptes a reactiver';

  @override
  String get residenceAdminSettingsSubtitle => 'Consultez les informations actuelles de la residence et mettez-les a jour si necessaire.';

  @override
  String get residenceAdminSettingsSection => 'Informations de la residence';

  @override
  String get residenceAdminSettingsNameLabel => 'Nom';

  @override
  String get residenceAdminSettingsNameError => 'Renseignez le nom de la residence.';

  @override
  String get residenceAdminSettingsAddressLabel => 'Adresse';

  @override
  String get residenceAdminSettingsAddressError => 'Renseignez l adresse de la residence.';

  @override
  String get residenceAdminSettingsCodeLabel => 'Code residence';

  @override
  String get residenceAdminSettingsCodeError => 'Renseignez le code residence.';

  @override
  String get residenceAdminSettingsMonthlyAmountLabel => 'Montant mensuel';

  @override
  String get residenceAdminSettingsMonthlyAmountError => 'Saisissez un montant mensuel valide.';

  @override
  String get residenceAdminSettingsMaxOccupantsLabel => 'Max occupants par logement';

  @override
  String residenceAdminSettingsOccupantsValue(Object count) {
    return '$count occupant(s)';
  }

  @override
  String get residenceAdminSettingsUpdatedSuccess => 'Les donnees de la residence ont ete mises a jour.';

  @override
  String get accountLanguageTitle => 'Langue';

  @override
  String get accountLanguageSubtitle => 'Seules les langues deja supportees par l application sont disponibles ici.';

  @override
  String get languageSwitcherTooltip => 'Changer la langue';

  @override
  String get languageFrench => 'Francais';

  @override
  String get languageEnglish => 'Anglais';
}

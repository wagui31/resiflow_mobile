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

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Habit Tracker';

  @override
  String get homeTitle => 'Habitudes';

  @override
  String get homeSettingsTooltip => 'Paramètres';

  @override
  String get homeAddHabitTooltip => 'Ajouter une habitude';

  @override
  String get consentDialogTitle =>
      'Partager des données d\'utilisation anonymes ?';

  @override
  String get consentDialogBody =>
      'Aidez-nous à améliorer Habit Tracker en partageant des métriques d\'utilisation anonymisées et des rapports de plantage. Vous pourrez modifier ce choix plus tard dans les Paramètres.';

  @override
  String get consentNotNow => 'Pas maintenant';

  @override
  String get consentShare => 'Partager';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsPrivacySection => 'Confidentialité et données';

  @override
  String get settingsAnalyticsToggle =>
      'Partager des analyses d\'utilisation anonymes';

  @override
  String get settingsAnalyticsSubtitle =>
      'Nous aide à comprendre quelles fonctionnalités sont les plus utiles.';

  @override
  String get settingsCrashToggle => 'Partager les rapports de plantage';

  @override
  String get settingsCrashSubtitle =>
      'Envoie des journaux de plantage anonymisés pour nous aider à corriger les problèmes plus rapidement.';

  @override
  String get settingsNotificationsSection => 'Notifications';

  @override
  String get settingsNotificationsToggle => 'Rappels quotidiens';

  @override
  String get settingsNotificationsSubtitle =>
      'Recevez un rappel utile pour accomplir les habitudes du jour.';

  @override
  String get settingsNotificationTimeTitle => 'Heure du rappel';

  @override
  String settingsNotificationTimeSubtitle(String time) {
    return 'Actuellement $time';
  }

  @override
  String get settingsAppearanceSection => 'Apparence';

  @override
  String get settingsThemeLabel => 'Mode de thème';

  @override
  String get settingsThemeLabelSystem => 'Par défaut du système';

  @override
  String get settingsThemeLabelLight => 'Clair';

  @override
  String get settingsThemeLabelDark => 'Sombre';

  @override
  String get settingsThemeDescriptionSystem =>
      'Suit automatiquement l\'apparence de l\'appareil';

  @override
  String get settingsThemeDescriptionLight =>
      'Toujours utiliser le thème clair';

  @override
  String get settingsThemeDescriptionDark =>
      'Toujours utiliser le thème sombre';

  @override
  String get settingsLanguageSection => 'Langue';

  @override
  String get settingsLanguageSystem => 'Suivre la langue du système';

  @override
  String get settingsLanguageEnglish => 'Anglais';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageDescriptionSystem =>
      'L\'application suit automatiquement la langue de votre appareil.';

  @override
  String settingsLanguageDescription(String language) {
    return 'Langue de l\'application : $language';
  }

  @override
  String get htmlThemeLabel => 'Thème du contenu';

  @override
  String get htmlThemeOptionSystem => 'Suivre le thème de l\'application';

  @override
  String get htmlThemeOptionLight => 'Clair';

  @override
  String get htmlThemeOptionDark => 'Sombre';

  @override
  String get settingsAboutSection => 'À propos';

  @override
  String get settingsReleaseNotes => 'Notes de version';

  @override
  String get settingsReleaseNotesSubtitle =>
      'Découvrez les changements de chaque version';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Comment nous traitons vos données';

  @override
  String settingsVersionLabel(String version, String build) {
    return 'v$version.$build - nom de version et numéro de build';
  }

  @override
  String get releaseNotesTitle => 'Notes de version';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get onboardingSkip => 'Ignorer';

  @override
  String get onboardingTagline =>
      'Construisez de meilleures routines un jour à la fois';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingGoal => 'Suivez jusqu\'à trois habitudes quotidiennes';

  @override
  String get onboardingHabitsTitle => 'Choisissez vos habitudes de départ';

  @override
  String get onboardingHabitsSubtitle =>
      'Sélectionnez jusqu\'à trois habitudes pour lancer votre routine.';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingSelectionHint =>
      'Vous pourrez ajouter ou modifier des habitudes plus tard depuis le tableau de bord.';

  @override
  String get onboardingNotificationsTitle =>
      'Restez sur la bonne voie avec des rappels';

  @override
  String get onboardingNotificationsSubtitle =>
      'Activez les rappels pour que nous puissions vous encourager à tenir vos séries.';

  @override
  String get onboardingEnableReminders => 'Activer les rappels';

  @override
  String get onboardingMaybeLater => 'Plus tard';

  @override
  String get onboardingNotificationsGranted =>
      'Les rappels sont activés ! Nous vous enverrons un petit rappel chaque jour.';

  @override
  String get onboardingNotificationsDenied =>
      'Pas de souci ! Vous pourrez activer les rappels plus tard dans les paramètres.';

  @override
  String get onboardingFinishTitle => 'Vous êtes prêt·e à commencer !';

  @override
  String get onboardingFinishCta => 'Aller au tableau de bord';

  @override
  String onboardingError(String message) {
    return 'Un problème est survenu : $message';
  }

  @override
  String get onboardingHabitMeditate => 'Méditer';

  @override
  String get onboardingHabitWalk => 'Marcher';

  @override
  String get onboardingHabitHydrate => 'Boire de l\'eau';

  @override
  String get onboardingHabitJournal => 'Écrire dans mon journal';

  @override
  String get onboardingHabitStretch => 'M\'étirer';

  @override
  String get onboardingHabitRead => 'Lire';
}

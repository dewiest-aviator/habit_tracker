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
  String get homeTodayTitle => 'Aujourd\'hui';

  @override
  String get homeTodayHeadline => 'Habitudes du jour';

  @override
  String get homeSettingsTooltip => 'Paramètres';

  @override
  String get homeAddHabitTooltip => 'Ajouter une habitude';

  @override
  String homeProgressSummary(int completed, int total) {
    return 'Vous avez terminé $completed sur $total habitudes aujourd\'hui';
  }

  @override
  String get homeEmptyTitle => 'Ajoutez votre première habitude';

  @override
  String get homeEmptySubtitle =>
      'Commencez en créant jusqu\'à trois habitudes quotidiennes à suivre.';

  @override
  String get homeEmptyCta => 'Créer une habitude';

  @override
  String get homeMarkCompleteTooltip => 'Marquer comme faite';

  @override
  String get homeMarkIncompleteTooltip => 'Marquer comme non faite';

  @override
  String homeCurrentStreakLabel(int count) {
    return 'Série de $count jour(s)';
  }

  @override
  String homeBestStreakLabel(int count) {
    return 'Meilleure série : $count jours';
  }

  @override
  String homeCompletionSnackbar(String habitName) {
    return 'Habitude $habitName marquée comme faite.';
  }

  @override
  String homeUndoSnackbar(String habitName) {
    return 'Habitude $habitName marquée comme non faite.';
  }

  @override
  String homeEditHabitLabel(String habitName) {
    return 'Modifier $habitName';
  }

  @override
  String homeUndoHabitLabel(String habitName) {
    return 'Annuler pour $habitName';
  }

  @override
  String get navHomeLabel => 'Accueil';

  @override
  String get navHistoryLabel => 'Historique';

  @override
  String get navSettingsLabel => 'Paramètres';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historyPlaceholder =>
      'Votre historique de séries apparaîtra bientôt ici.';

  @override
  String get historyEmptyTitle => 'Aucun historique pour le moment';

  @override
  String get historyEmptyMessage =>
      'Terminez vos habitudes pour construire votre chronologie.';

  @override
  String get historyEmptyCta => 'Commencez à suivre aujourd\'hui !';

  @override
  String get historyFilterLabel => 'Filtrer par habitude';

  @override
  String get historyFilterAll => 'Toutes les habitudes';

  @override
  String get historyStreakHeading => 'Résumé des séries';

  @override
  String get historyStreakBest => 'Meilleure série';

  @override
  String get historyStreakCurrent => 'Série en cours';

  @override
  String historyCompletionLabel(int completed, int total) {
    return '$completed sur $total accomplies';
  }

  @override
  String get historyNoHabitsForDay => 'Aucune habitude prévue ce jour-là.';

  @override
  String get habitFormCreateTitle => 'Créer une habitude';

  @override
  String get habitFormEditTitle => 'Modifier une habitude';

  @override
  String get habitFormCreatePlaceholder =>
      'Le formulaire d\'habitudes arrivera dans une prochaine mise à jour.';

  @override
  String get habitFormEditPlaceholder =>
      'La modification des habitudes sera bientôt disponible.';

  @override
  String get habitFormEmojiLabel => 'Emoji';

  @override
  String get habitFormEmojiPlaceholder => 'Touchez pour choisir';

  @override
  String get habitFormNameLabel => 'Nom de l\'habitude';

  @override
  String get habitFormNameHelper =>
      'Gardez un intitulé court et orienté action.';

  @override
  String get habitFormNameRequiredError =>
      'Saisissez un nom d\'au moins 2 caractères.';

  @override
  String get habitFormNameLengthError =>
      'Le nom doit contenir entre 2 et 32 caractères.';

  @override
  String get habitFormEmojiRequiredError =>
      'Choisissez un emoji pour représenter l\'habitude.';

  @override
  String get habitFormColorLabel => 'Couleur d\'accent';

  @override
  String get habitFormColorDescription =>
      'Utilisée dans les listes et les rappels.';

  @override
  String get habitFormDaysLabel => 'Jours de la semaine';

  @override
  String get habitFormDaysHelper =>
      'Sélectionnez au moins un jour pour pratiquer cette habitude.';

  @override
  String get habitFormDaysError => 'Choisissez au moins un jour.';

  @override
  String get habitFormReminderLabel => 'Rappel quotidien';

  @override
  String get habitFormReminderSubtitle =>
      'Activez les notifications pour rester motivé.';

  @override
  String get habitFormReminderTimeLabel => 'Heure du rappel';

  @override
  String get habitFormReminderTimeHelper =>
      'Nous vous rappellerons à cette heure les jours sélectionnés.';

  @override
  String get habitFormReminderTimeError =>
      'Sélectionnez une heure de rappel valide.';

  @override
  String get habitFormReminderPermissionDenied =>
      'Impossible d\'activer les rappels sans autorisation de notification.';

  @override
  String get habitFormLimitError =>
      'Vous pouvez suivre jusqu\'à trois habitudes simultanément.';

  @override
  String get habitFormCreateHabit => 'Créer l\'habitude';

  @override
  String get habitFormSaveChanges => 'Enregistrer les modifications';

  @override
  String get habitFormDeleteTooltip => 'Supprimer l\'habitude';

  @override
  String get habitFormDeleteConfirmTitle => 'Supprimer l\'habitude ?';

  @override
  String get habitFormDeleteConfirmMessage =>
      'Cela supprimera l\'habitude et son historique.';

  @override
  String get habitFormDeleteCancel => 'Annuler';

  @override
  String get habitFormDeleteConfirmAction => 'Supprimer';

  @override
  String get habitFormDeleteError =>
      'Impossible de supprimer l\'habitude. Réessayez.';

  @override
  String get habitFormDeleteSuccess => 'Habitude supprimée.';

  @override
  String get habitFormDiscardTitle => 'Annuler les modifications ?';

  @override
  String get habitFormDiscardMessage =>
      'Vous avez des modifications non enregistrées. Voulez-vous vraiment quitter ?';

  @override
  String get habitFormDiscardCancel => 'Continuer';

  @override
  String get habitFormDiscardConfirm => 'Annuler';

  @override
  String get habitFormReminderFallbackName => 'votre habitude';

  @override
  String habitFormReminderTitle(String emoji, String name) {
    return '$emoji $name';
  }

  @override
  String habitFormReminderBody(String name) {
    return 'Il est temps de faire $name.';
  }

  @override
  String get habitFormCreateSuccess => 'Habitude créée avec succès.';

  @override
  String get habitFormUpdateSuccess => 'Habitude mise à jour avec succès.';

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

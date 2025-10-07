// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Habit Tracker';

  @override
  String get homeTitle => 'Habits';

  @override
  String get homeTodayTitle => 'Today';

  @override
  String get homeTodayHeadline => 'Today\'s habits';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get homeAddHabitTooltip => 'Add habit';

  @override
  String homeProgressSummary(int completed, int total) {
    return 'You\'ve completed $completed of $total habits today';
  }

  @override
  String get homeEmptyTitle => 'Add your first habit';

  @override
  String get homeEmptySubtitle =>
      'Start by creating up to three daily habits to track.';

  @override
  String get homeEmptyCta => 'Create a habit';

  @override
  String get homeMarkCompleteTooltip => 'Mark as done';

  @override
  String get homeMarkIncompleteTooltip => 'Mark as not done';

  @override
  String homeCurrentStreakLabel(int count) {
    return '$count day streak';
  }

  @override
  String homeBestStreakLabel(int count) {
    return 'Best $count days';
  }

  @override
  String homeCompletionSnackbar(String habitName) {
    return 'Marked $habitName as done.';
  }

  @override
  String homeUndoSnackbar(String habitName) {
    return 'Marked $habitName as not done.';
  }

  @override
  String homeEditHabitLabel(String habitName) {
    return 'Edit $habitName';
  }

  @override
  String homeUndoHabitLabel(String habitName) {
    return 'Undo completion for $habitName';
  }

  @override
  String get navHomeLabel => 'Home';

  @override
  String get navHistoryLabel => 'History';

  @override
  String get navSettingsLabel => 'Settings';

  @override
  String get historyTitle => 'History';

  @override
  String get historyPlaceholder => 'Your streak history will appear here soon.';

  @override
  String get historyEmptyTitle => 'No history yet';

  @override
  String get historyEmptyMessage =>
      'Complete your habits to build your timeline.';

  @override
  String get historyEmptyCta => 'Start tracking today!';

  @override
  String get historyFilterLabel => 'Filter by habit';

  @override
  String get historyFilterAll => 'All habits';

  @override
  String get historyStreakHeading => 'Streak summary';

  @override
  String get historyStreakBest => 'Best streak';

  @override
  String get historyStreakCurrent => 'Current streak';

  @override
  String historyCompletionLabel(int completed, int total) {
    return '$completed of $total complete';
  }

  @override
  String get historyNoHabitsForDay => 'No scheduled habits for this day.';

  @override
  String get habitFormCreateTitle => 'Create habit';

  @override
  String get habitFormEditTitle => 'Edit habit';

  @override
  String get habitFormCreatePlaceholder =>
      'The habit form will live here in a future update.';

  @override
  String get habitFormEditPlaceholder => 'Editing habits is coming soon.';

  @override
  String get habitFormEmojiLabel => 'Emoji';

  @override
  String get habitFormEmojiPlaceholder => 'Tap to choose';

  @override
  String get habitFormNameLabel => 'Habit name';

  @override
  String get habitFormNameHelper => 'Keep it short and action-oriented.';

  @override
  String get habitFormNameRequiredError =>
      'Enter a name with at least 2 characters.';

  @override
  String get habitFormNameLengthError =>
      'Name must be between 2 and 32 characters.';

  @override
  String get habitFormEmojiRequiredError =>
      'Select an emoji to represent the habit.';

  @override
  String get habitFormColorLabel => 'Accent color';

  @override
  String get habitFormColorDescription => 'Used in lists and reminders.';

  @override
  String get habitFormDaysLabel => 'Days of the week';

  @override
  String get habitFormDaysHelper =>
      'Pick at least one day to practise this habit.';

  @override
  String get habitFormDaysError => 'Choose at least one day.';

  @override
  String get habitFormReminderLabel => 'Daily reminder';

  @override
  String get habitFormReminderSubtitle =>
      'Enable notifications to stay on track.';

  @override
  String get habitFormReminderTimeLabel => 'Reminder time';

  @override
  String get habitFormReminderTimeHelper =>
      'We\'ll remind you at this time on selected days.';

  @override
  String get habitFormReminderTimeError => 'Select a valid reminder time.';

  @override
  String get habitFormReminderPermissionDenied =>
      'We couldn\'t enable reminders without notification permission.';

  @override
  String get habitFormLimitError =>
      'You can only track up to three habits at a time.';

  @override
  String get habitFormCreateHabit => 'Create habit';

  @override
  String get habitFormSaveChanges => 'Save changes';

  @override
  String get habitFormDeleteTooltip => 'Delete habit';

  @override
  String get habitFormDeleteConfirmTitle => 'Delete habit?';

  @override
  String get habitFormDeleteConfirmMessage =>
      'This will remove the habit and its history.';

  @override
  String get habitFormDeleteCancel => 'Cancel';

  @override
  String get habitFormDeleteConfirmAction => 'Delete';

  @override
  String get habitFormDeleteError => 'Couldn\'t delete the habit. Try again.';

  @override
  String get habitFormDeleteSuccess => 'Habit deleted.';

  @override
  String get habitFormDiscardTitle => 'Discard changes?';

  @override
  String get habitFormDiscardMessage =>
      'You have unsaved changes. Are you sure you want to leave?';

  @override
  String get habitFormDiscardCancel => 'Keep editing';

  @override
  String get habitFormDiscardConfirm => 'Discard';

  @override
  String get habitFormReminderFallbackName => 'your habit';

  @override
  String habitFormReminderTitle(String emoji, String name) {
    return '$emoji $name';
  }

  @override
  String habitFormReminderBody(String name) {
    return 'Time to check in on $name.';
  }

  @override
  String get habitFormCreateSuccess => 'Habit created successfully.';

  @override
  String get habitFormUpdateSuccess => 'Habit updated successfully.';

  @override
  String get consentDialogTitle => 'Share Anonymous Usage Data?';

  @override
  String get consentDialogBody =>
      'Help us improve Habit Tracker by sharing anonymized usage metrics and crash reports. You can change this later in Settings.';

  @override
  String get consentNotNow => 'Not now';

  @override
  String get consentShare => 'Share';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrivacySection => 'Privacy & Data';

  @override
  String get settingsAnalyticsToggle => 'Share anonymous usage analytics';

  @override
  String get settingsAnalyticsSubtitle =>
      'Helps us understand which features are most useful.';

  @override
  String get settingsCrashToggle => 'Share crash reports';

  @override
  String get settingsCrashSubtitle =>
      'Sends anonymized crash logs so we can fix issues faster.';

  @override
  String get settingsNotificationsSection => 'Notifications';

  @override
  String get settingsNotificationsToggle => 'Daily reminder notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Receive a helpful nudge to complete today’s habits.';

  @override
  String get settingsNotificationTimeTitle => 'Reminder time';

  @override
  String settingsNotificationTimeSubtitle(String time) {
    return 'Currently $time';
  }

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsThemeLabel => 'Theme mode';

  @override
  String get settingsThemeLabelSystem => 'System default';

  @override
  String get settingsThemeLabelLight => 'Light';

  @override
  String get settingsThemeLabelDark => 'Dark';

  @override
  String get settingsThemeDescriptionSystem =>
      'Automatically follow device appearance';

  @override
  String get settingsThemeDescriptionLight => 'Always use a light theme';

  @override
  String get settingsThemeDescriptionDark => 'Always use a dark theme';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageSystem => 'Follow system language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFrench => 'French';

  @override
  String get settingsLanguageDescriptionSystem =>
      'App language follows your device settings.';

  @override
  String settingsLanguageDescription(String language) {
    return 'App language is set to $language';
  }

  @override
  String get htmlThemeLabel => 'Content theme';

  @override
  String get htmlThemeOptionSystem => 'Match app theme';

  @override
  String get htmlThemeOptionLight => 'Light';

  @override
  String get htmlThemeOptionDark => 'Dark';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsReleaseNotes => 'Release notes';

  @override
  String get settingsReleaseNotesSubtitle => 'See what changed in each version';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsPrivacyPolicySubtitle => 'How we handle your data';

  @override
  String settingsVersionLabel(String version, String build) {
    return 'v$version.$build - version name and build number';
  }

  @override
  String get releaseNotesTitle => 'Release Notes';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingTagline => 'Build better routines one day at a time';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingGoal => 'Track up to three daily habits';

  @override
  String get onboardingHabitsTitle => 'Choose your starter habits';

  @override
  String get onboardingHabitsSubtitle =>
      'Pick up to three habits to jump-start your routine.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingSelectionHint =>
      'You can add or edit habits later from the dashboard.';

  @override
  String get onboardingNotificationsTitle => 'Stay on track with reminders';

  @override
  String get onboardingNotificationsSubtitle =>
      'Enable reminders so we can nudge you to keep your streaks.';

  @override
  String get onboardingEnableReminders => 'Enable Reminders';

  @override
  String get onboardingMaybeLater => 'Later';

  @override
  String get onboardingNotificationsGranted =>
      'Reminders are on! We\'ll send a gentle nudge each day.';

  @override
  String get onboardingNotificationsDenied =>
      'No worries! You can turn reminders on later from Settings.';

  @override
  String get onboardingFinishTitle => 'You\'re ready to start!';

  @override
  String get onboardingFinishCta => 'Go to Dashboard';

  @override
  String onboardingError(String message) {
    return 'Something went wrong: $message';
  }

  @override
  String get onboardingHabitMeditate => 'Meditate';

  @override
  String get onboardingHabitWalk => 'Walk';

  @override
  String get onboardingHabitHydrate => 'Drink water';

  @override
  String get onboardingHabitJournal => 'Journal';

  @override
  String get onboardingHabitStretch => 'Stretch';

  @override
  String get onboardingHabitRead => 'Read';
}

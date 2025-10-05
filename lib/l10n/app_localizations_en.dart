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
  String get homeSettingsTooltip => 'Settings';

  @override
  String get homeAddHabitTooltip => 'Add habit';

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
}

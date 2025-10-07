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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Tracker'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get homeTitle;

  /// No description provided for @homeTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeTodayTitle;

  /// No description provided for @homeTodayHeadline.
  ///
  /// In en, this message translates to:
  /// **'Today\'s habits'**
  String get homeTodayHeadline;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTooltip;

  /// No description provided for @homeAddHabitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get homeAddHabitTooltip;

  /// Summary of completed habits for the day.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed {completed} of {total} habits today'**
  String homeProgressSummary(int completed, int total);

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first habit'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start by creating up to three daily habits to track.'**
  String get homeEmptySubtitle;

  /// No description provided for @homeEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Create a habit'**
  String get homeEmptyCta;

  /// No description provided for @homeMarkCompleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get homeMarkCompleteTooltip;

  /// No description provided for @homeMarkIncompleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark as not done'**
  String get homeMarkIncompleteTooltip;

  /// No description provided for @homeCurrentStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String homeCurrentStreakLabel(int count);

  /// No description provided for @homeBestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Best {count} days'**
  String homeBestStreakLabel(int count);

  /// No description provided for @homeCompletionSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Marked {habitName} as done.'**
  String homeCompletionSnackbar(String habitName);

  /// No description provided for @homeUndoSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Marked {habitName} as not done.'**
  String homeUndoSnackbar(String habitName);

  /// No description provided for @homeEditHabitLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit {habitName}'**
  String homeEditHabitLabel(String habitName);

  /// No description provided for @homeUndoHabitLabel.
  ///
  /// In en, this message translates to:
  /// **'Undo completion for {habitName}'**
  String homeUndoHabitLabel(String habitName);

  /// No description provided for @navHomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHomeLabel;

  /// No description provided for @navHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistoryLabel;

  /// No description provided for @navSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettingsLabel;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your streak history will appear here soon.'**
  String get historyPlaceholder;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete your habits to build your timeline.'**
  String get historyEmptyMessage;

  /// No description provided for @historyEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Start tracking today!'**
  String get historyEmptyCta;

  /// No description provided for @historyFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by habit'**
  String get historyFilterLabel;

  /// No description provided for @historyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All habits'**
  String get historyFilterAll;

  /// No description provided for @historyStreakHeading.
  ///
  /// In en, this message translates to:
  /// **'Streak summary'**
  String get historyStreakHeading;

  /// No description provided for @historyStreakBest.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get historyStreakBest;

  /// No description provided for @historyStreakCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get historyStreakCurrent;

  /// No description provided for @historyCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} complete'**
  String historyCompletionLabel(int completed, int total);

  /// No description provided for @historyNoHabitsForDay.
  ///
  /// In en, this message translates to:
  /// **'No scheduled habits for this day.'**
  String get historyNoHabitsForDay;

  /// No description provided for @habitFormCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create habit'**
  String get habitFormCreateTitle;

  /// No description provided for @habitFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get habitFormEditTitle;

  /// No description provided for @habitFormCreatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'The habit form will live here in a future update.'**
  String get habitFormCreatePlaceholder;

  /// No description provided for @habitFormEditPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Editing habits is coming soon.'**
  String get habitFormEditPlaceholder;

  /// No description provided for @habitFormEmojiLabel.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get habitFormEmojiLabel;

  /// No description provided for @habitFormEmojiPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose'**
  String get habitFormEmojiPlaceholder;

  /// No description provided for @habitFormNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitFormNameLabel;

  /// No description provided for @habitFormNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Keep it short and action-oriented.'**
  String get habitFormNameHelper;

  /// No description provided for @habitFormNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Enter a name with at least 2 characters.'**
  String get habitFormNameRequiredError;

  /// No description provided for @habitFormNameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must be between 2 and 32 characters.'**
  String get habitFormNameLengthError;

  /// No description provided for @habitFormEmojiRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Select an emoji to represent the habit.'**
  String get habitFormEmojiRequiredError;

  /// No description provided for @habitFormColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get habitFormColorLabel;

  /// No description provided for @habitFormColorDescription.
  ///
  /// In en, this message translates to:
  /// **'Used in lists and reminders.'**
  String get habitFormColorDescription;

  /// No description provided for @habitFormDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days of the week'**
  String get habitFormDaysLabel;

  /// No description provided for @habitFormDaysHelper.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day to practise this habit.'**
  String get habitFormDaysHelper;

  /// No description provided for @habitFormDaysError.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one day.'**
  String get habitFormDaysError;

  /// No description provided for @habitFormReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get habitFormReminderLabel;

  /// No description provided for @habitFormReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to stay on track.'**
  String get habitFormReminderSubtitle;

  /// No description provided for @habitFormReminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get habitFormReminderTimeLabel;

  /// No description provided for @habitFormReminderTimeHelper.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you at this time on selected days.'**
  String get habitFormReminderTimeHelper;

  /// No description provided for @habitFormReminderTimeError.
  ///
  /// In en, this message translates to:
  /// **'Select a valid reminder time.'**
  String get habitFormReminderTimeError;

  /// No description provided for @habitFormReminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t enable reminders without notification permission.'**
  String get habitFormReminderPermissionDenied;

  /// No description provided for @habitFormLimitError.
  ///
  /// In en, this message translates to:
  /// **'You can only track up to three habits at a time.'**
  String get habitFormLimitError;

  /// No description provided for @habitFormCreateHabit.
  ///
  /// In en, this message translates to:
  /// **'Create habit'**
  String get habitFormCreateHabit;

  /// No description provided for @habitFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get habitFormSaveChanges;

  /// No description provided for @habitFormDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get habitFormDeleteTooltip;

  /// No description provided for @habitFormDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete habit?'**
  String get habitFormDeleteConfirmTitle;

  /// No description provided for @habitFormDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove the habit and its history.'**
  String get habitFormDeleteConfirmMessage;

  /// No description provided for @habitFormDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get habitFormDeleteCancel;

  /// No description provided for @habitFormDeleteConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get habitFormDeleteConfirmAction;

  /// No description provided for @habitFormDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the habit. Try again.'**
  String get habitFormDeleteError;

  /// No description provided for @habitFormDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Habit deleted.'**
  String get habitFormDeleteSuccess;

  /// No description provided for @habitFormDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get habitFormDiscardTitle;

  /// No description provided for @habitFormDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave?'**
  String get habitFormDiscardMessage;

  /// No description provided for @habitFormDiscardCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get habitFormDiscardCancel;

  /// No description provided for @habitFormDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get habitFormDiscardConfirm;

  /// No description provided for @habitFormReminderFallbackName.
  ///
  /// In en, this message translates to:
  /// **'your habit'**
  String get habitFormReminderFallbackName;

  /// No description provided for @habitFormReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'{emoji} {name}'**
  String habitFormReminderTitle(String emoji, String name);

  /// No description provided for @habitFormReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Time to check in on {name}.'**
  String habitFormReminderBody(String name);

  /// No description provided for @habitFormCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Habit created successfully.'**
  String get habitFormCreateSuccess;

  /// No description provided for @habitFormUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Habit updated successfully.'**
  String get habitFormUpdateSuccess;

  /// No description provided for @consentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Anonymous Usage Data?'**
  String get consentDialogTitle;

  /// No description provided for @consentDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Help us improve Habit Tracker by sharing anonymized usage metrics and crash reports. You can change this later in Settings.'**
  String get consentDialogBody;

  /// No description provided for @consentNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get consentNotNow;

  /// No description provided for @consentShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get consentShare;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get settingsPrivacySection;

  /// No description provided for @settingsAnalyticsToggle.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage analytics'**
  String get settingsAnalyticsToggle;

  /// No description provided for @settingsAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps us understand which features are most useful.'**
  String get settingsAnalyticsSubtitle;

  /// No description provided for @settingsCrashToggle.
  ///
  /// In en, this message translates to:
  /// **'Share crash reports'**
  String get settingsCrashToggle;

  /// No description provided for @settingsCrashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sends anonymized crash logs so we can fix issues faster.'**
  String get settingsCrashSubtitle;

  /// No description provided for @settingsNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsSection;

  /// No description provided for @settingsNotificationsToggle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder notifications'**
  String get settingsNotificationsToggle;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a helpful nudge to complete today’s habits.'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsNotificationTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsNotificationTimeTitle;

  /// Subtitle showing the selected reminder time.
  ///
  /// In en, this message translates to:
  /// **'Currently {time}'**
  String settingsNotificationTimeSubtitle(String time);

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeLabelSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeLabelSystem;

  /// No description provided for @settingsThemeLabelLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLabelLight;

  /// No description provided for @settingsThemeLabelDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeLabelDark;

  /// No description provided for @settingsThemeDescriptionSystem.
  ///
  /// In en, this message translates to:
  /// **'Automatically follow device appearance'**
  String get settingsThemeDescriptionSystem;

  /// No description provided for @settingsThemeDescriptionLight.
  ///
  /// In en, this message translates to:
  /// **'Always use a light theme'**
  String get settingsThemeDescriptionLight;

  /// No description provided for @settingsThemeDescriptionDark.
  ///
  /// In en, this message translates to:
  /// **'Always use a dark theme'**
  String get settingsThemeDescriptionDark;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system language'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsLanguageDescriptionSystem.
  ///
  /// In en, this message translates to:
  /// **'App language follows your device settings.'**
  String get settingsLanguageDescriptionSystem;

  /// Describes the currently selected language.
  ///
  /// In en, this message translates to:
  /// **'App language is set to {language}'**
  String settingsLanguageDescription(String language);

  /// No description provided for @htmlThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Content theme'**
  String get htmlThemeLabel;

  /// No description provided for @htmlThemeOptionSystem.
  ///
  /// In en, this message translates to:
  /// **'Match app theme'**
  String get htmlThemeOptionSystem;

  /// No description provided for @htmlThemeOptionLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get htmlThemeOptionLight;

  /// No description provided for @htmlThemeOptionDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get htmlThemeOptionDark;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsReleaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release notes'**
  String get settingsReleaseNotes;

  /// No description provided for @settingsReleaseNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See what changed in each version'**
  String get settingsReleaseNotesSubtitle;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get settingsPrivacyPolicySubtitle;

  /// Displays the version and build number on settings.
  ///
  /// In en, this message translates to:
  /// **'v{version}.{build} - version name and build number'**
  String settingsVersionLabel(String version, String build);

  /// No description provided for @releaseNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Release Notes'**
  String get releaseNotesTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'Build better routines one day at a time'**
  String get onboardingTagline;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingGoal.
  ///
  /// In en, this message translates to:
  /// **'Track up to three daily habits'**
  String get onboardingGoal;

  /// No description provided for @onboardingHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your starter habits'**
  String get onboardingHabitsTitle;

  /// No description provided for @onboardingHabitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up to three habits to jump-start your routine.'**
  String get onboardingHabitsSubtitle;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'You can add or edit habits later from the dashboard.'**
  String get onboardingSelectionHint;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on track with reminders'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders so we can nudge you to keep your streaks.'**
  String get onboardingNotificationsSubtitle;

  /// No description provided for @onboardingEnableReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable Reminders'**
  String get onboardingEnableReminders;

  /// No description provided for @onboardingMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get onboardingMaybeLater;

  /// No description provided for @onboardingNotificationsGranted.
  ///
  /// In en, this message translates to:
  /// **'Reminders are on! We\'ll send a gentle nudge each day.'**
  String get onboardingNotificationsGranted;

  /// No description provided for @onboardingNotificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'No worries! You can turn reminders on later from Settings.'**
  String get onboardingNotificationsDenied;

  /// No description provided for @onboardingFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready to start!'**
  String get onboardingFinishTitle;

  /// No description provided for @onboardingFinishCta.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get onboardingFinishCta;

  /// Displayed when saving onboarding data fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {message}'**
  String onboardingError(String message);

  /// No description provided for @onboardingHabitMeditate.
  ///
  /// In en, this message translates to:
  /// **'Meditate'**
  String get onboardingHabitMeditate;

  /// No description provided for @onboardingHabitWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get onboardingHabitWalk;

  /// No description provided for @onboardingHabitHydrate.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get onboardingHabitHydrate;

  /// No description provided for @onboardingHabitJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get onboardingHabitJournal;

  /// No description provided for @onboardingHabitStretch.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get onboardingHabitStretch;

  /// No description provided for @onboardingHabitRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get onboardingHabitRead;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

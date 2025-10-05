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

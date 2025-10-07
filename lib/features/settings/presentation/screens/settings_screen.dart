import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/core/localization/l10n_extensions.dart';
import 'package:habit_tracker/core/telemetry/providers/telemetry_provider.dart';
import 'package:habit_tracker/features/info/application/providers/app_info_provider.dart';
import 'package:habit_tracker/features/info/presentation/screens/privacy_policy_screen.dart';
import 'package:habit_tracker/features/info/presentation/screens/release_notes_screen.dart';
import 'package:habit_tracker/features/settings/application/providers/language_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/notification_settings_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/theme_provider.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryState = ref.watch(telemetryControllerProvider);
    final telemetryController =
        ref.read(telemetryControllerProvider.notifier);
    final analyticsEnabled = telemetryState.analyticsConsent;
    final crashEnabled = telemetryState.crashConsent;
    final loaded = telemetryState.isLoaded;
    final themeState = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);
    final themeMode = themeState.themeMode;
    const themeModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final languageState = ref.watch(languageControllerProvider);
    final languageController = ref.read(languageControllerProvider.notifier);
    final currentLocale = languageState.locale;
    final supportedLocales = AppLocalizations.supportedLocales;
    final appInfo = ref.watch(appInfoProvider);
    final notificationSettingsState = ref.watch(notificationSettingsProvider);
    final notificationSettingsController =
        ref.read(notificationSettingsProvider.notifier);
    final notificationsLoaded = notificationSettingsState.hasLoaded;
    final notificationsEnabled = notificationSettingsState.enabled;
    final reminderTime = notificationSettingsState.reminderTime;
    final formattedReminderTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(reminderTime);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(context.l10n.settingsLanguageSection),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    key: const Key('dropdown_language'),
                    initialValue: currentLocale?.languageCode ?? 'system',
                    decoration: InputDecoration(
                      labelText: context.l10n.settingsLanguageSection,
                      border: const OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<String>(
                        value: 'system',
                        child: Text(context.l10n.settingsLanguageSystem),
                      ),
                      for (final localeOption in supportedLocales)
                        DropdownMenuItem<String>(
                          value: localeOption.languageCode,
                          child: Text(_languageLabel(context, localeOption)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null || value == 'system') {
                        languageController.setLocale(null);
                        return;
                      }
                      final locale = supportedLocales.firstWhere(
                        (element) => element.languageCode == value,
                        orElse: () => supportedLocales.first,
                      );
                      languageController.setLocale(locale);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _languageDescription(context, currentLocale),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(context.l10n.settingsAppearanceSection),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<ThemeMode>(
                    key: const Key('dropdown_theme'),
                    initialValue: themeMode,
                    decoration: InputDecoration(
                      labelText: context.l10n.settingsThemeLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: themeModes
                        .map(
                          (mode) => DropdownMenuItem<ThemeMode>(
                            value: mode,
                            child: Text(_themeLabel(context, mode)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        themeController.setThemeMode(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _themeDescription(context, themeMode),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(context.l10n.settingsNotificationsSection),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile.adaptive(
                  key: const Key('switch_notifications_enabled'),
                  title: Text(context.l10n.settingsNotificationsToggle),
                  subtitle: Text(context.l10n.settingsNotificationsSubtitle),
                  value: notificationsEnabled,
                  onChanged: notificationsLoaded
                      ? (value) =>
                          notificationSettingsController.setEnabled(value)
                      : null,
                ),
                const Divider(height: 0),
                ListTile(
                  key: const Key('tile_notification_time'),
                  enabled: notificationsEnabled,
                  leading: const Icon(Icons.access_time),
                  title: Text(context.l10n.settingsNotificationTimeTitle),
                  subtitle: Text(
                    context.l10n.settingsNotificationTimeSubtitle(
                      formattedReminderTime,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: (!notificationsLoaded || !notificationsEnabled)
                      ? null
                      : () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: reminderTime,
                          );
                          if (picked != null) {
                            await notificationSettingsController
                                .setReminderTime(picked);
                          }
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(context.l10n.settingsPrivacySection),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile.adaptive(
                  key: const Key('switch_analytics_consent'),
                  title: Text(context.l10n.settingsAnalyticsToggle),
                  subtitle: Text(context.l10n.settingsAnalyticsSubtitle),
                  value: analyticsEnabled,
                  onChanged: loaded
                      ? (value) =>
                          telemetryController.updateAnalyticsConsent(value)
                      : null,
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  key: const Key('switch_crash_consent'),
                  title: Text(context.l10n.settingsCrashToggle),
                  subtitle: Text(context.l10n.settingsCrashSubtitle),
                  value: crashEnabled,
                  onChanged: loaded
                      ? (value) =>
                          telemetryController.updateCrashConsent(value)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(context.l10n.settingsAboutSection),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                appInfo.when(
                  data: (info) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: const Icon(Icons.info_outline),
                    title: Text(info.appName),
                    subtitle: Text(
                      context.l10n.settingsVersionLabel(
                        info.version,
                        info.buildNumber,
                      ),
                    ),
                  ),
                  loading: () => const ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text('Loading app info...'),
                  ),
                  error: (error, _) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Habit Tracker'),
                    subtitle: Text('Version unavailable: $error'),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(context.l10n.settingsReleaseNotes),
                  subtitle: Text(context.l10n.settingsReleaseNotesSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const ReleaseNotesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(context.l10n.settingsPrivacyPolicy),
                  subtitle: Text(context.l10n.settingsPrivacyPolicySubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(clipBehavior: Clip.antiAlias, child: child);
  }
}

String _themeLabel(BuildContext context, ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return context.l10n.settingsThemeLabelSystem;
    case ThemeMode.light:
      return context.l10n.settingsThemeLabelLight;
    case ThemeMode.dark:
      return context.l10n.settingsThemeLabelDark;
  }
}

String _themeDescription(BuildContext context, ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return context.l10n.settingsThemeDescriptionSystem;
    case ThemeMode.light:
      return context.l10n.settingsThemeDescriptionLight;
    case ThemeMode.dark:
      return context.l10n.settingsThemeDescriptionDark;
  }
}

String _languageLabel(BuildContext context, Locale locale) {
  switch (locale.languageCode) {
    case 'fr':
      return context.l10n.settingsLanguageFrench;
    case 'en':
    default:
      return context.l10n.settingsLanguageEnglish;
  }
}

String _languageDescription(BuildContext context, Locale? locale) {
  if (locale == null) {
    return context.l10n.settingsLanguageDescriptionSystem;
  }
  return context.l10n.settingsLanguageDescription(
    _languageLabel(context, locale),
  );
}

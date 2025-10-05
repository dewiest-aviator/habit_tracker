import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_info_provider.dart';
import '../state/notification_settings_provider.dart';
import '../state/telemetry_provider.dart';
import '../state/theme_provider.dart';
import 'privacy_policy_screen.dart';
import 'release_notes_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(telemetryControllerProvider);
    final analyticsEnabled = telemetry.isAnalyticsEnabled;
    final crashEnabled = telemetry.isCrashEnabled;
    final loaded = telemetry.isLoaded;
    final themeController = ref.watch(themeControllerProvider);
    final themeMode = themeController.themeMode;
    const themeModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final appInfo = ref.watch(appInfoProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final notificationsLoaded = notificationSettings.hasLoaded;
    final notificationsEnabled = notificationSettings.enabled;
    final reminderTime = notificationSettings.reminderTime;
    final formattedReminderTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(reminderTime);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader('Privacy & Data'),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile.adaptive(
                  key: const Key('switch_analytics_consent'),
                  title: const Text('Share anonymous usage analytics'),
                  subtitle: const Text(
                    'Helps us understand which features are most useful.',
                  ),
                  value: analyticsEnabled,
                  onChanged: loaded
                      ? (value) => telemetry.updateAnalyticsConsent(value)
                      : null,
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  key: const Key('switch_crash_consent'),
                  title: const Text('Share crash reports'),
                  subtitle: const Text(
                    'Sends anonymized crash logs so we can fix issues faster.',
                  ),
                  value: crashEnabled,
                  onChanged: loaded
                      ? (value) => telemetry.updateCrashConsent(value)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader('Notifications'),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile.adaptive(
                  key: const Key('switch_notifications_enabled'),
                  title: const Text('Daily reminder notifications'),
                  subtitle: const Text(
                    'Receive a helpful nudge to complete today’s habits.',
                  ),
                  value: notificationsEnabled,
                  onChanged: notificationsLoaded
                      ? (value) => notificationSettings.setEnabled(value)
                      : null,
                ),
                const Divider(height: 0),
                ListTile(
                  key: const Key('tile_notification_time'),
                  enabled: notificationsEnabled,
                  leading: const Icon(Icons.access_time),
                  title: const Text('Reminder time'),
                  subtitle: Text('Currently $formattedReminderTime'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: (!notificationsLoaded || !notificationsEnabled)
                      ? null
                      : () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: reminderTime,
                          );
                          if (picked != null) {
                            await notificationSettings.setReminderTime(picked);
                          }
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader('Appearance'),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<ThemeMode>(
                    initialValue: themeMode,
                    decoration: const InputDecoration(
                      labelText: 'Theme mode',
                      border: OutlineInputBorder(),
                    ),
                    items: themeModes
                        .map(
                          (mode) => DropdownMenuItem<ThemeMode>(
                            value: mode,
                            child: Text(_themeLabel(mode)),
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
                    _themeDescription(themeMode),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader('About'),
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
                      'v${info.version}.${info.buildNumber} - version name and build number',
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
                  title: const Text('Release notes'),
                  subtitle: const Text('See what changed in each version'),
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
                  title: const Text('Privacy policy'),
                  subtitle: const Text('How we handle your data'),
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

String _themeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return 'Use system setting';
    case ThemeMode.light:
      return 'Light mode';
    case ThemeMode.dark:
      return 'Dark mode';
  }
}

String _themeDescription(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return 'Automatically follow device appearance';
    case ThemeMode.light:
      return 'Always use a light theme';
    case ThemeMode.dark:
      return 'Always use a dark theme';
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/core/localization/l10n_extensions.dart';
import 'package:habit_tracker/core/telemetry/providers/telemetry_provider.dart';
import 'package:habit_tracker/features/info/application/providers/app_info_provider.dart';
import 'package:habit_tracker/features/info/presentation/screens/privacy_policy_screen.dart';
import 'package:habit_tracker/features/info/presentation/screens/release_notes_screen.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/features/settings/application/controllers/notification_settings_controller.dart';
import 'package:habit_tracker/core/services/support_service.dart';
import 'package:habit_tracker/features/settings/application/controllers/time_preferences_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/language_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/notification_settings_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/theme_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/time_preferences_provider.dart';
import 'package:habit_tracker/features/settings/application/settings_analytics.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  bool _isRateInProgress = false;
  bool _isReportInProgress = false;
  bool _shouldRefreshPermissionsOnResume = false;
  bool _showPermissionSnackOnNextUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analytics = ref.read(settingsAnalyticsProvider);
      final themeState = ref.read(themeControllerProvider);
      final languageState = ref.read(languageControllerProvider);
      final telemetryState = ref.read(telemetryControllerProvider);
      final timePreferencesState = ref.read(timePreferencesProvider);
      unawaited(
        analytics.logView(
          themeMode: themeState.themeMode,
          locale: languageState.locale,
          analyticsEnabled: telemetryState.analyticsConsent,
          crashEnabled: telemetryState.crashConsent,
          timePreference: timePreferencesState.preference,
        ),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _shouldRefreshPermissionsOnResume) {
      _shouldRefreshPermissionsOnResume = false;
      unawaited(
        ref
            .read(notificationSettingsProvider.notifier)
            .refreshPermissionStatus(),
      );
    }
  }

  Future<void> _onRateApp(BuildContext context) async {
    if (_isRateInProgress) return;
    setState(() => _isRateInProgress = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final analytics = ref.read(settingsAnalyticsProvider);
    try {
      final outcome = await ref.read(supportServiceProvider).rateApp();
      unawaited(
        analytics.logRateAppTap(inAppAvailable: outcome.usedInAppReview),
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            outcome.success
                ? l10n.settingsRateAppSuccess
                : l10n.settingsRateAppFailure,
          ),
        ),
      );
    } catch (_) {
      unawaited(analytics.logRateAppTap(inAppAvailable: false));
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsRateAppFailure)),
      );
    } finally {
      if (mounted) {
        setState(() => _isRateInProgress = false);
      }
    }
  }

  Future<void> _onReportIssue(BuildContext context, PackageInfo? info) async {
    if (_isReportInProgress) return;
    setState(() => _isReportInProgress = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final analytics = ref.read(settingsAnalyticsProvider);
    try {
      final outcome = await ref
          .read(supportServiceProvider)
          .reportIssue(packageInfo: info);
      unawaited(
        analytics.logReportIssueTap(
          logReady: outcome.logReady,
          logSizeBytes: outcome.logSizeBytes,
        ),
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            outcome.success
                ? l10n.settingsReportIssueSuccess
                : l10n.settingsReportIssueFailure,
          ),
        ),
      );
    } catch (_) {
      unawaited(analytics.logReportIssueTap(logReady: false));
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsReportIssueFailure)),
      );
    } finally {
      if (mounted) {
        setState(() => _isReportInProgress = false);
      }
    }
  }

  Future<void> _handlePermissionRequest(
    BuildContext context,
    NotificationSettingsController controller,
  ) async {
    _showPermissionSnackOnNextUpdate = true;
    await controller.requestPermission();
  }

  Future<void> _handleOpenPermissionSettings(
    BuildContext context,
    NotificationSettingsController controller,
  ) async {
    _shouldRefreshPermissionsOnResume = true;
    _showPermissionSnackOnNextUpdate = true;
    final opened = await controller.openPermissionSettings();
    if (!opened) {
      _shouldRefreshPermissionsOnResume = false;
      _showPermissionSnackOnNextUpdate = false;
    }
  }

  Future<bool> _onEnableNotifications(
    BuildContext context,
    NotificationSettingsController controller,
  ) async {
    _showPermissionSnackOnNextUpdate = true;
    var status = _effectivePermissionStatus(
      ref.read(notificationSettingsProvider),
    );
    if (status != NotificationAuthorizationStatus.granted) {
      await controller.requestPermission();
      status = _effectivePermissionStatus(
        ref.read(notificationSettingsProvider),
      );
      if (status != NotificationAuthorizationStatus.granted) {
        await controller.setEnabled(false);
        return false;
      }
    }
    await controller.setEnabled(true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    ref.listen<NotificationSettingsState>(
      notificationSettingsProvider,
      (previous, next) {
        if (!mounted) return;
        final statusChanged = previous != null &&
            previous.permissionStatus != next.permissionStatus;
        if (!statusChanged && !_showPermissionSnackOnNextUpdate) {
          return;
        }
        _showPermissionSnackOnNextUpdate = false;
        final messenger = ScaffoldMessenger.of(context);
        final l10n = context.l10n;
        final message =
            next.permissionStatus == NotificationAuthorizationStatus.granted
                ? l10n.settingsNotificationPermissionGrantedMessage
                : l10n.settingsNotificationPermissionDeniedMessage;
        messenger.showSnackBar(SnackBar(content: Text(message)));
      },
    );
    final telemetryState = ref.watch(telemetryControllerProvider);
    final telemetryController = ref.read(telemetryControllerProvider.notifier);
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
    final timePreferencesState = ref.watch(timePreferencesProvider);
    final timePreferencesController = ref.read(
      timePreferencesProvider.notifier,
    );
    final timePreference = timePreferencesState.preference;
    final timePreferencesLoaded = timePreferencesState.hasLoaded;
    final settingsAnalytics = ref.read(settingsAnalyticsProvider);
    final appInfo = ref.watch(appInfoProvider);
    final appInfoValue = appInfo.asData?.value;
    final notificationSettingsState = ref.watch(notificationSettingsProvider);
    final notificationSettingsController = ref.read(
      notificationSettingsProvider.notifier,
    );
    final notificationsLoaded = notificationSettingsState.hasLoaded;
    final notificationsEnabled = notificationSettingsState.enabled;
    final reminderTime = notificationSettingsState.reminderTime;
    final permissionStatus = _effectivePermissionStatus(
      notificationSettingsState,
    );
    final permissionInProgress =
        notificationSettingsState.isPermissionInProgress;
    final permissionGranted =
        permissionStatus == NotificationAuthorizationStatus.granted;
    final mediaQuery = MediaQuery.of(context);
    final alwaysUse24HourFormat = switch (timePreference) {
      TimeFormatPreference.system => mediaQuery.alwaysUse24HourFormat,
      TimeFormatPreference.h12 => false,
      TimeFormatPreference.h24 => true,
    };
    final formattedReminderTime = MaterialLocalizations.of(context)
        .formatTimeOfDay(
          reminderTime,
          alwaysUse24HourFormat: alwaysUse24HourFormat,
        );
    final canToggleNotifications = notificationsLoaded && permissionGranted;
    final reminderControlsEnabled =
        notificationsLoaded && notificationsEnabled && permissionGranted;

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
                      final previousLocale = currentLocale;
                      if (value == null || value == 'system') {
                        languageController.setLocale(null);
                        unawaited(
                          settingsAnalytics.logLanguageChange(
                            newLocale: null,
                            previousLocale: previousLocale,
                          ),
                        );
                        return;
                      }
                      final locale = supportedLocales.firstWhere(
                        (element) => element.languageCode == value,
                        orElse: () => supportedLocales.first,
                      );
                      languageController.setLocale(locale);
                      unawaited(
                        settingsAnalytics.logLanguageChange(
                          newLocale: locale,
                          previousLocale: previousLocale,
                        ),
                      );
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
                        final previousTheme = themeMode;
                        themeController.setThemeMode(value);
                        unawaited(
                          settingsAnalytics.logThemeChange(
                            newTheme: value,
                            previousTheme: previousTheme,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _themeDescription(context, themeMode),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<TimeFormatPreference>(
                    key: const Key('dropdown_time_format'),
                    initialValue: timePreference,
                    decoration: InputDecoration(
                      labelText: context.l10n.settingsTimeFormatLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: TimeFormatPreference.values
                        .map(
                          (preference) =>
                              DropdownMenuItem<TimeFormatPreference>(
                                value: preference,
                                child: Text(
                                  _timeFormatLabel(context, preference),
                                ),
                              ),
                        )
                        .toList(),
                    onChanged: timePreferencesLoaded
                        ? (value) {
                            if (value == null) return;
                            timePreferencesController.setPreference(value);
                            unawaited(
                              settingsAnalytics.logTimeFormatChange(value),
                            );
                          }
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _timeFormatDescription(context, timePreference),
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
                ListTile(
                  key: const Key('tile_notification_permission'),
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text(context.l10n.settingsNotificationPermissionTitle),
                  subtitle: Text(
                    _permissionStatusDescription(context, permissionStatus),
                  ),
                  trailing: _PermissionActionButton(
                    status: permissionStatus,
                    busy: permissionInProgress,
                    onRequest: () => _handlePermissionRequest(
                      context,
                      notificationSettingsController,
                    ),
                    onOpenSettings: () => _handleOpenPermissionSettings(
                      context,
                      notificationSettingsController,
                    ),
                  ),
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  key: const Key('switch_notifications_enabled'),
                  title: Text(context.l10n.settingsNotificationsToggle),
                  subtitle: Text(context.l10n.settingsNotificationsSubtitle),
                  value: notificationsEnabled && permissionGranted,
                  onChanged: canToggleNotifications
                      ? (value) async {
                          if (value) {
                            final wasEnabled = await _onEnableNotifications(
                              context,
                              notificationSettingsController,
                            );
                            if (!wasEnabled) return;
                          } else {
                            await notificationSettingsController.setEnabled(
                              false,
                            );
                          }
                        }
                      : null,
                ),
                const Divider(height: 0),
                ListTile(
                  key: const Key('tile_notification_time'),
                  enabled: reminderControlsEnabled,
                  leading: const Icon(Icons.access_time),
                  title: Text(context.l10n.settingsNotificationTimeTitle),
                  subtitle: Text(
                    context.l10n.settingsNotificationTimeSubtitle(
                      formattedReminderTime,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: !reminderControlsEnabled
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
                      ? (value) {
                          telemetryController.updateAnalyticsConsent(value);
                          unawaited(
                            settingsAnalytics.logAnalyticsToggle(value),
                          );
                        }
                      : null,
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  key: const Key('switch_crash_consent'),
                  title: Text(context.l10n.settingsCrashToggle),
                  subtitle: Text(context.l10n.settingsCrashSubtitle),
                  value: crashEnabled,
                  onChanged: loaded
                      ? (value) {
                          telemetryController.updateCrashConsent(value);
                          unawaited(settingsAnalytics.logCrashToggle(value));
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(context.l10n.settingsSupportSection),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined),
                  title: Text(context.l10n.settingsRateApp),
                  subtitle: Text(context.l10n.settingsRateAppSubtitle),
                  trailing: _isRateInProgress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isRateInProgress ? null : () => _onRateApp(context),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(context.l10n.settingsReportIssue),
                  subtitle: Text(context.l10n.settingsReportIssueSubtitle),
                  trailing: _isReportInProgress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isReportInProgress
                      ? null
                      : () => _onReportIssue(context, appInfoValue),
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
                    unawaited(settingsAnalytics.logReleaseNotesOpen());
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
                    unawaited(settingsAnalytics.logPrivacyPolicyOpen());
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.library_books_outlined),
                  title: Text(context.l10n.settingsLicenses),
                  subtitle: Text(context.l10n.settingsLicensesSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    unawaited(settingsAnalytics.logLicensesOpen());
                    final info = appInfoValue;
                    showLicensePage(
                      context: context,
                      applicationName: info?.appName,
                      applicationVersion: info == null
                          ? null
                          : '${info.version} (${info.buildNumber})',
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

String _timeFormatLabel(BuildContext context, TimeFormatPreference preference) {
  switch (preference) {
    case TimeFormatPreference.system:
      return context.l10n.settingsTimeFormatOptionSystem;
    case TimeFormatPreference.h12:
      return context.l10n.settingsTimeFormatOption12h;
    case TimeFormatPreference.h24:
      return context.l10n.settingsTimeFormatOption24h;
  }
}

String _timeFormatDescription(
  BuildContext context,
  TimeFormatPreference preference,
) {
  switch (preference) {
    case TimeFormatPreference.system:
      return context.l10n.settingsTimeFormatDescriptionSystem;
    case TimeFormatPreference.h12:
      return context.l10n.settingsTimeFormatDescription12h;
    case TimeFormatPreference.h24:
      return context.l10n.settingsTimeFormatDescription24h;
  }
}

NotificationAuthorizationStatus _effectivePermissionStatus(
  NotificationSettingsState state,
) {
  var status = state.permissionStatus;
  if (status == NotificationAuthorizationStatus.notDetermined &&
      state.permissionRequested) {
    status = NotificationAuthorizationStatus.denied;
  }
  return status;
}

String _permissionStatusDescription(
  BuildContext context,
  NotificationAuthorizationStatus status,
) {
  switch (status) {
    case NotificationAuthorizationStatus.granted:
      return context.l10n.settingsNotificationPermissionStatusGranted;
    case NotificationAuthorizationStatus.denied:
      return context.l10n.settingsNotificationPermissionStatusDenied;
    case NotificationAuthorizationStatus.notDetermined:
      return context.l10n.settingsNotificationPermissionStatusAsk;
    case NotificationAuthorizationStatus.unknown:
      return context.l10n.settingsNotificationPermissionStatusUnknown;
  }
}

class _PermissionActionButton extends StatelessWidget {
  const _PermissionActionButton({
    required this.status,
    required this.busy,
    required this.onRequest,
    required this.onOpenSettings,
  });

  final NotificationAuthorizationStatus status;
  final bool busy;
  final Future<void> Function() onRequest;
  final Future<void> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    switch (status) {
      case NotificationAuthorizationStatus.granted:
        return Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
        );
      case NotificationAuthorizationStatus.notDetermined:
        return TextButton(
          onPressed: () {
            onRequest();
          },
          child: Text(context.l10n.settingsNotificationPermissionActionRequest),
        );
      case NotificationAuthorizationStatus.denied:
        return TextButton(
          onPressed: () {
            onOpenSettings();
          },
          child: Text(
            context.l10n.settingsNotificationPermissionActionSettings,
          ),
        );
      case NotificationAuthorizationStatus.unknown:
        return const SizedBox.shrink();
    }
  }
}

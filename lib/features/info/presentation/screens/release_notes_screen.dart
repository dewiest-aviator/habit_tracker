import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/core/localization/l10n_extensions.dart';
import 'package:habit_tracker/features/info/application/providers/app_info_provider.dart';
import 'package:habit_tracker/features/info/application/providers/remote_content_provider.dart';
import 'package:habit_tracker/features/info/presentation/widgets/html_theme.dart';

class ReleaseNotesScreen extends ConsumerStatefulWidget {
  const ReleaseNotesScreen({super.key});

  @override
  ConsumerState<ReleaseNotesScreen> createState() =>
      _ReleaseNotesScreenState();
}

class _ReleaseNotesScreenState extends ConsumerState<ReleaseNotesScreen> {
  HtmlThemePreference _preference = HtmlThemePreference.system;

  Brightness _resolvedBrightness(BuildContext context) {
    switch (_preference) {
      case HtmlThemePreference.system:
        return Theme.of(context).brightness;
      case HtmlThemePreference.light:
        return Brightness.light;
      case HtmlThemePreference.dark:
        return Brightness.dark;
    }
  }

  void _togglePreference(BuildContext context) {
    final brightness = _resolvedBrightness(context);
    setState(() {
      if (brightness == Brightness.light) {
        _preference = HtmlThemePreference.dark;
      } else {
        _preference = HtmlThemePreference.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appInfo = ref.watch(appInfoProvider);

    final l10n = context.l10n;
    final brightness = _resolvedBrightness(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.releaseNotesTitle),
        actions: [
          IconButton(
            key: const Key('btn_toggle_html_theme'),
            tooltip: brightness == Brightness.light
                ? l10n.htmlThemeOptionDark
                : l10n.htmlThemeOptionLight,
            icon: Icon(
              brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () => _togglePreference(context),
          ),
        ],
      ),
      body: appInfo.when(
        loading: () => const _CenteredProgress(),
        error: (error, _) =>
            _ErrorContent(message: 'Failed to load app info: $error'),
        data: (info) {
          final versionKey = '${info.version}.${info.buildNumber}';
          final notes = ref.watch(
            remoteContentProvider('release-notes/$versionKey'),
          );

          return notes.when(
            loading: () => const _CenteredProgress(),
            error: (error, _) =>
                _ErrorContent(message: 'Failed to load release notes: $error'),
            data: (content) => _ContentView(
              content: content,
              preference: _preference,
            ),
          );
        },
      ),
    );
  }
}

class _ContentView extends StatelessWidget {
  const _ContentView({
    required this.content,
    required this.preference,
  });

  final String content;
  final HtmlThemePreference preference;

  @override
  Widget build(BuildContext context) {
    final scheme = htmlColorSchemeForPreference(context, preference);
    final styles = htmlStylesForColorScheme(scheme);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: scheme.surface,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Html(
                      data: content,
                      style: styles,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredProgress extends StatelessWidget {
  const _CenteredProgress();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/core/localization/l10n_extensions.dart';
import 'package:habit_tracker/features/info/application/providers/remote_content_provider.dart';
import 'package:habit_tracker/features/info/presentation/widgets/html_theme.dart';

class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<PrivacyPolicyScreen> createState() =>
      _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {
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
    final content = ref.watch(remoteContentProvider('privacy-policy'));

    final l10n = context.l10n;
    final brightness = _resolvedBrightness(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicyTitle),
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
      body: content.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Failed to load privacy policy: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (body) => _HtmlContent(
          content: body,
          preference: _preference,
        ),
      ),
    );
  }
}

class _HtmlContent extends StatelessWidget {
  const _HtmlContent({
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

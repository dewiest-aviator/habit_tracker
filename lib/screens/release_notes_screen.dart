import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_info_provider.dart';
import '../state/remote_content_provider.dart';

class ReleaseNotesScreen extends ConsumerWidget {
  const ReleaseNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Release Notes')),
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
            data: (content) => _ContentView(content: content),
          );
        },
      ),
    );
  }
}

class _ContentView extends StatelessWidget {
  const _ContentView({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Html(
          data: content,
          style: {
            'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
          },
        ),
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

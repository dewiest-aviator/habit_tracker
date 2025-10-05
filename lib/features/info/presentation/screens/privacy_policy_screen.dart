import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/features/info/application/providers/remote_content_provider.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(remoteContentProvider('privacy-policy'));

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
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
        data: (body) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Html(
              data: body,
              style: {
                'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              },
            ),
          ),
        ),
      ),
    );
  }
}

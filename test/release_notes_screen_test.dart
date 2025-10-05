import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/screens/release_notes_screen.dart';
import 'package:habit_tracker/state/app_info_provider.dart';
import 'package:habit_tracker/state/remote_content_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('renders remote release notes content', (tester) async {
    final packageInfo = PackageInfo(
      appName: 'Habit Tracker',
      packageName: 'com.example.habit',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'sig',
      installerStore: null,
    );

    final client = MockClient((request) async {
      expect(request.url.path, contains('release-notes/1.0.0.1'));
      return http.Response('Release notes content', 200);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appInfoProvider.overrideWith((ref) async => packageInfo),
          httpClientProvider.overrideWithValue(client),
        ],
        child: const MaterialApp(home: ReleaseNotesScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    final htmlFinder = find.byType(Html);
    expect(htmlFinder, findsOneWidget);
    final htmlWidget = tester.widget<Html>(htmlFinder);
    expect(htmlWidget.data, contains('Release notes content'));
  });

  testWidgets('shows error when release notes fetch fails', (tester) async {
    final packageInfo = PackageInfo(
      appName: 'Habit Tracker',
      packageName: 'com.example.habit',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'sig',
      installerStore: null,
    );

    final client = MockClient((request) async {
      return http.Response('not found', 404);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appInfoProvider.overrideWith((ref) async => packageInfo),
          httpClientProvider.overrideWithValue(client),
        ],
        child: const MaterialApp(home: ReleaseNotesScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Failed to load release notes'), findsOneWidget);
  });
}

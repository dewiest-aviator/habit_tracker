import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/info/application/providers/remote_content_provider.dart';
import 'package:habit_tracker/features/info/presentation/screens/privacy_policy_screen.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('renders privacy policy content', (tester) async {
    final client = MockClient((request) async {
      expect(request.url.path, contains('privacy-policy'));
      return http.Response('Privacy policy content', 200);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [httpClientProvider.overrideWithValue(client)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PrivacyPolicyScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final htmlFinder = find.byType(Html);
    expect(htmlFinder, findsOneWidget);
    final htmlWidget = tester.widget<Html>(htmlFinder);
    expect(htmlWidget.data, contains('Privacy policy content'));

    final toggleButton = find.byKey(const Key('btn_toggle_html_theme'));
    expect(toggleButton, findsOneWidget);

    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    final updatedHtml = tester.widget<Html>(htmlFinder);
    final bodyStyle = updatedHtml.style['body'];
    expect(bodyStyle?.color, ThemeData.light().colorScheme.onSurface);
  });

  testWidgets('shows error state when fetch fails', (tester) async {
    final client = MockClient((request) async {
      return http.Response('oops', 500);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [httpClientProvider.overrideWithValue(client)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PrivacyPolicyScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.textContaining('Failed to load privacy policy'),
      findsOneWidget,
    );
  });
}

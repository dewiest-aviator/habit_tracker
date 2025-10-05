import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/main.dart';
import 'package:habit_tracker/core/services/consent_service.dart';
import 'package:habit_tracker/features/info/application/providers/app_info_provider.dart';
import 'package:habit_tracker/features/settings/application/controllers/notification_settings_controller.dart';
import 'package:habit_tracker/features/settings/application/controllers/theme_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/notification_settings_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/theme_provider.dart';
import 'package:habit_tracker/core/telemetry/controllers/telemetry_controller.dart';
import 'package:habit_tracker/core/telemetry/providers/telemetry_provider.dart';
import 'package:habit_tracker/features/settings/application/controllers/language_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/language_provider.dart';
import 'package:habit_tracker/l10n/app_localizations_en.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  late TelemetryController controller;
  late ThemeController themeController;
  late NotificationSettingsController notificationController;
  late LanguageController languageController;
  late PackageInfo packageInfo;
  late GoRouter router;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ConsentService.reset();

    controller = TelemetryController(enableFirebase: false);
    await controller.initialize();

    themeController = ThemeController();
    await themeController.load();

    notificationController = NotificationSettingsController();
    await notificationController.load();

    languageController = LanguageController();
    await languageController.load();

    packageInfo = PackageInfo(
      appName: 'Habit Tracker',
      packageName: 'com.example.habit',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: 'sig',
      installerStore: null,
    );

    navigatorKey = GlobalKey<NavigatorState>();
    router = GoRouter(
      navigatorKey: navigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
  });

  tearDown(() {
    router.dispose();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        telemetryControllerProvider.overrideWith((ref) => controller),
        themeControllerProvider.overrideWith((ref) => themeController),
        languageControllerProvider.overrideWith((ref) => languageController),
        notificationSettingsProvider.overrideWith(
          (ref) => notificationController,
        ),
        appInfoProvider.overrideWith((ref) async => packageInfo),
      ],
      child: HabitTrackerApp(router: router, rootNavigatorKey: navigatorKey),
    );
  }

  testWidgets('dismisses consent dialog when opting out', (tester) async {
    final l10n = AppLocalizationsEn();
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump();

    expect(find.text(l10n.consentDialogTitle), findsOneWidget);

    await tester.tap(find.text(l10n.consentNotNow));
    await tester.pumpAndSettle();

    expect(controller.hasRecordedDecision, isTrue);
    expect(controller.isConsentGranted, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('records consent when user accepts', (tester) async {
    final l10n = AppLocalizationsEn();
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text(l10n.consentShare));
    await tester.pumpAndSettle();

    expect(controller.hasRecordedDecision, isTrue);
    expect(controller.isConsentGranted, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });
}

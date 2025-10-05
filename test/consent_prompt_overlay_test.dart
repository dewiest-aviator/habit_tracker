import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/main.dart';
import 'package:habit_tracker/services/consent_service.dart';
import 'package:habit_tracker/state/telemetry_controller.dart';
import 'package:habit_tracker/state/telemetry_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late TelemetryController controller;
  late GoRouter router;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ConsentService.reset();

    controller = TelemetryController(enableFirebase: false);
    await controller.initialize();

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
      ],
      child: HabitTrackerApp(router: router, rootNavigatorKey: navigatorKey),
    );
  }

  testWidgets('dismisses consent dialog when opting out', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump();

    expect(find.text('Share Anonymous Usage Data?'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(controller.hasRecordedDecision, isTrue);
    expect(controller.isConsentGranted, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('records consent when user accepts', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(controller.hasRecordedDecision, isTrue);
    expect(controller.isConsentGranted, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });
}

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
  });

  setUp(AnalyticsService.reset);

  test('configure wires analytics and enables collection', () async {
    final analytics = _MockFirebaseAnalytics();

    when(
      () => analytics.setAnalyticsCollectionEnabled(true),
    ).thenAnswer((_) async {});
    when(() => analytics.logAppOpen()).thenAnswer((_) async {});
    when(
      () => analytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      ),
    ).thenAnswer((_) async {});

    await AnalyticsService.configure(analytics);

    expect(AnalyticsService.enabled, isTrue);
    expect(AnalyticsService.observer, isNotNull);

    await AnalyticsService.logAppOpen();
    await AnalyticsService.logEvent('test_event', parameters: {'foo': 'bar'});
    await AnalyticsService.logScreenView('home', screenClass: 'HomeScreen');

    verify(() => analytics.setAnalyticsCollectionEnabled(true)).called(1);
    verify(() => analytics.logAppOpen()).called(1);
    verify(
      () => analytics.logEvent(name: 'test_event', parameters: {'foo': 'bar'}),
    ).called(1);
    verify(
      () => analytics.logScreenView(
        screenName: 'home',
        screenClass: 'HomeScreen',
      ),
    ).called(1);
  });

  test('logEvent strips null parameters before forwarding', () async {
    final analytics = _MockFirebaseAnalytics();

    when(
      () => analytics.setAnalyticsCollectionEnabled(true),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});

    await AnalyticsService.configure(analytics);

    await AnalyticsService.logEvent(
      'test_event',
      parameters: {'keep': 'value', 'drop': null},
    );

    verify(
      () =>
          analytics.logEvent(name: 'test_event', parameters: {'keep': 'value'}),
    ).called(1);
  });

  test('log calls are safe when analytics is disabled', () async {
    expect(AnalyticsService.enabled, isFalse);
    expect(AnalyticsService.observer, isNull);

    await AnalyticsService.logAppOpen();
    await AnalyticsService.logEvent('noop');
    await AnalyticsService.logScreenView('noop');

    expect(AnalyticsService.enabled, isFalse);
    expect(AnalyticsService.observer, isNull);
  });
}

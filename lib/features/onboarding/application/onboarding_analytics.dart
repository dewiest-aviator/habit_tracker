import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/analytics_service.dart';
import 'starter_habit_template.dart';

@immutable
class OnboardingAnalytics {
  const OnboardingAnalytics();

  Future<void> logPageView(int index) {
    return AnalyticsService.logEvent(
      'onboarding_page_view',
      parameters: {'page_index': index},
    );
  }

  Future<void> logGetStartedTap() {
    return AnalyticsService.logEvent('onboarding_get_started');
  }

  Future<void> logSkip() {
    return AnalyticsService.logEvent('onboarding_skip');
  }

  Future<void> logHabitToggle(
    StarterHabitTemplate template,
    String label,
    bool selected,
  ) {
    return AnalyticsService.logEvent(
      'onboarding_habit_toggle',
      parameters: {
        'template_id': template.id,
        'habit_hash': _hashLabel(label),
        'selected': selected ? 1 : 0,
      },
    );
  }

  Future<void> logNotificationsRequest({required bool granted}) {
    return AnalyticsService.logEvent(
      'onboarding_notifications_request',
      parameters: {'granted': granted ? 1 : 0},
    );
  }

  Future<void> logNotificationsDeclined() {
    return AnalyticsService.logEvent('onboarding_notifications_decline');
  }

  Future<void> logComplete({required int selectedCount}) {
    return AnalyticsService.logEvent(
      'onboarding_complete',
      parameters: {'selected_count': selectedCount},
    );
  }

  Future<void> logConsentUpdate({
    required String channel,
    required bool granted,
  }) {
    return AnalyticsService.logEvent(
      'onboarding_consent_update',
      parameters: {
        'channel': channel,
        'granted': granted ? 1 : 0,
      },
    );
  }

  String _hashLabel(String label) {
    final digest = sha1.convert(utf8.encode(label));
    return digest.toString().substring(0, 12);
  }
}

final onboardingAnalyticsProvider = Provider<OnboardingAnalytics>((ref) {
  return const OnboardingAnalytics();
});

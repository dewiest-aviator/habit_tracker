# Analytics Event Catalog

This document lists the analytics events currently instrumented in the Habit Tracker app. Update it whenever you add, rename, or remove an event so that product, marketing, and data teams have a reliable reference.

| Event Name | Trigger | Parameters | Notes |
|------------|---------|------------|-------|
| `open_settings_tap` | User taps the settings icon on the home screen. | _None_ | Logged via `AnalyticsService.logEvent` when the settings button is pressed. |
| `add_habit_tap` | User taps the add habit button on the home screen. | _None_ | Logged via `AnalyticsService.logEvent` when starting the add habit flow. |

## Instrumentation checklist

- Ensure events are routed through `AnalyticsService` so they honor consent state.
- Add or update automated tests verifying analytics is enabled/disabled based on user consent when applicable.
- Confirm new events do not include personally identifiable information and align with the privacy policy in `docs/privacy-policy.html`.

# Agent Guidelines for Habit Tracker

## Scope
These instructions apply to the entire repository unless a nested `AGENTS.md` overrides them.

## Tooling & Environment
- Manage the Flutter SDK with [FVM](https://fvm.app/) and use the pinned version from `.fvmrc` (currently `3.35.4`). Prefer commands prefixed with `fvm flutter …` so the correct SDK is used.
- Run `fvm flutter pub get` whenever you change dependencies or add new packages.
- Before delivering changes, run the static analysis suite with `fvm flutter analyze`.
- Execute the test suite with coverage using `fvm flutter test --coverage`. Ensure the patch coverage reported locally stays at or above the 60% minimum defined in `codecov.yml`.

## Code Style & Architecture
- Follow the lints configured in `analysis_options.yaml`; avoid disabling rules unless absolutely necessary and document any exceptions inline.
- Keep imports organized and prefer using existing abstractions (Riverpod providers, GoRouter routes, theme extensions) over introducing duplicate patterns.
- When introducing new state or services, back them with unit tests in `test/` and, if applicable, provider integration tests.

## Localization & Assets
- Add user-facing strings to the ARB files under `lib/l10n/` and regenerate localizations with `fvm flutter gen-l10n`.
- Register new assets in `pubspec.yaml` under the appropriate section and include platform-specific setup if required.

## Documentation & Changelog
- Update relevant documentation (e.g., `README.md`, `docs/`) when adding features or changing workflows.
- For behavior changes, include or update tests demonstrating the expected UX.

## Analytics & Telemetry
- Route all analytics instrumentation through `AnalyticsService` so that consent toggles remain respected across platforms.
- When introducing a new analytics event, document the event name, triggering interaction, and expected parameters in `docs/analytics_events.md`.
- Cover analytics flows with unit or widget tests that assert consent-gated behavior (e.g., verifying that collection is disabled when a user opts out).

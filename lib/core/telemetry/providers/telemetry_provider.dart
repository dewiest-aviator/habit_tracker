import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/core/telemetry/controllers/telemetry_controller.dart';

/// Riverpod provider for the global [TelemetryController].
///
/// The controller is initialized in `main.dart` and injected via
/// [ProviderScope.overrides] so that widget tests can supply their own
/// instances easily.
final telemetryControllerProvider =
    NotifierProvider<TelemetryController, TelemetryState>(
      TelemetryController.new,
    );

import 'package:flutter/widgets.dart';

import 'telemetry_controller.dart';

class TelemetryProvider extends InheritedNotifier<TelemetryController> {
  const TelemetryProvider({
    super.key,
    required TelemetryController controller,
    required super.child,
  }) : super(notifier: controller);

  static TelemetryController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<TelemetryProvider>();
    assert(provider != null, 'TelemetryProvider not found in context');
    return provider!.notifier!;
  }

  @override
  bool updateShouldNotify(
    covariant InheritedNotifier<TelemetryController> oldWidget,
  ) {
    return oldWidget.notifier != notifier;
  }
}

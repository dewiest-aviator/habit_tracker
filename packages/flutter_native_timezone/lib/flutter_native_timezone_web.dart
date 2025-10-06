import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// The plugin class for the web, acts as the plugin inside bits
/// and connects to the js world.
class FlutterNativeTimezonePlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'flutter_native_timezone',
      const StandardMethodCodec(),
      registrar,
    );
    final FlutterNativeTimezonePlugin instance = FlutterNativeTimezonePlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getLocalTimezone':
        return _getLocalTimeZone();
      case 'getAvailableTimezones':
        return <String>[_getLocalTimeZone()];
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              "The flutter_native_timezone plugin for web doesn't implement the method '${call.method}'",
        );
    }
  }

  /// Platform-specific implementation of determining the user's
  /// local time zone when running on the web.
  String _getLocalTimeZone() {
    try {
      final JSIntl? intl = _intl;
      if (intl == null) {
        return 'UTC';
      }
      final JSDateTimeFormat Function() factory = intl.dateTimeFormat;
      final JSResolvedOptions resolvedOptions = factory().resolvedOptions();
      final JSString? timeZone = resolvedOptions.timeZone;
      final String? resolved = timeZone?.toDart;
      return (resolved == null || resolved.isEmpty) ? 'UTC' : resolved;
    } catch (_) {
      return 'UTC';
    }
  }
}

@JS('Intl')
external JSIntl? get _intl;

@JS()
@staticInterop
class JSIntl {}

extension JSIntlBindings on JSIntl {
  @JS('DateTimeFormat')
  external JSDateTimeFormat Function() get dateTimeFormat;
}

@JS()
@staticInterop
class JSDateTimeFormat {}

extension JSDateTimeFormatBindings on JSDateTimeFormat {
  external JSResolvedOptions resolvedOptions();
}

@JS()
@staticInterop
class JSResolvedOptions {}

extension JSResolvedOptionsBindings on JSResolvedOptions {
  external JSString? get timeZone;
}

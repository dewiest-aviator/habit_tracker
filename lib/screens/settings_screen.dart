import 'package:flutter/material.dart';

import '../state/telemetry_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final telemetry = TelemetryProvider.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AnimatedBuilder(
        animation: telemetry,
        builder: (context, _) {
          final consent = telemetry.isConsentGranted;
          final loaded = telemetry.isLoaded;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile.adaptive(
                title: const Text('Share anonymous usage & crash reports'),
                subtitle: const Text(
                  'Helps us spot issues faster. You can change this at any time.',
                ),
                value: consent,
                onChanged: loaded
                    ? (value) => telemetry.updateConsent(value)
                    : null,
              ),
              const SizedBox(height: 16),
              const ListTile(
                title: Text('Theme'),
                subtitle: Text('Follows system (Light/Dark)'),
                leading: Icon(Icons.brightness_6),
              ),
              const SizedBox(height: 8),
              const ListTile(
                title: Text('About'),
                subtitle: Text('Habit Tracker MVP'),
                leading: Icon(Icons.info_outline),
              ),
            ],
          );
        },
      ),
    );
  }
}

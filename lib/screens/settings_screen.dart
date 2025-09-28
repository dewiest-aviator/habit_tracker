import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('Theme'),
            subtitle: Text('Follows system (Light/Dark)'),
            leading: Icon(Icons.brightness_6),
          ),
          SizedBox(height: 8),
          ListTile(
            title: Text('About'),
            subtitle: Text('Habit Tracker MVP'),
            leading: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
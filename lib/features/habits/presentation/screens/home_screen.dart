import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/services/analytics_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: Center(
        child: ElevatedButton.icon(
          key: const Key('btn_settings'),
          onPressed: () {
            unawaited(AnalyticsService.logEvent('open_settings_tap'));
            context.push('/settings');
          },
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          unawaited(AnalyticsService.logEvent('add_habit_tap'));
        },
        tooltip: 'Add habit',
        child: const Icon(Icons.add),
      ),
    );
  }
}

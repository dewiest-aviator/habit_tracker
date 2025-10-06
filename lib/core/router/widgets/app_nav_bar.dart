import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/localization/l10n_extensions.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final router = GoRouter.maybeOf(context);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (router == null || index == currentIndex) {
          return;
        }
        switch (index) {
          case 0:
            router.go('/');
            break;
          case 1:
            router.go('/history');
            break;
          case 2:
            router.go('/settings');
            break;
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.check_circle_outline),
          selectedIcon: const Icon(Icons.check_circle),
          label: l10n.navHomeLabel,
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today),
          label: l10n.navHistoryLabel,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: l10n.navSettingsLabel,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:habit_tracker/core/localization/l10n_extensions.dart';
import 'package:habit_tracker/core/router/widgets/app_nav_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.historyPlaceholder,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      bottomNavigationBar: const AppNavBar(currentIndex: 1),
    );
  }
}

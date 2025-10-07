import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/localization/l10n_extensions.dart';
import 'package:habit_tracker/features/habits/application/habit_form_controller.dart';
import 'package:habit_tracker/features/habits/application/home_analytics.dart';
import 'package:habit_tracker/features/habits/application/home_controller.dart';
import 'package:habit_tracker/features/habits/application/home_state.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/habit_card.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/home_empty_state.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/home_progress_summary.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.read(homeAnalyticsProvider);

    ref.listen<HomeState>(homeControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      final wasLoading = previous?.isLoading ?? true;
      if (wasLoading && !next.isLoading) {
        analytics.logView(
          totalHabits: next.habits.length,
          completedHabits: next.completedCount,
          isEmpty: next.isEmpty,
        );
      }
    });

    final state = ref.watch(homeControllerProvider);
    final notifier = ref.read(homeControllerProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTodayTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          analytics.logRefresh(state);
          await notifier.refresh();
        },
        child: _HomeBody(
          state: state,
          onToggleHabit: (habit) => _handleToggle(context, ref, habit),
          onShowActions: (habit) => _showHabitActions(context, ref, habit),
        ),
      ),
      floatingActionButton: state.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () async {
                if (!state.canAddHabit) {
                  analytics.logAddHabitLimitReached(state.habits.length);
                  final message = l10n.habitFormLimitError;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(message)));
                  return;
                }
                analytics.logAddHabitTap();
                final result = await context.pushNamed('habit_form');
                if (!context.mounted) return;
                _handleFormResult(context, result);
              },
              tooltip: l10n.homeAddHabitTooltip,
              child: const Icon(Icons.add),
            ),
    );
  }

  Future<void> _handleToggle(
    BuildContext context,
    WidgetRef ref,
    HomeHabitViewData habit,
  ) async {
    HapticFeedback.lightImpact();
    final result = await ref
        .read(homeControllerProvider.notifier)
        .toggleHabit(habit.habit.id);
    if (!context.mounted || result == null) {
      return;
    }

    final analytics = ref.read(homeAnalyticsProvider);
    analytics.logToggle(habit.habit, result);

    final message = result
        ? context.l10n.homeCompletionSnackbar(habit.habit.name)
        : context.l10n.homeUndoSnackbar(habit.habit.name);
    unawaited(
      Future<void>.delayed(Duration.zero, () {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }),
    );
  }

  Future<void> _showHabitActions(
    BuildContext context,
    WidgetRef ref,
    HomeHabitViewData habit,
  ) async {
    final analytics = ref.read(homeAnalyticsProvider);
    analytics.logHabitActionsOpen(habit.habit);
    final action = await showModalBottomSheet<_HabitAction>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _HabitActionsSheet(
          habitName: habit.habit.name,
          isCompleted: habit.isCompleted,
        );
      },
    );

    if (!context.mounted || action == null) {
      return;
    }

    switch (action) {
      case _HabitAction.edit:
        analytics.logHabitActionSelected(habit.habit, action: 'edit');
        final result = await context.pushNamed(
          'habit_form',
          extra: habit.habit.id,
        );
        if (!context.mounted) return;
        _handleFormResult(context, result);
        break;
      case _HabitAction.undo:
        if (habit.isCompleted) {
          analytics.logHabitActionSelected(habit.habit, action: 'undo');
          await _handleToggle(context, ref, habit);
        }
        break;
    }
  }

  void _handleFormResult(BuildContext context, Object? result) {
    final l10n = context.l10n;
    if (result is HabitFormSaveResult &&
        result.status == HabitFormSaveStatus.success) {
      final message = result.isNew
          ? l10n.habitFormCreateSuccess
          : l10n.habitFormUpdateSuccess;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } else if (result is HabitFormDeleteResult &&
        result.status == HabitFormDeleteStatus.deleted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.habitFormDeleteSuccess)));
    }
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.state,
    required this.onToggleHabit,
    required this.onShowActions,
  });

  final HomeState state;
  final Future<void> Function(HomeHabitViewData habit) onToggleHabit;
  final Future<void> Function(HomeHabitViewData habit) onShowActions;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.habits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: HomeEmptyState(
                    onAdd: () => context.pushNamed('habit_form'),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == 0) {
          return HomeProgressSummary(
            completed: state.completedCount,
            total: state.habits.length,
          );
        }

        final habit = state.habits[index - 1];
        return HabitCard(
          data: habit,
          onToggle: () => onToggleHabit(habit),
          onLongPress: () => onShowActions(habit),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: state.habits.length + 1,
    );
  }
}

enum _HabitAction { edit, undo }

class _HabitActionsSheet extends StatelessWidget {
  const _HabitActionsSheet({
    required this.habitName,
    required this.isCompleted,
  });

  final String habitName;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.homeEditHabitLabel(habitName)),
            onTap: () => Navigator.of(context).pop(_HabitAction.edit),
          ),
          if (isCompleted)
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(l10n.homeUndoHabitLabel(habitName)),
              onTap: () => Navigator.of(context).pop(_HabitAction.undo),
            ),
        ],
      ),
    );
  }
}

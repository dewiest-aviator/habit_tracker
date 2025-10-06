import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../application/onboarding_controller.dart';
import '../../application/onboarding_state.dart';
import '../../application/starter_habit_template.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  ProviderSubscription<OnboardingState>? _subscription;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _subscription = ref.listenManual<OnboardingState>(
      onboardingControllerProvider,
      (previous, next) {
        if (!_pageController.hasClients) {
          return;
        }
        final currentPage =
            _pageController.page?.round() ?? _pageController.initialPage;
        if (currentPage == next.pageIndex) {
          return;
        }
        _pageController.animateToPage(
          next.pageIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state.pageIndex < 2)
                    TextButton(
                      onPressed: () {
                        controller.skipToNotifications();
                      },
                      child: Text(l10n.onboardingSkip),
                    ),
                ],
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: controller.setPageIndex,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    _WelcomePage(
                      onGetStarted: () => controller.setPageIndex(1),
                    ),
                    _HabitSelectionPage(state: state),
                    _NotificationsPage(state: state),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProgressDots(currentIndex: state.pageIndex, total: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends ConsumerWidget {
  const _WelcomePage({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Text(
          l10n.appTitle,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.onboardingTagline,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: onGetStarted,
          child: Text(l10n.onboardingGetStarted),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingGoal,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _HabitSelectionPage extends ConsumerWidget {
  const _HabitSelectionPage({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.onboardingHabitsTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingHabitsSubtitle,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final template in starterHabitTemplates)
                  _StarterHabitCard(
                    template: template,
                    label: template.label(l10n),
                    selected: state.selectedHabits.containsKey(template.id),
                    onTap: () =>
                        controller.toggleHabit(template, template.label(l10n)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.canContinue
                ? () => controller.setPageIndex(2)
                : null,
            child: Text(l10n.onboardingContinue),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingSelectionHint,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _NotificationsPage extends ConsumerWidget {
  const _NotificationsPage({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.onboardingNotificationsTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingNotificationsSubtitle,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isRequestingPermission
                ? null
                : () => controller.enableNotifications(),
            child: state.isRequestingPermission
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(l10n.onboardingEnableReminders),
          ),
        ),
        TextButton(
          onPressed: state.isRequestingPermission
              ? null
              : () => controller.declineNotifications(),
          child: Text(l10n.onboardingMaybeLater),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: state.hasNotificationChoice
              ? Column(
                  key: ValueKey(state.permissionStatus),
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      state.permissionStatus ==
                              NotificationPermissionStatus.granted
                          ? l10n.onboardingNotificationsGranted
                          : l10n.onboardingNotificationsDenied,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.onboardingFinishTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const Spacer(),
        if (state.errorMessage != null) ...[
          Text(
            l10n.onboardingError(state.errorMessage!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.canFinish
                ? () async {
                    final success = await controller.completeOnboarding();
                    if (!context.mounted || !success) {
                      return;
                    }
                    if (context.mounted) {
                      context.goNamed('home');
                    }
                  }
                : null,
            child: Text(l10n.onboardingFinishCta),
          ),
        ),
      ],
    );
  }
}

class _StarterHabitCard extends StatelessWidget {
  const _StarterHabitCard({
    required this.template,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final StarterHabitTemplate template;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Semantics(
      label: label,
      button: true,
      toggled: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(template.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.currentIndex, required this.total});

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

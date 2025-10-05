import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

@immutable
class StarterHabitTemplate {
  const StarterHabitTemplate({
    required this.id,
    required this.emoji,
    required this.color,
  });

  final String id;
  final String emoji;
  final int color;

  String label(AppLocalizations l10n) {
    switch (id) {
      case 'meditate':
        return l10n.onboardingHabitMeditate;
      case 'walk':
        return l10n.onboardingHabitWalk;
      case 'hydrate':
        return l10n.onboardingHabitHydrate;
      case 'journal':
        return l10n.onboardingHabitJournal;
      case 'stretch':
        return l10n.onboardingHabitStretch;
      case 'read':
        return l10n.onboardingHabitRead;
      default:
        return id;
    }
  }
}

const starterHabitTemplates = <StarterHabitTemplate>[
  StarterHabitTemplate(
    id: 'meditate',
    emoji: '🧘',
    color: 0xFF7C83FD,
  ),
  StarterHabitTemplate(
    id: 'walk',
    emoji: '🚶',
    color: 0xFF00B894,
  ),
  StarterHabitTemplate(
    id: 'hydrate',
    emoji: '💧',
    color: 0xFF40C4FF,
  ),
  StarterHabitTemplate(
    id: 'journal',
    emoji: '📓',
    color: 0xFFFFB347,
  ),
  StarterHabitTemplate(
    id: 'stretch',
    emoji: '🤸',
    color: 0xFFF06292,
  ),
  StarterHabitTemplate(
    id: 'read',
    emoji: '📚',
    color: 0xFF6C5CE7,
  ),
];

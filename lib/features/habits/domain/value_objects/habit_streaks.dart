import 'package:flutter/foundation.dart';

@immutable
class HabitStreaks {
  const HabitStreaks({required this.current, required this.best});

  final int current;
  final int best;

  HabitStreaks copyWith({int? current, int? best}) {
    return HabitStreaks(
      current: current ?? this.current,
      best: best ?? this.best,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitStreaks &&
        other.current == current &&
        other.best == best;
  }

  @override
  int get hashCode => Object.hash(current, best);

  @override
  String toString() => 'HabitStreaks(current: $current, best: $best)';
}

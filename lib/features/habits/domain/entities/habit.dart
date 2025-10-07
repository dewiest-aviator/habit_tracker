import 'package:flutter/foundation.dart';

import '../value_objects/habit_weekday.dart';

class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required List<int> days,
    required this.reminderId,
    required this.reminderTime,
    required this.bestStreak,
    required this.currentStreak,
    DateTime? createdAt,
    this.lastChecked,
  }) : assert(
         color >= 0 && color <= 0xFFFFFFFF,
         'color must be between 0x00000000 and 0xFFFFFFFF',
       ),
       days = List.unmodifiable(_normalizeDays(days)),
       createdAt = _normalizeCreationDate(createdAt ?? _defaultCreationDate);

  final String id;
  final String name;
  final String emoji;
  final int color;
  final List<int> days;
  final String reminderId;
  final String reminderTime;
  final int bestStreak;
  final int currentStreak;
  final DateTime createdAt;
  final DateTime? lastChecked;

  static final DateTime _defaultCreationDate =
      DateTime.fromMillisecondsSinceEpoch(0);

  static DateTime get defaultCreationDate => _defaultCreationDate;

  bool get hasExplicitCreationDate => createdAt != _defaultCreationDate;

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    int? color,
    List<int>? days,
    String? reminderId,
    String? reminderTime,
    int? bestStreak,
    int? currentStreak,
    DateTime? createdAt,
    DateTime? lastChecked,
    bool clearLastChecked = false,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      days: days ?? this.days,
      reminderId: reminderId ?? this.reminderId,
      reminderTime: reminderTime ?? this.reminderTime,
      bestStreak: bestStreak ?? this.bestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      createdAt: createdAt ?? this.createdAt,
      lastChecked: clearLastChecked ? null : (lastChecked ?? this.lastChecked),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color,
      'days': days,
      'reminderId': reminderId,
      'reminderTime': reminderTime,
      'bestStreak': bestStreak,
      'currentStreak': currentStreak,
      'createdAt': createdAt.toIso8601String(),
      'lastChecked': lastChecked?.toIso8601String(),
    };
  }

  static Habit fromMap(Map<String, Object?> map) {
    final id = map['id'] as String?;
    final name = map['name'] as String?;
    final emoji = map['emoji'] as String?;
    final color = map['color'] as int?;
    final bestStreak = map['bestStreak'] as int?;
    final currentStreak = map['currentStreak'] as int?;

    return Habit(
      id: _requireField(id, 'id'),
      name: _requireField(name, 'name'),
      emoji: _requireField(emoji, 'emoji'),
      color: _requireField(color, 'color'),
      days: _normalizeDays(_parseIntList(map['days'])),
      reminderId: _requireField(map['reminderId'] as String?, 'reminderId'),
      reminderTime: _requireField(
        map['reminderTime'] as String?,
        'reminderTime',
      ),
      bestStreak: _requireField(bestStreak, 'bestStreak'),
      currentStreak: _requireField(currentStreak, 'currentStreak'),
      createdAt: _parseDate(map['createdAt']) ?? _defaultCreationDate,
      lastChecked: map['lastChecked'] == null
          ? null
          : DateTime.tryParse(map['lastChecked'] as String),
    );
  }

  static List<int> _parseIntList(Object? value) {
    if (value is List) {
      return value.whereType<int>().toList();
    }
    return const <int>[];
  }

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static T _requireField<T>(T? value, String field) {
    if (value == null) {
      throw ArgumentError.notNull(field);
    }
    return value;
  }

  static List<int> _normalizeDays(List<int> days) {
    final cleaned = days.where((day) => day >= 0 && day <= 6).toSet().toList()
      ..sort();
    return cleaned;
  }

  static DateTime _normalizeCreationDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<HabitWeekday> get weekdaySelections => HabitWeekday.fromIndexList(days);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.id == id &&
        other.name == name &&
        other.emoji == emoji &&
        other.color == color &&
        listEquals(other.days, days) &&
        other.reminderId == reminderId &&
        other.reminderTime == reminderTime &&
        other.bestStreak == bestStreak &&
        other.currentStreak == currentStreak &&
        other.createdAt == createdAt &&
        other.lastChecked == lastChecked;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    emoji,
    color,
    Object.hashAll(days),
    reminderId,
    reminderTime,
    bestStreak,
    currentStreak,
    createdAt,
    lastChecked,
  );

  @override
  String toString() =>
      'Habit(id: $id, name: $name, streak: $currentStreak/$bestStreak, createdAt: $createdAt)';
}

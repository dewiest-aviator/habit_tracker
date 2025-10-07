import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_helpers.dart';
import '../../application/history_state.dart';

typedef WeekStripSelectCallback = void Function(DateTime date);

class WeekStrip extends StatefulWidget {
  const WeekStrip({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onSelect,
    this.accentColor,
  });

  final List<HistoryDayViewData> days;
  final DateTime selectedDate;
  final WeekStripSelectCallback onSelect;
  final Color? accentColor;

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  late final ScrollController _controller;

  static const double _itemWidth = 72;
  static const double _itemSpacing = 12;
  static const double _horizontalPadding = 16;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant WeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedChanged = !DateHelpers.isSameDay(
      oldWidget.selectedDate,
      widget.selectedDate,
    );
    if (selectedChanged || oldWidget.days.length != widget.days.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _resolveAccentColor(BuildContext context) {
    return widget.accentColor ?? Theme.of(context).colorScheme.primary;
  }

  void _scrollToSelected() {
    if (!_controller.hasClients || widget.days.isEmpty) {
      return;
    }
    final index = widget.days.indexWhere(
      (day) => DateHelpers.isSameDay(day.date, widget.selectedDate),
    );
    if (index == -1) return;

    final rawOffset = index * (_itemWidth + _itemSpacing);
    final clampedOffset = rawOffset.clamp(
      _controller.position.minScrollExtent,
      _controller.position.maxScrollExtent,
    );
    _controller.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveAccentColor(context);
    final today = DateHelpers.startOfDay(DateTime.now());
    final dateFormat = DateFormat.Md();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        controller: _controller,
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final day = widget.days[index];
          final isSelected = DateHelpers.isSameDay(
            day.date,
            widget.selectedDate,
          );
          final isToday = DateHelpers.isSameDay(day.date, today);
          final dayLabel = DateFormat.E().format(day.date).substring(0, 1);
          final dateLabel = dateFormat.format(day.date);

          return SizedBox(
            width: _itemWidth,
            child: _WeekStripItem(
              label: dayLabel,
              dateLabel: dateLabel,
              completionRate: day.completionRate,
              isSelected: isSelected,
              isToday: isToday,
              color: color,
              onTap: () => widget.onSelect(day.date),
              hasHabits: day.hasHabits,
            ),
          );
        },
        separatorBuilder: (context, index) =>
            const SizedBox(width: _itemSpacing),
        itemCount: widget.days.length,
      ),
    );
  }
}

class _WeekStripItem extends StatelessWidget {
  const _WeekStripItem({
    required this.label,
    required this.dateLabel,
    required this.completionRate,
    required this.isSelected,
    required this.isToday,
    required this.color,
    required this.onTap,
    required this.hasHabits,
  });

  final String label;
  final String dateLabel;
  final double completionRate;
  final bool isSelected;
  final bool isToday;
  final Color color;
  final VoidCallback onTap;
  final bool hasHabits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = hasHabits ? color : theme.colorScheme.outlineVariant;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: hasHabits ? completionRate : 0,
                  strokeWidth: 4,
                  color: baseColor,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? baseColor.withValues(alpha: hasHabits ? 0.2 : 0.12)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? baseColor
                        : isToday
                        ? baseColor.withValues(alpha: 0.6)
                        : theme.dividerColor.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  dateLabel,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? baseColor
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

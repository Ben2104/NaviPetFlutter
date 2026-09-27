import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/course_class.dart';
import '../theme/app_theme.dart';

/// Week view of the user's classes (Mon–Sun). The visible hours grow to fit
/// the earliest and latest class so evening and early-morning classes are
/// never clipped.
class ScheduleCalendar extends StatelessWidget {
  const ScheduleCalendar({
    super.key,
    required this.classes,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onTapClass,
    this.today,
  });

  final List<CourseClass> classes;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<CourseClass> onTapClass;

  /// Overrides the current date; for tests.
  final DateTime? today;

  static const gridKey = ValueKey('schedule-grid');

  static const _defaultStartHour = 8;
  static const _defaultEndHour = 19;
  static const _dayWidth = 96.0;
  static const _timeWidth = 58.0;
  static const _rowHeight = 68.0;
  static const _minBlockHeight = 42.0;
  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// The hour span the grid shows: at least 8 AM–7 PM, widened to the
  /// whole hours covering every class.
  static ({int startHour, int endHour}) hourRange(
    Iterable<CourseClass> classes,
  ) {
    var start = _defaultStartHour;
    var end = _defaultEndHour;
    for (final course in classes) {
      start = math.min(start, _minutes(course.startTime) ~/ 60);
      end = math.max(end, (_minutes(course.endTime) / 60).ceil());
    }
    return (startHour: start, endHour: math.min(end, 24));
  }

  static int _minutes(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? _defaultStartHour;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return hour * 60 + minute;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = today ?? DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final (:startHour, :endHour) = hourRange(classes);
    final gridHeight = (endHour - startHour) * _rowHeight;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: _timeWidth + _dayWidth * 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.petInk,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const SizedBox(width: _timeWidth),
                    for (var index = 0; index < 7; index++)
                      _dayHeader(
                        DateTime(
                          weekStart.year,
                          weekStart.month,
                          weekStart.day + index,
                        ),
                        _dayNames[index],
                        isToday: index == now.weekday - 1,
                      ),
                  ],
                ),
              ),
              SizedBox(
                key: gridKey,
                height: gridHeight,
                child: Stack(
                  children: [
                    for (var row = 0; row <= endHour - startHour; row++)
                      Positioned(
                        top: math.min(row * _rowHeight, gridHeight - 1),
                        left: 0,
                        right: 0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: _timeWidth,
                              child: row == endHour - startHour
                                  ? null
                                  : Text(
                                      _hourLabel(startHour + row),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.muted,
                                      ),
                                    ),
                            ),
                            Container(
                              width: _dayWidth * 7,
                              height: 1,
                              color: AppColors.cardBorder,
                            ),
                          ],
                        ),
                      ),
                    for (var day = 0; day < 7; day++)
                      Positioned(
                        left: _timeWidth + day * _dayWidth,
                        top: 0,
                        bottom: 0,
                        child: Container(width: 1, color: AppColors.cardBorder),
                      ),
                    for (final course in classes)
                      for (final weekday in course.weekdays)
                        if (weekday >= 1 && weekday <= 7)
                          _classBlock(
                            course,
                            weekday,
                            startHour: startHour,
                            gridHeight: gridHeight,
                          ),
                  ],
                ),
              ),
              if (classes.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Add a class to populate your schedule.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayHeader(DateTime date, String name, {required bool isToday}) {
    final selected = _sameDay(date, selectedDate);
    final foreground = selected ? Colors.white : AppColors.petInk;
    return SizedBox(
      width: _dayWidth,
      child: MergeSemantics(
        child: Semantics(
          button: true,
          selected: selected,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelectDate(date),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.petInk : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !selected
                      ? Border.all(color: AppColors.petInk)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 11,
                        color: selected ? Colors.white : AppColors.muted,
                      ),
                    ),
                    Text(
                      '${date.month}/${date.day}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _hourLabel(int hour) {
    final suffix = hour >= 12 && hour < 24 ? 'PM' : 'AM';
    final display = hour % 12 == 0 ? 12 : hour % 12;
    return '$display:00 $suffix';
  }

  Widget _classBlock(
    CourseClass course,
    int weekday, {
    required int startHour,
    required double gridHeight,
  }) {
    final start = _minutes(course.startTime);
    final end = _minutes(course.endTime);
    final top = ((start - startHour * 60) / 60 * _rowHeight).clamp(
      0.0,
      gridHeight - _minBlockHeight,
    );
    final height = ((end - start) / 60 * _rowHeight).clamp(
      _minBlockHeight,
      gridHeight - top,
    );
    return Positioned(
      key: ValueKey('class-${course.id}-$weekday'),
      left: _timeWidth + (weekday - 1) * _dayWidth + 4,
      top: top,
      width: _dayWidth - 8,
      height: height,
      child: GestureDetector(
        onTap: () => onTapClass(course),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: course.isOnline
                ? const Color(0xFFD9E8F7)
                : const Color(0xFFC5DDA2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.petInk.withValues(alpha: .18)),
          ),
          child: Text(
            '${course.courseCode}\n${course.courseName}\n'
            '${course.startTime}-${course.endTime}\n${course.locationLabel}',
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              height: 1.15,
              color: AppColors.petInk,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

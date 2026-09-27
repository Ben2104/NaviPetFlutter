import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navipet/data/course_class.dart';
import 'package:navipet/widgets/schedule_calendar.dart';

CourseClass _course(String id, String start, String end, List<int> days) =>
    CourseClass(
      id: id,
      courseCode: 'CECS $id',
      courseName: 'Course $id',
      building: 'VEC',
      room: '',
      weekdays: days,
      startTime: start,
      endTime: end,
      latitude: 33.78,
      longitude: -118.11,
    );

Future<void> _pump(
  WidgetTester tester, {
  required List<CourseClass> classes,
  DateTime? selected,
  ValueChanged<DateTime>? onSelectDate,
}) {
  final today = DateTime(2026, 9, 23); // a Wednesday
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ScheduleCalendar(
            classes: classes,
            today: today,
            selectedDate: selected ?? today,
            onSelectDate: onSelectDate ?? (_) {},
            onTapClass: (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  test('the visible hours grow to fit early and evening classes', () {
    expect(ScheduleCalendar.hourRange(const []), (startHour: 8, endHour: 19));
    expect(
      ScheduleCalendar.hourRange([
        _course('1', '07:00:00', '07:50:00', [1]),
        _course('2', '19:00:00', '21:45:00', [2]),
      ]),
      (startHour: 7, endHour: 22),
    );
  });

  testWidgets('an evening class is drawn fully inside the grid', (
    tester,
  ) async {
    await _pump(
      tester,
      classes: [
        _course('2', '19:00:00', '21:45:00', [3]),
      ],
    );

    final grid = tester.getRect(find.byKey(ScheduleCalendar.gridKey));
    final block = tester.getRect(find.byKey(const ValueKey('class-2-3')));
    expect(block.top, greaterThanOrEqualTo(grid.top));
    expect(block.bottom, lessThanOrEqualTo(grid.bottom));
    expect(block.height, greaterThan(100));
  });

  testWidgets('tapping a day selects it and marks it selected', (tester) async {
    DateTime? picked;
    await _pump(tester, classes: const [], onSelectDate: (d) => picked = d);

    await tester.tap(find.text('9/25'));
    expect(picked, DateTime(2026, 9, 25));

    await _pump(tester, classes: const [], selected: DateTime(2026, 9, 25));
    expect(
      tester.getSemantics(find.text('9/25')),
      containsSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('9/24')),
      containsSemantics(isSelected: false),
    );
  });
}

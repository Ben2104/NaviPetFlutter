import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navipet/data/course_class.dart';
import 'package:navipet/widgets/class_detail_sheet.dart';

const _course = CourseClass(
  id: '1',
  courseCode: 'CECS 491A',
  courseName: 'Senior Project',
  building: 'Vivian Engineering Center',
  room: '308',
  weekdays: [1, 3],
  startTime: '10:00',
  endTime: '11:15',
  latitude: 33.78,
  longitude: -118.11,
);

void main() {
  testWidgets('shows the location and schedule the calendar leaves out', (
    tester,
  ) async {
    var edited = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClassDetailSheet(
            course: _course,
            completions: 1,
            onEdit: () => edited = true,
          ),
        ),
      ),
    );

    expect(find.text('CECS 491A'), findsOneWidget);
    expect(find.text('Senior Project'), findsOneWidget);
    expect(find.text('Mon, Wed · 10:00–11:15 AM'), findsOneWidget);
    expect(find.text('Vivian Engineering Center 308'), findsOneWidget);
    expect(find.text('1 task completed · 1/5'), findsOneWidget);

    await tester.tap(find.text('Edit class'));
    expect(edited, isTrue);
  });
}

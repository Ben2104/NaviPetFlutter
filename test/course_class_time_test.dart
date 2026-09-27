import 'package:flutter_test/flutter_test.dart';
import 'package:navipet/data/course_class.dart';

CourseClass _course(String start, String end) => CourseClass(
  id: '1',
  courseCode: 'CECS 491',
  courseName: 'Senior Project',
  building: 'VEC',
  room: '',
  weekdays: const [1],
  startTime: start,
  endTime: end,
  latitude: 33.78,
  longitude: -118.11,
);

void main() {
  test('clock times are shown in 12-hour form without seconds', () {
    expect(formatClockTime('10:00:00'), '10:00 AM');
    expect(formatClockTime('00:15'), '12:15 AM');
    expect(formatClockTime('12:00'), '12:00 PM');
    expect(formatClockTime('19:30'), '7:30 PM');
    expect(formatClockTime('19:30', period: false), '7:30');
  });

  test('a class time range shares the period when it does not cross noon', () {
    expect(_course('10:00:00', '11:15:00').timeRangeLabel, '10:00–11:15 AM');
    expect(_course('11:30', '12:45').timeRangeLabel, '11:30 AM–12:45 PM');
    expect(_course('14:00', '15:15').startLabel, '2:00 PM');
  });
}

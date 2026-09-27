import 'package:flutter_test/flutter_test.dart';
import 'package:navipet/data/app_state.dart';
import 'package:navipet/data/course_class.dart';

const _inPerson = CourseClass(
  id: 'class-1',
  courseCode: 'CECS 491A',
  courseName: 'Senior Project',
  building: 'Vivian Engineering Center',
  room: '308',
  weekdays: [1, 2, 3, 4, 5, 6, 7],
  startTime: '10:00:00',
  endTime: '11:15:00',
  latitude: 33.78,
  longitude: -118.11,
);

const _online = CourseClass(
  id: 'class-2',
  courseCode: 'CECS 453',
  courseName: 'Mobile Apps',
  building: '',
  room: '',
  weekdays: [1, 2, 3, 4, 5, 6, 7],
  startTime: '10:00:00',
  endTime: '11:15:00',
  latitude: 33.78,
  longitude: -118.11,
  isOnline: true,
);

DailyClassTask _task(CourseClass course, String kind) => DailyClassTask(
  course: course,
  kind: kind,
  label: kind,
  reward: 10,
  done: false,
);

void main() {
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  test('attendance for another day cannot be claimed', () async {
    final state = AppState();

    expect(
      await state.verifyAndToggleTask(_task(_inPerson, 'attend'), yesterday),
      TaskClaimResult.notToday,
    );
    expect(
      await state.verifyAndToggleTask(
        _task(_online, 'attend_online'),
        tomorrow,
      ),
      TaskClaimResult.notToday,
    );
    expect(
      await state.verifyAndToggleTask(_task(_inPerson, 'prepare'), tomorrow),
      TaskClaimResult.notToday,
    );
  });

  test('an online class needs a long enough session today', () async {
    final state = AppState();

    expect(
      await state.verifyAndToggleTask(_task(_online, 'attend_online'), today),
      TaskClaimResult.sessionTooShort,
    );

    state.startOnlineSession(_online.id);
    expect(
      await state.verifyAndToggleTask(_task(_online, 'attend_online'), today),
      TaskClaimResult.sessionTooShort,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navipet/data/app_state.dart';
import 'package:navipet/data/course_class.dart';
import 'package:navipet/screens/checklist_screen.dart';
import 'package:navipet/widgets/schedule_calendar.dart';
import 'package:provider/provider.dart';

final _everyDay = [1, 2, 3, 4, 5, 6, 7];

final _classes = [
  CourseClass(
    id: '1',
    courseCode: 'CECS 491A',
    courseName: 'Senior Project',
    building: 'Vivian Engineering Center',
    room: '308',
    weekdays: _everyDay,
    startTime: '10:00',
    endTime: '11:15',
    latitude: 33.78,
    longitude: -118.11,
  ),
  CourseClass(
    id: '2',
    courseCode: 'CECS 453',
    courseName: 'Mobile Apps',
    building: '',
    room: '',
    weekdays: _everyDay,
    startTime: '13:00',
    endTime: '14:15',
    latitude: 33.78,
    longitude: -118.11,
    isOnline: true,
  ),
];

class _FakeAppState extends AppState {
  @override
  List<CourseClass> get classes => _classes;

  @override
  int completionCountFor(String classId) => classId == '1' ? 1 : 3;

  @override
  Future<void> refreshClasses() async {}
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<AppState>(
      create: (_) => _FakeAppState(),
      child: const MaterialApp(home: ChecklistScreen()),
    ),
  );
  await tester.pump();
}

/// Scrolls the page itself; a drag in the middle would land on the calendar
/// grid, which scrolls on its own.
Future<void> _scrollPageToEnd(WidgetTester tester) async {
  final page = tester.state<ScrollableState>(find.byType(Scrollable).first);
  page.position.jumpTo(page.position.maxScrollExtent);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the screen is the Calendar, with Week selected', (tester) async {
    await _pump(tester);
    expect(find.widgetWithText(AppBar, 'Calendar'), findsOneWidget);
    final views = tester.widget<SegmentedButton<CalendarView>>(
      find.byType(SegmentedButton<CalendarView>),
    );
    expect(views.selected, {CalendarView.week});
  });

  testWidgets('Add class never covers the calendar', (tester) async {
    await _pump(tester);
    final add = tester.getRect(find.widgetWithText(FilledButton, 'Add class'));
    final body = tester.getRect(find.byType(ListView));
    expect(add.top, greaterThanOrEqualTo(body.bottom));
  });

  testWidgets('switching to Agenda lists the classes', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Today · '), findsOneWidget);
    expect(find.text('10:00–11:15 AM'), findsWidgets);
  });

  testWidgets('achievement cards count tasks with the right plural', (
    tester,
  ) async {
    await _pump(tester);
    await _scrollPageToEnd(tester);
    expect(find.text('1 task completed'), findsOneWidget);
    expect(find.text('3 tasks completed'), findsOneWidget);
  });

  testWidgets('tapping an achievement opens the class details', (tester) async {
    await _pump(tester);
    await _scrollPageToEnd(tester);
    await tester.tap(find.text('1 task completed'));
    await tester.pumpAndSettle();
    expect(find.text('Vivian Engineering Center 308'), findsOneWidget);
    expect(find.text('Edit class'), findsOneWidget);
  });
}

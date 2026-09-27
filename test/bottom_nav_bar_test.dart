import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navipet/theme/app_theme.dart';
import 'package:navipet/widgets/bottom_nav_bar.dart';

Future<void> _pump(WidgetTester tester, NaviTab active) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(bottomNavigationBar: NaviBottomNav(active: active)),
  ),
);

BoxDecoration _ring(WidgetTester tester, String label) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byKey(ValueKey('nav-$label')),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('every destination is labelled', (tester) async {
    await _pump(tester, NaviTab.menu);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Pet'), findsOneWidget);
    expect(find.text('Locations'), findsOneWidget);
  });

  testWidgets('each active tab gets the same navy ring', (tester) async {
    for (final (tab, label) in [
      (NaviTab.menu, 'Calendar'),
      (NaviTab.pets, 'Pet'),
      (NaviTab.location, 'Locations'),
    ]) {
      await _pump(tester, tab);
      final border = _ring(tester, label).border! as Border;
      expect(border.top.color, AppColors.navy, reason: label);
      expect(
        tester.getSemantics(find.byKey(ValueKey('nav-$label'))),
        isSemantics(isSelected: true, isButton: true, label: label),
      );
    }
  });

  testWidgets('inactive tabs have no ring', (tester) async {
    await _pump(tester, NaviTab.menu);
    expect(_ring(tester, 'Pet').border, isNull);
    expect(_ring(tester, 'Locations').border, isNull);
  });
}

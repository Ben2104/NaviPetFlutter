import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navipet/widgets/profile_avatar.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows the initial when there is no avatar URL', (tester) async {
    await tester.pumpWidget(
      _host(const ProfileAvatar(name: 'jane', color: Colors.blue, size: 40)),
    );

    expect(find.text('J'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('falls back to the initial and reports a broken URL', (
    tester,
  ) async {
    final failed = <String>[];
    const url = 'https://cdn.test/avatar.webp?token=expired';

    // flutter_test answers every HTTP request with a 400, so the image fails.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        _host(
          ProfileAvatar(
            name: 'jane',
            color: Colors.blue,
            size: 40,
            imageUrl: url,
            onImageError: failed.add,
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.text('J'), findsOneWidget);
    expect(failed, contains(url));
  });
}

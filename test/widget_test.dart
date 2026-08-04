import 'package:flutter_test/flutter_test.dart';

import 'package:navipet/data/app_state.dart';
import 'package:navipet/data/navigation_models.dart';

void main() {
  group('AppState without backend configuration', () {
    test('starts signed out and reports missing Supabase configuration', () {
      final state = AppState();
      addTearDown(state.dispose);

      expect(state.isSupabaseConfigured, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.activeUser, isNull);
    });

    test('returns a useful failure instead of pretending to sign in', () async {
      final state = AppState();
      addTearDown(state.dispose);

      final result = await state.signIn(
        email: 'person@example.com',
        password: 'password',
      );

      expect(result.status, AuthActionStatus.failure);
      expect(result.message, contains('Supabase is not configured'));
    });
  });

  group('NavigationRoute labels', () {
    test('formats a short walking route', () {
      const route = NavigationRoute(
        coordinates: [],
        steps: [],
        distanceMeters: 30,
        durationSeconds: 301,
      );

      expect(route.distanceLabel, '98 ft');
      expect(route.durationLabel, '6 min');
    });

    test('formats a longer route', () {
      const route = NavigationRoute(
        coordinates: [],
        steps: [],
        distanceMeters: 3218.688,
        durationSeconds: 3900,
      );

      expect(route.distanceLabel, '2.0 mi');
      expect(route.durationLabel, '1 hr 5 min');
    });
  });
}

// Unit tests for NaviPet app state.
//
// These cover the sign-in logic ported from the RN AppState. Widget/integration
// tests that exercise the Mapbox map are intentionally omitted for now (the
// native map requires platform channels not available in the test harness).

import 'package:flutter_test/flutter_test.dart';

import 'package:navipet/data/app_state.dart';
import 'package:navipet/data/mock_data.dart';

void main() {
  group('AppState.signIn', () {
    test('defaults to the first user', () {
      final state = AppState();
      expect(state.activeUser.id, users.first.id);
    });

    test('matches a known user by email (case-insensitive)', () {
      final state = AppState();
      state.signIn('MAYA@csulb.edu');
      expect(state.activeUser.email, 'maya@csulb.edu');
    });

    test('falls back to the first user for an unknown email', () {
      final state = AppState();
      state.signIn('nobody@example.com');
      expect(state.activeUser.id, users.first.id);
    });

    test('guest email selects the Guest Explorer account', () {
      final state = AppState();
      state.signIn('guest@navipet.app');
      expect(state.activeUser.name, 'Guest Explorer');
    });
  });
}

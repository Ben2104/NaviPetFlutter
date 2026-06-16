import 'package:flutter/foundation.dart';

import 'mock_data.dart';

/// Global, in-memory app state. The Flutter analog of the RN `AppStateProvider`
/// React context (`data/AppState.tsx`). Exposed app-wide via `provider`.
///
/// For the current SignIn + Map scope this only tracks the active user; the
/// gems / outfits / messages state from the RN app will be added back as those
/// screens are ported.
class AppState extends ChangeNotifier {
  String _activeAccountId = users.first.id;

  /// The signed-in user, matched against the [users] fixture. Falls back to the
  /// first user, mirroring the RN behaviour.
  UserAccount get activeUser =>
      users.firstWhere((u) => u.id == _activeAccountId, orElse: () => users.first);

  /// Look up a user by email and make them active. Unrecognised emails fall
  /// back to the first user — same rule as the RN `signIn`.
  void signIn(String? email) {
    final normalized = email?.trim().toLowerCase();
    final match = users.firstWhere(
      (u) => u.email.toLowerCase() == normalized,
      orElse: () => users.first,
    );
    _activeAccountId = match.id;
    notifyListeners();
  }
}

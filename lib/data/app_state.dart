import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'user_account.dart';

/// App-wide authentication and profile state backed by Supabase.
class AppState extends ChangeNotifier {
  AppState({SupabaseClient? supabase}) : this._(supabase);

  AppState._(this._supabase) {
    if (_supabase == null) return;

    _applyUser(_supabase.auth.currentUser);
    _authSubscription = _supabase.auth.onAuthStateChange.listen((event) {
      _applyUser(event.session?.user);
    });
  }

  final SupabaseClient? _supabase;
  StreamSubscription<AuthState>? _authSubscription;

  UserAccount? _activeUser;
  bool _busy = false;
  String? _errorMessage;

  bool get isSupabaseConfigured => _supabase != null;
  bool get isAuthenticated => _supabase?.auth.currentSession != null;
  bool get isBusy => _busy;
  String? get errorMessage => _errorMessage;
  UserAccount? get activeUser => _activeUser;

  Future<AuthActionResult> signIn({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      final client = _requireClient();
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      await _applyUser(response.user);
      return const AuthActionResult.authenticated();
    });
  }

  Future<AuthActionResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      final client = _requireClient();
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'display_name': name.trim()},
      );
      await _applyUser(response.user);
      if (response.session == null) {
        return const AuthActionResult.emailConfirmationRequired();
      }
      return const AuthActionResult.authenticated();
    });
  }

  Future<AuthActionResult> continueAsGuest() async {
    return _runAuthAction(() async {
      final response = await _requireClient().auth.signInAnonymously(
        data: {'display_name': 'Guest Explorer'},
      );
      await _applyUser(response.user);
      return const AuthActionResult.authenticated();
    });
  }

  Future<AuthActionResult> sendPasswordReset(String email) async {
    return _runAuthAction(() async {
      await _requireClient().auth.resetPasswordForEmail(email.trim());
      return const AuthActionResult.passwordResetSent();
    });
  }

  Future<void> signOut() async {
    _setBusy(true);
    try {
      await _requireClient().auth.signOut();
      _activeUser = null;
      _errorMessage = null;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthActionResult> _runAuthAction(
    Future<AuthActionResult> Function() action,
  ) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      return await action();
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return AuthActionResult.failure(error.message);
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
      return AuthActionResult.failure(error.message);
    } catch (error) {
      _errorMessage = error.toString();
      return AuthActionResult.failure(
        isSupabaseConfigured
            ? 'Something went wrong. Please try again.'
            : 'Supabase is not configured yet. Add its URL and publishable key to .env.',
      );
    } finally {
      _setBusy(false);
    }
  }

  SupabaseClient _requireClient() {
    final client = _supabase;
    if (client == null) {
      throw StateError(
        'Supabase is not configured. Add SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY to .env.',
      );
    }
    return client;
  }

  Future<void> _applyUser(User? user) async {
    if (user == null) {
      _activeUser = null;
      notifyListeners();
      return;
    }

    Map<String, dynamic>? profile;
    try {
      profile = await _supabase
          ?.from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
    } on PostgrestException {
      // Authentication still works before the optional profiles schema has
      // been installed. User metadata supplies a useful fallback.
    }

    _activeUser = UserAccount.fromSupabase(user, profile: profile);
    notifyListeners();
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

enum AuthActionStatus {
  authenticated,
  emailConfirmationRequired,
  passwordResetSent,
  failure,
}

class AuthActionResult {
  const AuthActionResult._(this.status, [this.message]);

  const AuthActionResult.authenticated()
    : this._(AuthActionStatus.authenticated);

  const AuthActionResult.emailConfirmationRequired()
    : this._(AuthActionStatus.emailConfirmationRequired);

  const AuthActionResult.passwordResetSent()
    : this._(AuthActionStatus.passwordResetSent);

  const AuthActionResult.failure(String message)
    : this._(AuthActionStatus.failure, message);

  final AuthActionStatus status;
  final String? message;
}

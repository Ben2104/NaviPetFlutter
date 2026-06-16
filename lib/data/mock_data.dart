import 'package:flutter/material.dart';

/// A signed-in user. Ported from `UserAccount` in the RN `data/mockData.ts`.
/// Only the fields needed for the SignIn + Map flow are carried over for now.
class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarColor,
    required this.gems,
    required this.level,
  });

  final String id;
  final String name;
  final String email;
  final Color avatarColor;
  final int gems;
  final int level;
}

/// Static fixture data mirroring `users` in the RN app. There is no backend —
/// sign-in matches against this list (see `AppState.signIn`).
const List<UserAccount> users = [
  UserAccount(
    id: 'u1',
    name: 'Alex Rivera',
    email: 'alex@csulb.edu',
    avatarColor: Color(0xFFFFB000),
    gems: 680,
    level: 12,
  ),
  UserAccount(
    id: 'u2',
    name: 'Maya Chen',
    email: 'maya@csulb.edu',
    avatarColor: Color(0xFF0EA5A4),
    gems: 340,
    level: 8,
  ),
  UserAccount(
    id: 'u3',
    name: 'Guest Explorer',
    email: 'guest@navipet.app',
    avatarColor: Color(0xFF2F80ED),
    gems: 120,
    level: 2,
  ),
];

import 'package:go_router/go_router.dart';

import '../screens/account_settings_screen.dart';
import '../screens/ar_navigation_screen.dart';
import '../screens/checklist_screen.dart';
import '../screens/map_screen.dart';
import '../screens/pet_customization_screen.dart';
import '../screens/search_screen.dart';
import '../screens/sign_in_screen.dart';

/// App navigation, the Flutter analog of the RN `RootNavigator`.
///
/// Sign-in uses `context.go('/map')` which replaces the stack. The shared
/// bottom-nav tabs (Map / Pet / Checklist) switch with `context.go`, while
/// overlay-style screens (Search, AR, Account) are opened with `context.push`
/// so their back arrow / X pops back to the caller — matching the Figma
/// prototype's user flow.
final GoRouter appRouter = GoRouter(
  initialLocation: '/signin',
  routes: [
    GoRoute(
      path: '/signin',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/pet',
      builder: (context, state) => const PetCustomizationScreen(),
    ),
    GoRoute(
      path: '/checklist',
      builder: (context, state) => const ChecklistScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => const AccountSettingsScreen(),
    ),
    GoRoute(
      path: '/ar',
      builder: (context, state) => const ArNavigationScreen(),
    ),
  ],
);

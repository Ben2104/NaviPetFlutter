# NaviPet Flutter

NaviPet is a campus companion for CSU Long Beach. The current functional slice
includes:

- Supabase email/password authentication, account creation, password reset,
  anonymous guest sessions, persisted sessions, and profile data.
- A native Mapbox map with live device location.
- Mapbox destination autocomplete and walking directions.
- A route line, destination marker, ETA/distance preview, maneuver guidance,
  spoken instructions, arrival detection, and basic off-route recalculation.
- Existing Pet, Checklist, Account, and prototype AR screens. The 3D/Multiset
  integration is intentionally deferred and is not exposed from the map.

## Project structure

```text
lib/
  main.dart                         App initialization
  data/
    app_config.dart                 Safe runtime configuration checks
    app_state.dart                  Supabase auth/session/profile state
    user_account.dart               Authenticated profile model
    mapbox_config.dart              Mapbox token and campus defaults
    mapbox_navigation_service.dart  Search Box + Directions API client
    navigation_models.dart          Destination, route, and maneuver models
  router/app_router.dart            Auth-aware go_router configuration
  screens/
    sign_in_screen.dart             Sign in, create, reset, and guest actions
    search_screen.dart              Live destination autocomplete
    map_screen.dart                 GPS, route preview, and guided navigation
supabase/schema.sql                 Profiles table, trigger, and RLS policies
```

## Prerequisites

- Flutter 3.44 or later
- Android Studio and Android SDK 36 for Android development
- Xcode and an iOS runtime for iOS development
- A Mapbox account
- A Supabase project

Run `flutter doctor` and resolve its required items before continuing.

## Environment configuration

Copy `.env.example` to `.env`. The `.env` file is git-ignored.

```properties
MAPBOX_PUBLIC_TOKEN=pk.your_public_token
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_your_key
```

Use only Supabase's publishable/anon client key. Never place a Supabase
`service_role` or secret key in the app.

### Mapbox Android download token

Android builds also require a secret Mapbox token with `DOWNLOADS:READ`. Put it
in your user-level Gradle file, not in this repository:

```text
C:\Users\YOUR_NAME\.gradle\gradle.properties
```

```properties
MAPBOX_DOWNLOADS_TOKEN=sk.your_download_token
```

## Supabase setup

1. Create a Supabase project.
2. Open **SQL Editor**, paste [supabase/schema.sql](supabase/schema.sql), and run
   it once. This creates the `profiles` table, a new-user trigger, and Row Level
   Security policies.
3. In **Authentication > Providers**, keep Email enabled.
4. Enable anonymous sign-ins if **Continue as Guest** should work.
5. Decide whether new users must confirm their email. NaviPet handles both
   configurations: with confirmation enabled it asks users to check their email;
   without it they enter the app immediately.
6. Copy the Project URL and publishable key from Supabase's **Connect** panel into
   `.env`.

Supabase Auth owns passwords and sessions. The public `profiles` table stores
only NaviPet data such as display name, gems, level, and avatar color.

## Run on an Android phone

1. Enable Developer options and USB debugging on the phone.
2. Connect it with a data-capable USB cable and approve the debugging prompt.
3. From the project root, run:

```powershell
flutter pub get
flutter devices
flutter run
```

The first build can take several minutes. The app will request location access
when the map opens; precise location is needed for route guidance and rerouting.

## Navigation behavior

The app stays on Mapbox for this phase. It uses the native Maps Flutter SDK for
rendering and location, the Search Box API for destinations, and the Directions
API's walking profile for route geometry and maneuver instructions.

This is a functional foreground walking-navigation experience. Before treating
it as safety-critical or shipping it broadly, add integration/device tests for
GPS loss, background execution, route deviations, network loss, accessibility,
and battery use. Do not rely on it for emergency navigation.

Mapbox search results are treated as temporary session data and are not stored
in Supabase.

## Verification

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

The debug APK is written to:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| Supabase setup notice on sign-in | Add `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` to `.env`, then fully restart the app. |
| Guest sign-in fails | Enable anonymous sign-ins in Supabase Authentication settings. |
| New account cannot sign in immediately | Check the inbox and confirm the account, or disable Confirm email in Supabase for development. |
| Map is blank or destination search fails | Verify `MAPBOX_PUBLIC_TOKEN` is a valid `pk.*` token. |
| Android Mapbox dependency returns 401 | Verify the global `MAPBOX_DOWNLOADS_TOKEN` starts with `sk.` and has `DOWNLOADS:READ`. |
| Current location is unavailable | Enable precise location for NaviPet and turn on the phone's Location Services. |
| Route is not found | Walking directions require a Mapbox-routable origin and destination; try a nearby street entrance. |
| `cmdline-tools` is missing | Install Android SDK Command-line Tools in Android Studio, then run `flutter doctor --android-licenses`. |

The Kotlin Gradle Plugin warning currently emitted by Mapbox/Flutter TTS is a
forward-compatibility warning from those plugins; the Android build succeeds on
the pinned Flutter/Mapbox versions in this repository.

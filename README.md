# NaviPet (Flutter)

A Flutter port of the NaviPet campus-companion app, using the **native Mapbox
Maps Flutter SDK** (`mapbox_maps_flutter`) instead of the WebView-based Mapbox GL
JS map the original React Native app used.

This is an incremental port. The current scope is the first flow only:

> **Sign In → Map** — sign in (or continue as guest) and land on a native Mapbox
> map centered on the CSU Long Beach campus, with a "You" marker, a floating
> search bar, and a 2D/3D toggle.

The remaining screens (Pet, Search, Store, Friends, Chat, Settings, Achievements,
etc.) from the RN app are not ported yet.

---

## Project structure

```
lib/
  main.dart                  App entry: loads .env, sets the Mapbox token, mounts providers + router
  router/app_router.dart     go_router routes (/signin, /map) — analog of the RN RootNavigator
  data/
    app_state.dart           AppState (ChangeNotifier) — analog of the RN AppState context
    mock_data.dart           UserAccount model + `users` fixture
    mapbox_config.dart       Public token (from .env), style, CSULB coords + zoom
  screens/
    sign_in_screen.dart      Sign-in UI (ported from SignInScreen.tsx)
    map_screen.dart          Native Mapbox map (ported from MapScreen.tsx + MapboxMap.tsx)
  theme/app_theme.dart       Design tokens (colors/spacing/radius/shadows) from theme/index.ts
  widgets/search_bar_field.dart  Pill search bar (ported from SearchBar.tsx)
assets/mascot.png            App mascot shown on the sign-in screen
.env.example                 Template for the public Mapbox token
```

State uses [`provider`](https://pub.dev/packages/provider), navigation uses
[`go_router`](https://pub.dev/packages/go_router), and env loading uses
[`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv).

---

## Prerequisites

| Tool | Notes |
|---|---|
| **Flutter SDK** (3.44+) | `brew install --cask flutter`, then `flutter doctor` |
| **Xcode** (for iOS) | Install from the App Store; run `xcodebuild -runFirstLaunch` once |
| **iOS Simulator** | Bundled with Xcode |
| **Android Studio + SDK** (for Android) | Provides the emulator and the **cmdline-tools** component |
| **A Mapbox account** | Free at <https://account.mapbox.com> — you'll create tokens below |

Run `flutter doctor` and resolve anything it flags before continuing.

---

## Mapbox setup (read this carefully)

The native Mapbox SDK uses **two different tokens**. Don't mix them up.

### 1. Public token (`pk.*`) — required on every platform

Used at **runtime** to display the map.

1. Go to <https://account.mapbox.com/access-tokens/> and copy your **default
   public token** (starts with `pk.`).
2. Copy the env template and paste your token in:
   ```bash
   cp .env.example .env
   # then edit .env:
   # MAPBOX_PUBLIC_TOKEN=pk.your_token_here
   ```
   `.env` is git-ignored. It's loaded in `lib/main.dart` and handed to the SDK via
   `MapboxOptions.setAccessToken(...)`.

> A working public token is already filled into `.env` on this machine, so the map
> works out of the box locally. Anyone cloning the repo must create their own
> `.env` from `.env.example`.

### 2. Secret download token (`sk.*`) — **Android only**

Used at **build time** to download the Mapbox Android SDK from Mapbox's Maven
repository. **iOS does not need this** — this project resolves the iOS SDK via
Swift Package Manager, which uses the public packages.

1. At <https://account.mapbox.com/access-tokens/>, click **Create a token**.
2. Give it a name, and under **Secret scopes** check **`DOWNLOADS:READ`**.
3. Create it and copy the token (starts with `sk.`). **You only see it once.**
4. Add it to your **global** Gradle properties so it stays out of the repo:
   ```bash
   mkdir -p ~/.gradle
   echo 'MAPBOX_DOWNLOADS_TOKEN=sk.your_secret_token_here' >> ~/.gradle/gradle.properties
   ```
   The Maven repo in `android/build.gradle.kts` reads this property. Without it,
   Android builds fail with a `401 Unauthorized` while resolving the Mapbox
   dependency.

---

## Run on the iOS Simulator

```bash
# 1. Open a simulator
open -a Simulator

# 2. Get dependencies
flutter pub get

# 3. Run (Flutter auto-selects the booted simulator)
flutter run
```

If multiple devices are connected, list them and pick one:

```bash
flutter devices
flutter run -d <device-id>      # e.g. flutter run -d "iPhone 16 Pro"
```

Notes:
- iOS dependencies are managed by **Swift Package Manager** (there is no
  `Podfile`). The first build fetches the Mapbox Swift packages from GitHub and
  can take several minutes.
- The iOS deployment target is set to **14.0** (Mapbox's minimum).

> ⚠️ **Do not build iOS from an iCloud-synced folder (Desktop/Documents).**
> When "Desktop & Documents Folders" iCloud Drive sync is on, iCloud stamps a
> `com.apple.FinderInfo` extended attribute on build directories. `codesign`
> rejects this with *"resource fork, Finder information, or similar detritus not
> allowed"*, and the iOS build fails at the "copy Flutter framework" step.
> **Fix: keep/clone this project in a non-synced location** such as
> `~/Development/NaviPetFlutter`. (Android is unaffected.) See troubleshooting
> below.

---

## Run on the Android Emulator

```bash
# 1. Make sure the secret download token is configured (see Mapbox setup §2)

# 2. Launch an emulator (or start one from Android Studio > Device Manager)
flutter emulators                       # list available AVDs
flutter emulators --launch <avd-id>

# 3. Run
flutter pub get
flutter run -d android
```

The first Android build downloads the Mapbox Android SDK via Maven using your
`MAPBOX_DOWNLOADS_TOKEN`.

---

## Verify the build without a device

```bash
flutter analyze              # static analysis (like the RN `npm run typecheck`)
flutter test                 # unit tests (AppState sign-in logic)
flutter build ios --simulator --debug    # compile for iOS Simulator, no signing
```

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| **Android build: `401 Unauthorized` / can't resolve `com.mapbox.*`** | Missing/invalid secret download token. Add `MAPBOX_DOWNLOADS_TOKEN=sk...` (scope `DOWNLOADS:READ`) to `~/.gradle/gradle.properties`. |
| **Map is blank / grey** | Missing or invalid **public** token. Check `.env` has a valid `MAPBOX_PUBLIC_TOKEN=pk...`. |
| **`flutter doctor`: "cmdline-tools component is missing"** | Open Android Studio → Settings → Languages & Frameworks → Android SDK → SDK Tools → check **Android SDK Command-line Tools**, then `flutter doctor --android-licenses`. |
| **Gradle fails on Java version** | This machine has a very new JDK. Point Flutter at the JDK bundled with Android Studio: `flutter config --jdk-dir "/Applications/Android Studio.app/Contents/jbr/Contents/Home"`. |
| **iOS build: "resource fork, Finder information, or similar detritus not allowed" / "Failed to copy Flutter framework"** | The project is in an **iCloud-synced** folder (Desktop/Documents). iCloud adds a `com.apple.FinderInfo` xattr that `codesign` rejects. Move/clone the project to a non-synced path (e.g. `~/Development/NaviPetFlutter`), then `flutter clean && flutter run`. |
| **iOS SPM fetch is slow/stuck** | First run only; it clones Mapbox repos. Re-run `flutter run`; ensure you have network access to github.com. |
| **No simulators listed** | `open -a Simulator`, or in Xcode → Settings → Platforms install an iOS runtime. |

---

## Adding the next screens

1. Port the RN screen into `lib/screens/<name>_screen.dart` using the tokens in
   `lib/theme/app_theme.dart`.
2. Add a route in `lib/router/app_router.dart`.
3. Extend `lib/data/app_state.dart` / `lib/data/mock_data.dart` with any state and
   fixtures that screen needs (the RN `data/mockData.ts` is the reference).

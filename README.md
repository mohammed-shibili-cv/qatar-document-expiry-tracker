# Qatar Document Expiry Tracker

Offline-first Flutter utility for people in Qatar to track personal document expiries (QID, health card, residency, istimara, licence, passport, vehicle insurance) with **local** reminders.

> Scope: **v1 MVP only**. See [`docs/PRODUCT.md`](docs/PRODUCT.md) for v1 vs v1.5 vs v2.

## Requirements

- Flutter **stable** (`3.35+` recommended)
- For full local notifications + photo persistence: **Android** or **iOS** device/emulator
- This cloud environment has **Chrome (web)** available; Android SDK / Linux desktop toolchains are not installed by default

## Run

```bash
flutter pub get
flutter run
```

Useful targets:

```bash
flutter run -d chrome          # UI flows (notifications limited on web)
flutter analyze
flutter test
```

## Architecture (v1)

```
lib/
  main.dart                 # bootstrap Hive + notifications
  app_scope.dart            # InheritedWidget DI
  models/                   # TrackedDocument, templates, reminder settings
  data/                     # Hive repositories (AES-encrypted documents box)
  services/                 # local notifications, photo copy-to-app-dir
  screens/                  # onboarding, home, document form, settings
  widgets/                  # list tile + urgency chip
```

| Concern | Choice |
|---|---|
| Persistence | Hive (`documents` AES box + `settings` box) |
| Encryption key | `flutter_secure_storage` → `HiveAesCipher` |
| Reminders | `flutter_local_notifications` (no FCM) |
| Photos | `image_picker` → copy under app documents |
| UI | Material 3 |

### Sensitivity

- Document numbers are **never logged** (`TrackedDocument.toString` omits them).
- The documents Hive box is encrypted at rest when secure storage is available.
- Do **not** commit sample QID / passport numbers.

### Platform gaps (this VM)

| Target | Status |
|---|---|
| `flutter analyze` | Supported |
| Web (`chrome`) | Supported for UI/CRUD; scheduled local notifications are a no-op |
| Android APK | Needs Android SDK (not installed in this environment) |
| iOS | Needs macOS + Xcode |
| Linux desktop | Needs GTK/ninja packages |

On cold start the app re-schedules all local reminders so a reboot does not permanently drop them (Android boot receiver is also registered).

## Product docs

- [`docs/PRODUCT.md`](docs/PRODUCT.md) — v1 / v1.5 / v2 scope guardrails

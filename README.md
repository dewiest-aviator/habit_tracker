# 📱 Habit Tracker (Flutter)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![Build](https://github.com/dewiest-aviator/habit_tracker/actions/workflows/nightly_release.yml/badge.svg)](https://github.com/dewiest-aviator/habit_tracker/actions)
[![codecov](https://codecov.io/gh/dewiest-aviator/habit_tracker/graph/badge.svg)](https://codecov.io/gh/dewiest-aviator/habit_tracker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A simple cross-platform **habit tracking app** built with Flutter.  
Track up to 3 daily habits, get reminders, and keep streaks. 🚀

---

## ✨ Features
- Add up to **3 habits** (name, emoji/icon, color).
- **Daily check-in** with streak counter.
- **Local notifications** as reminders.
- **Light/Dark themes** out of the box.
- Works **offline** (all data stored locally).

---

## 🛠️ Tech Stack
- [Flutter](https://flutter.dev/) (Dart)
- [Riverpod](https://riverpod.dev/) for state management
- [Go Router](https://pub.dev/packages/go_router) for navigation
- [Isar](https://isar.dev/) or Hive for local storage
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) for reminders

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (stable)
- Android Studio or Xcode
- Device emulator or physical device

### Run locally
```bash
git clone git@github.com:dewiest-aviator/habit_tracker.git
cd habit_tracker
flutter pub get
flutter run
```
---

## 🔐 Release Signing Setup

### Local
1. Generate a keystore (only once):
   ```bash
   keytool -genkeypair -v -keystore /Users/youruser/keys/habittracker-release.jks -alias habit_release -keyalg RSA -keysize 2048 -validity 36500 -storetype JKS -dname "CN=Raijin Ryu, OU=Mobile, O=Raijin Ryu, L=Paris, S=Ile de France, C=FR"
   ```
2. Add properties to `~/.gradle/gradle.properties`:
   ```properties
   HABITTRACKER_RELEASE_STORE_FILE=/Users/youruser/keys/habittracker-release.jks
   HABITTRACKER_RELEASE_STORE_PASSWORD=your-store-password
   HABITTRACKER_RELEASE_KEY_ALIAS=habit_release
   HABITTRACKER_RELEASE_KEY_PASSWORD=your-key-password
   ```
3. Build release:
   ```bash
   flutter build appbundle --release
   ```

### CI (GitHub Actions)
Set these repository secrets:
- `ANDROID_RELEASE_KEYSTORE_B64` → base64 of your keystore
- `ANDROID_RELEASE_STORE_PASSWORD`
- `ANDROID_RELEASE_KEY_ALIAS`
- `ANDROID_RELEASE_KEY_PASSWORD`

The workflow decodes the keystore and applies signing automatically.
---

## Routing & Theme

This app uses **go_router** and a **ThemeExtension** for brand colors.

Router: `lib/app_router.dart` maps `/` → Home and `/settings` → Settings.

Theme: `lib/theme/app_theme.dart` defines `AppBrandColors` and Material 3 light/dark themes.

Usage:
```dart
final brand = Theme.of(context).extension<AppBrandColors>()!.brand;
```
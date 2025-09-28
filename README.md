# 📱 Habit Tracker (Flutter)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![Build](https://github.com/dewiest-aviator/habit_tracker/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/dewiest-aviator/habit_tracker/actions)
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
# MyCally

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter)
![Status](https://img.shields.io/badge/status-early%20development-orange)

MyCally is a **local-first personal-finance diary** for Flutter: log day-wise
purchases on a calendar and review where your money goes, all offline and on your
device. No accounts, no cloud, no ads. Bilingual (English / हिन्दी).

> **🚧 Early development.** Core expense capture, calendar wiring, and analysis/reports
> charts are in place; polish and data portability are next. See the roadmap below.

## Features

- 📅 Calendar-based daily expense diary with real persisted entries
- ➕ Add expenses (amount, category/payee, note, optional receipt photo)
- 📊 Analysis charts — category breakdown, daily spend, month-over-month
- 📋 Reports — date-range summary, category totals, largest expenses
- 🌐 Localized UI — English & Hindi (`easy_localization`)
- 🎨 Light/dark themes and adjustable font size, persisted across launches
- 💾 Local-first storage with [Isar](https://isar.dev) — works fully offline
- 📱 Built with Flutter (Android primary; iOS / web / desktop scaffolds present)

## Stack

Flutter (Dart ≥ 3.6) · `provider` (state) · `isar` (local DB) ·
`easy_localization` · `table_calendar` · `shared_preferences` · `intl`

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generate Isar code
flutter run
```

## Test locally

```bash
flutter analyze
flutter test test/src/app/main_test.dart test/src/data/repositories/expense_repository_test.dart
flutter test integration_test   # requires Android emulator/device
```

## Roadmap

1. ~~**Core diary**~~ — expense model + capture flow; calendar wired to real data.
2. ~~**Insights**~~ — analysis & report charts from recorded expenses.
3. **Daily utility** — categories, recurring entries, budgets and reminders.
4. **Data portability** — CSV/PDF export, encrypted backup & restore.

A detailed development brief lives in [`docs/OSS_PLAN.md`](docs/OSS_PLAN.md).

## Contributing

Issues and pull requests are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md)
before opening a pull request.

## License

[MIT](LICENSE)

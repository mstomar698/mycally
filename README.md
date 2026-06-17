# MyCally

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter)
![Status](https://img.shields.io/badge/status-early%20development-orange)

MyCally is a **local-first personal-finance diary** for Flutter: log day-wise
purchases on a calendar and review where your money goes, all offline and on your
device. No accounts, no cloud, no ads. Bilingual (English / हिन्दी).

> **🚧 Early development.** The app shell, calendar, settings, theme/language
> preferences, and local (Isar) storage are in place, but the core
> expense-recording flow and the analysis/report charts are still being built.
> See the roadmap below.

## Features

- 📅 Calendar-based daily expense diary
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

## Roadmap

1. **Core diary** — expense model + capture flow; wire the calendar to real data.
2. **Insights** — analysis & report charts from recorded expenses.
3. **Daily utility** — categories, recurring entries, budgets and reminders.
4. **Data portability** — CSV/PDF export, encrypted backup & restore.

A detailed development brief lives in [`docs/OSS_PLAN.md`](docs/OSS_PLAN.md).

## Contributing

Issues and pull requests are welcome. This is an early-stage project — the
roadmap above is the best place to start.

## License

[MIT](LICENSE)

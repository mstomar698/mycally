# Contributing to MyCally

Thanks for contributing.

## Local setup

1. Install Flutter stable.
2. Run:
   - `flutter pub get`
   - `dart run build_runner build --delete-conflicting-outputs`
   - `flutter analyze`
   - `flutter test`

## Pull requests

- Keep PRs focused and small.
- Add or update tests for behavioral changes.
- Do not commit APKs or other generated binaries.
- Ensure CI is green before requesting review.

## Commit style

Prefer concise messages with intent first, for example:
- `feat: add expense day summary`
- `fix: handle empty category in add expense sheet`

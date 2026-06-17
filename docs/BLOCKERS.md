# MyCally — Active Blockers & Environment Gotchas

> Last updated: 2026-06-17. Read this before picking up CI, testing, or release work.

---

## 1. CI — `flutter analyze` must be zero issues

**Status:** Fixed in `fix/ci-blockers-and-docs` (replaced `withOpacity` → `withValues`, removed `print` in `edit_vendor_screen`).

**Symptom:** GitHub Actions `CI` job fails at the Analyze step with exit code 1 even when only `info`-level lints are reported (`deprecated_member_use`, `avoid_print`).

**Fix applied:** Code cleanup across `lib/` + keep `flutter analyze` strict in `.github/workflows/ci.yml`.

**If it regresses:** Run `flutter analyze` locally before push; do not add `// ignore` without fixing root cause.

---

## 2. E2E integration tests — Android emulator required

**Status:** Fixed signing + compileSdk for CI (PR pending). Workflow: `.github/workflows/e2e-android.yml`.

**Previous failure (2026-06-17):** `assembleDebug` failed on CI with:
- `SigningConfig "debug" is missing required property "storeFile"` — custom debug signing in
  `android/app/build.gradle` required local `key.properties` not present on GitHub Actions.
- `integration_test` plugin requires `compileSdk 36`; project was on 34.
- `package_info_plus` 4.x fails Kotlin compile against SDK 36 — upgrade to ^8.3.

**Fix:** Only apply custom `signingConfigs` when `key.properties` exists; bump `compileSdk` to 36; upgrade `package_info_plus` to ^8.3 for Kotlin/SDK 36 compatibility.

**To run locally:**
1. Install Android SDK + emulator (Android Studio).
2. Start an emulator: `flutter emulators --launch <id>`
3. Run: `flutter test integration_test/app_flow_test.dart -d <deviceId>`

**Current test:** `integration_test/app_flow_test.dart` — awaits async `main()`, smoke launch + splash/MaterialApp visibility. Expand once emulator path is stable.

---

## 3. Isar repository tests on Windows host

**Status:** Open (by design).

**Symptom:** Tests that call `Isar.open()` fail on Windows VM/CI-less host with:
`Failed to load dynamic library 'isar.dll'`.

**Mitigation:** `test/src/data/repositories/expense_repository_test.dart` only tests pure `dayOnly()` logic — no Isar I/O. Full CRUD tests belong in:
- Android emulator integration tests, or
- Linux CI job with native libs available.

**Future:** Add `test/isar/` helper that skips when `Isar.initializeIsar` unavailable, or run Isar tests only in e2e workflow.

---

## 4. APK binaries in git history

**Status:** Open — tree is clean; history is not.

**Done:** `releases/*.apk` removed from current tree; `.gitignore` blocks `releases/`, `*.apk`, `*.aab` (PR #3 / `522233d`).

**Still needed:** Purge ~135 MB of APKs from **git history** before going public:
```bash
git filter-repo --path releases/ --invert-paths
# coordinate force-push to origin; repo is private + solo owner
```

**Owner action required:** Approve history rewrite + `git push --force` to `main`/`dev`.

---

## 5. Windows Developer Mode (local Flutter plugins)

**Status:** Open on some Windows dev machines.

**Symptom:** `flutter pub get` warns: *Building with plugins requires symlink support. Please enable Developer Mode.*

**Fix:** Settings → System → For developers → Developer Mode ON.  
Cannot be enabled via registry without elevated admin on locked-down hosts.

**Workaround used in container:** `flutter config --no-enable-windows-desktop` (desktop targets disabled; mobile/web unaffected).

---

## 6. Legacy test stubs (empty `main`)

**Status:** Resolved in repo tree.

**Symptom:** Running bare `flutter test` used to fail on placeholder test files with no `main()`.

**Current:** CI runs explicit stable subset:
```bash
flutter test test/src/app/main_test.dart test/src/data/repositories/expense_repository_test.dart
```

**Future:** Either delete empty stubs under `test/` or implement real tests before widening CI to `flutter test` (full tree).

---

## 7. Public / portfolio gate

**Status:** Phase 2 complete — decision pending.

Per `docs/OSS_PLAN.md`:
- Analysis + Reports are implemented (`fl_chart`, aggregates).
- Repo can move toward public flip after: CI green, e2e green, APK history purge, screenshots in README.

**Not blockers but next:** Phase 3 polish (category UX rename, budgets, recurring), Phase 4 export/backup.

---

## Quick pickup checklist

```bash
git checkout dev && git pull
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test test/src/app/main_test.dart test/src/data/repositories/expense_repository_test.dart
```

For e2e (device required):
```bash
flutter test integration_test/app_flow_test.dart -d <deviceId>
```

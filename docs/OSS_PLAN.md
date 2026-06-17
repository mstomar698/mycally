# MyCally — OSS Revive Plan

> **Purpose of this doc:** a self-contained brief so a *fresh* Claude session can
> pick up MyCally and take it from "half-built local app" to a clean, completed,
> open-source-ready Flutter project. Written 2026-06-17. Keep MyCally **local /
> private for now** — it is **not** in the portfolio projects section yet. Decide
> public + portfolio inclusion after blockers in [`BLOCKERS.md`](BLOCKERS.md) are cleared.

---

## 1. What MyCally is (intended)

A **local-first personal-finance diary**: record day-wise purchases/expenses on a
calendar, then see them as clear graphs and tables. Flutter, offline, no backend.
Bilingual (English / Hindi). Sibling in spirit to `jijivisha` (offline-first,
Hindi, Isar/local storage) — but a much smaller, single-purpose utility.

- **Platforms:** Android primary; iOS/web/macOS/Linux/Windows scaffolds present.
- **Stack:** Flutter (Dart SDK ^3.6), `provider` state, `isar` local DB,
  `easy_localization` (EN/HI), `table_calendar`, `fl_chart`, `shared_preferences`,
  `image_picker`, `intl`. Note the `isar_flutter_libs` pin to a community fork to
  fix the Gradle 8.x namespace issue.
- **Repo:** `github.com/mstomar698/mycally` — **private**, owner `mstomar698`.
  Active branches: `dev` (integration), `main` (release line). PRs merged via GitHub.

## 2. Honest status snapshot (verified 2026-06-17, post Phase 2)

**Implemented & working:**
- App shell, routing, splash, login, profile + edit-profile, settings,
  language-selector, theme/font/language preferences (persisted).
- **Vendors** CRUD (Isar) — repurposed as categories/payees (`vendors_screen`, `edit_vendor`).
- **Home** calendar wired to real **Expense** data — add-expense sheet, day list,
  month total, calendar markers.
- **Expense** model + `ExpenseRepository` — CRUD, by-day/month/range, analytics aggregates.
- **Analysis** screen — category pie, daily spend bars, month-over-month (`fl_chart`).
- **Reports** screen — date-range filter, summary cards, category table, largest expenses.
- Localization EN/HI for expense + analytics strings.
- OSS governance: MIT `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
  `.github/` issue/PR templates, `ci.yml`, `e2e-android.yml`.
- APKs removed from tree; `.gitignore` blocks `releases/`, `*.apk`, `*.aab`.

**Remaining gaps (Phase 3+):**
- 🟡 Categories UX still labeled "Vendors" in UI — rename/polish in Phase 3.
- 🟡 Login/multi-user flow kept but not required for solo diary — simplify later.
- 🟡 CSV export, backup/restore, budgets, recurring entries — Phase 4 / backlog.
- 🟡 README screenshots section empty.

**Active blockers — see [`docs/BLOCKERS.md`](BLOCKERS.md):**
- 🔴 **CI analyze** was failing on info lints — fixed in latest `dev` (migrate `withOpacity`, remove `print`).
- 🟡 **E2E tests** need Android emulator (local + `e2e-android.yml` CI).
- 🟡 **Isar integration tests** on Windows host need device/native runtime.
- 🟡 **APK history purge** — tree clean, git history still contains old binaries.
- 🟡 **Windows Developer Mode** for local plugin symlinks on some machines.

## 3. Positioning decision (do this first)

MyCally needs a crisp identity before code. Recommended framing:

> **"A private, offline expense diary you actually keep — tap a day, log what you
> spent, watch the month add up."** No accounts, no cloud, no ads. Local-first,
> bilingual.

This is honest, differentiated (privacy/offline angle), and small enough to
*finish*. **Drop or repurpose the "Vendors" + login/profile machinery** — a
solo offline diary doesn't need user accounts or vendor management. Recommended:
- **Keep:** Vendors → repurpose as **Categories/Payees** (Food, Rent, Fuel …) so
  the existing CRUD isn't wasted.
- **Cut from the core flow:** login/auth + multi-user profile. A single local
  profile (name + avatar in `shared_preferences`) is enough. Move auth to a
  *future* "sync tier" backlog item, don't block v1 on it.

(If the user wants to keep the multi-user/vendor concept, the feature plan below
still works — just don't delete those screens.)

## 4. OSS route (repo → public-ready)

Mirror what was done for the other gp repos (shopwhirl/eventgo/pictoral). Order:

1. ~~**Toolchain sanity:** `flutter pub get`, regen Isar, `flutter analyze`, `flutter test`.~~ ✅
2. **Purge binaries from history:** remove `releases/*.apk` from git history
   (`git filter-repo --path releases/ --invert-paths`, or BFG). Tree already clean.
   *(History rewrite → coordinate force-push; see BLOCKERS.md §4.)*
3. ~~**License:** MIT + README.~~ ✅
4. ~~**Governance files:** CONTRIBUTING, CODE_OF_CONDUCT, `.github/` templates.~~ ✅
5. ~~**CI:** `.github/workflows/ci.yml`.~~ ✅ — keep green; see BLOCKERS.md.
6. **README rewrite:** public-facing copy done; add screenshots/GIF once stable.
7. **Branch model:** PR `dev` → `main` (in use).
8. **Account/push gotcha:** owner is `mstomar698` — `gh auth switch --user mstomar698`.
9. **Stay private** until blockers cleared + manual QA on device.

## 5. Feature / completion plan (the real work)

Phased so a session can stop cleanly at any phase boundary.

### Phase 0 — Foundation cleanup ✅
- Positioning decided. Vendors kept as categories. Toolchain + governance landed.

### Phase 1 — Make it actually record expenses ✅
- `Expense` Isar model, repository, add-expense flow, home calendar wired to real data.
- Baseline unit tests (`expense_repository_test`, smoke test).

### Phase 2 — Analysis & Reports ✅
- `fl_chart` analysis + reports screens with repository aggregates.
- EN/HI localization for analytics strings.

### Phase 3 — Daily-utility polish (NEXT)
- Categories management UI (rename Vendors → Categories in copy/navigation).
- Recurring entries, monthly budget + alerts, quick-add presets.
- Empty-states, dark-mode pass on new screens (if any `withValues` gaps remain).

### Phase 4 — Data portability & release readiness
- **CSV export** (and optional PDF report). Encrypted local backup + restore.
- Crash/QA: `flutter analyze` clean, device matrix smoke test.
- Store assets (icon, screenshots, description) — Play Store on hold.

### Backlog (explicitly *not* v1)
- Optional cloud **sync tier** (auth/multi-user).
- OCR receipt capture + merchant auto-categorization.
- Goal tracking / savings insights. Family/shared wallet.

## 6. Quality bar (match the other gp repos)
- `flutter analyze` clean; CI `test` job green.
- E2E smoke on Android emulator (workflow present; verify green).
- Real tests for data layer + core flows.
- README with screenshots; full OSS governance; no binaries in tree.
- No portfolio listing until blockers cleared + public flip decision.

## 7. Notes for the delegated session
- **Isar codegen:** `dart run build_runner build --delete-conflicting-outputs`
- **Isar fork pin:** `MrLittleWhite/isar_flutter_libs` — don't revert without build check.
- **Branch:** integrate on `dev`; PR to `main`.
- **Don't commit APKs.** Ship as GitHub Release assets.
- **Blockers:** always read [`docs/BLOCKERS.md`](BLOCKERS.md) first.
- **gh account:** `mstomar698` for push/PR.
- **Privacy:** nothing personal/identifying in README, commits, or assets.

---

### TL;DR for whoever picks this up
MyCally is a working offline expense diary with calendar capture, analysis charts,
and reports. Next: clear blockers in `BLOCKERS.md`, green CI/e2e, APK history
purge, then Phase 3 polish + public flip decision.

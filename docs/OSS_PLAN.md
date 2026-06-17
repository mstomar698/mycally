# MyCally — OSS Revive Plan

> **Purpose of this doc:** a self-contained brief so a *fresh* Claude session can
> pick up MyCally and take it from "half-built local app" to a clean, completed,
> open-source-ready Flutter project. Written 2026-06-17. Keep MyCally **local /
> private for now** — it is **not** in the portfolio projects section yet. Decide
> public + portfolio inclusion only after Phase 2 below lands.

---

## 1. What MyCally is (intended)

A **local-first personal-finance diary**: record day-wise purchases/expenses on a
calendar, then see them as clear graphs and tables. Flutter, offline, no backend.
Bilingual (English / Hindi). Sibling in spirit to `jijivisha` (offline-first,
Hindi, Isar/local storage) — but a much smaller, single-purpose utility.

- **Platforms:** Android primary; iOS/web/macOS/Linux/Windows scaffolds present.
- **Stack:** Flutter (Dart SDK ^3.6), `provider` state, `isar` local DB,
  `easy_localization` (EN/HI), `table_calendar`, `shared_preferences`,
  `image_picker`, `intl`. Note the `isar_flutter_libs` pin to a community fork to
  fix the Gradle 8.x namespace issue.
- **Repo:** `github.com/mstomar698/mycally` — **private**, owner `mstomar698`, no
  license, last push 2025-04-07. Local checkout on branch `dev`.

## 2. Honest status snapshot (verified 2026-06-17)

**Implemented & working:**
- App shell, routing, splash, login, profile + edit-profile, settings,
  language-selector, theme/font/language preferences (persisted).
- **Vendors** CRUD (Isar) — `vendors_screen`, `edit_vendor`.
- **Home** (757-line calendar screen) with `table_calendar` wired and a
  bottom-nav shell across pages.
- Localization EN/HI; logo/font/asset pipeline set up.
- A thin test suite (theme, router, config, utils, splash, localization). Many
  `data/`, `repositories/`, `screens/` test dirs are empty `.keep` stubs.

**The core gap (this is the headline):**
- 🔴 **There is no Expense/Transaction model.** Isar only registers
  `UserSchema` + `VendorSchema` (`lib/src/data/services/database.dart`). The app
  literally **cannot record or persist an expense** — the one thing it's named for.
- 🔴 The Home calendar is **vendor/"amountDelivered"-centric with dummy data**, a
  leftover from a delivery-tracking concept, not real expense entries.
- 🔴 **Analysis** and **Reports** screens are 39-line **placeholder stubs**
  ("Analysis Screen" / "Reports Screen" centered text). No charts exist; **no
  charting or export dependency** is even in `pubspec.yaml`.

**Repo hygiene problems:**
- 🔴 **6 APKs (~135 MB) committed to git** under `releases/` (`mycally_v1.0.0`
  … `v1.2.1`). Must be purged from history before going public.
- 🔴 No OSS governance: no `LICENSE`, `CONTRIBUTING`, `CODE_OF_CONDUCT`,
  `.github/` templates, CI.
- 🟡 Local working tree has uncommitted Flutter-toolchain churn (gradle wrapper,
  xcconfig, pubspec.lock) + new `ios/Podfile`, `macos/Podfile`. Decide
  keep/discard before branching.
- 🟡 `releases/` and the `.apk` glob are **not** in `.gitignore`.

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

1. **Toolchain sanity:** `flutter pub get`, regen Isar (`dart run build_runner
   build --delete-conflicting-outputs`), `flutter analyze`, `flutter test` — get a
   green baseline. Resolve/commit-or-discard the pending toolchain churn first.
2. **Purge binaries from history:** remove `releases/*.apk` from git history
   (`git filter-repo --path releases/ --invert-paths`, or BFG). Add `releases/`
   and `*.apk` to `.gitignore`. Ship APKs as **GitHub Release assets**, never in
   the tree. *(History rewrite → coordinate force-push; repo is private + solo, so
   low risk. Confirm with user before rewriting.)*
3. **License:** add **MIT** (matches the rest of the gp portfolio) + headers as
   needed.
4. **Governance files:** `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md` (reference
   Contributor Covenant v2.1 **by link** — writing the full enumerated text trips
   a content filter, learned on pictoral), `.github/ISSUE_TEMPLATE/{bug,feature}.yml`
   + `config.yml`, `PULL_REQUEST_TEMPLATE.md`.
5. **CI:** `.github/workflows/ci.yml` — `flutter pub get` → `dart run
   build_runner build` → `flutter analyze` → `flutter test`. Optionally a build
   job producing a debug APK artifact.
6. **README rewrite:** replace the current internal "feasibility/priority #7/13"
   notes (remove that — it's portfolio-triage scratch, not for the public) with:
   what it is, screenshots/GIF, features, platforms, local setup, architecture
   note (Isar/Provider/feature-folders), contributing pointer. Add a screenshots
   section once Phase 1 UI is real.
7. **Branch model:** decide PR-only-to-`main` like shopwhirl, or keep it light.
   Currently HEAD is `dev`; reconcile `dev`/`main` before opening up.
8. **Account/push gotcha:** owner is `mstomar698`, which is **not** the default
   active gh account. Use
   `gh auth switch --user mstomar698` then
   `git -c credential.helper= -c credential.helper='!gh auth git-credential' push`.
   See Claude memory `github-accounts`.
9. **Stay private** until the product is actually usable (end of Phase 2). Going
   public with placeholder Analysis/Reports screens would hurt, not help, the
   profile — same bar applied to the other repos.

## 5. Feature / completion plan (the real work)

Phased so a session can stop cleanly at any phase boundary. **Phase 1 is the
non-negotiable core; everything after is value-add.**

### Phase 0 — Foundation cleanup
- Decide positioning (§3). Repurpose/keep Vendors; simplify or keep auth.
- Green baseline build/test (§4.1). Commit toolchain churn.

### Phase 1 — Make it actually record expenses (CORE — ships the product)
- **`Expense` Isar model** (`lib/src/data/models/expense.dart`): id, amount,
  date, category/payee ref, note, optional receipt image path, created/updated.
  Register `ExpenseSchema` in `database.dart`; run `build_runner`.
- **Repository layer** (`lib/src/data/repositories/`) — the empty dir is already
  scaffolded. CRUD + queries (by day, by month, by category).
- **Add-expense flow:** tap a calendar day → bottom sheet / form (amount, category
  picker via existing `dropdown_search`, note, optional photo). Validate via the
  existing `validators.dart`.
- **Wire the Home calendar to real data:** replace dummy `amountDelivered` content
  with per-day expense markers + a day's expense list; show **total expense this
  month** (the `total_expense_this_month` string already exists in localization)
  from real sums.
- **Tests:** repository unit tests + an add→persist→read widget test. Fill the
  empty `data/` and `screens/home` test stubs.

### Phase 2 — Analysis & Reports (turn placeholders into the value prop)
- Add a charting dep (recommend **`fl_chart`** — pure-Dart, no native build pain).
- **Analysis screen:** category breakdown (pie/donut), spend-over-time (line/bar),
  month-over-month comparison. Driven by repository aggregates.
- **Reports screen:** tabular monthly/category summaries; date-range filter;
  largest expenses; daily average.
- Localize all new strings (EN + HI in `assets/lang/`).
- **This is the gate for going public** — once Analysis/Reports are real, MyCally
  is a finishable, demoable utility.

### Phase 3 — Daily-utility polish
- Categories management UI (the repurposed Vendors screen).
- Recurring entries, monthly budget + alerts, quick-add presets.
- Empty-states, currency formatting via `intl`, dark-mode pass on new screens.

### Phase 4 — Data portability & release readiness
- **CSV export** (and optional PDF report). Encrypted local backup + restore.
- Crash/QA: `flutter analyze` clean, device matrix smoke test.
- Store assets (icon, screenshots, description) — **but Play Store publishing is
  out of scope / on hold**, same constraint as jijivisha (no Play Store account
  until the user sets one up). Web build can serve as the live demo if a
  deployment is wanted later.

### Backlog (explicitly *not* v1)
- Optional cloud **sync tier** (this is where auth/multi-user comes back).
- OCR receipt capture + merchant auto-categorization.
- Goal tracking / savings insights. Family/shared wallet.

## 6. Quality bar (match the other gp repos)
- `flutter analyze` clean; `flutter test` green in CI.
- Real tests for the data layer + core flows (not just config/util tests).
- README with screenshots; full OSS governance file set; no binaries in tree.
- No portfolio listing and **no public flip** until Phase 2 is done and verified.

## 7. Notes for the delegated session
- **Isar codegen:** any model change needs `dart run build_runner build
  --delete-conflicting-outputs`; commit the regenerated `*.g.dart`.
- **Isar fork pin:** `isar_flutter_libs` points at `MrLittleWhite/isar_flutter_libs`
  for Gradle 8.x — don't "fix" it back to pub without checking the build.
  *(If Isar proves painful on current Flutter, evaluate swapping to `drift` —
  jijivisha already uses Drift/SQLCipher, so there's in-house precedent. Treat as
  a Phase-0 spike decision, not a default.)*
- **Branch:** currently on `dev`; reconcile with `main` early.
- **Don't commit APKs.** Ever. Releases go to GitHub Release assets.
- **gh account:** owner `mstomar698` is not the default active account (see §4.8).
- **Privacy:** nothing personal/identifying in README, commits, or assets — same
  rule as the rest of the portfolio.
- **Update trackers when done:** `~/Work/mine/gp/GP_STATUS.md` (mycally row, Tier 4
  → promote) and Claude memory `gp-portfolio-status`.

---

### TL;DR for whoever picks this up
MyCally is a Flutter expense-diary that **can't yet record an expense** (no model)
and whose Analysis/Reports screens are stubs. The job: (1) clean the repo (purge
135 MB of committed APKs, add license + governance + CI), (2) build the missing
`Expense` model + capture flow and wire the calendar to real data, (3) turn
Analysis/Reports into real `fl_chart` views. Keep it **private + out of the
portfolio** until step 3 is done — then decide public + portfolio inclusion.

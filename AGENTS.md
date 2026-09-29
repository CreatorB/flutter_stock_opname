# AGENTS.md

Project guidance for AI coding agents (and humans) working on `flutter_stock_opname`.

## Tooling

This project uses **FVM (Flutter Version Management)** for Flutter SDK pinning.

- `.fvmrc` pins the Flutter channel (`stable`).
- VS Code is configured to use `.fvm/versions/stable` (see `.vscode/settings.json`).

### Prerequisites

- Install [FVM](https://fvm.app/docs/getting_started/installation).
- From the repo root, run `fvm install` to fetch the pinned SDK the first time.

### Common commands

Always prefix Flutter / Dart commands with `fvm`:

```bash
# Install dependencies
fvm flutter pub get

# Regenerate localization files (when editing assets/translations/*.json)
fvm flutter pub run easy_localization:generate --source-dir assets/translations --output-dir lib/generated
fvm flutter pub run easy_localization:generate -f keys -o lib -S assets/translations

# Static analysis
fvm flutter analyze

# Run on a specific device (emulator-5554, etc.)
fvm flutter run -d emulator-5554

# Build APK
fvm flutter build apk --release

# Clean
fvm flutter clean
```

Do **not** invoke a bare `flutter` or `dart` binary - use `fvm flutter` / `fvm dart`.

## Git workflow

```
feature/* or fix/*  ──►  dev  ──►  main
```

- Branch off `dev` for new work: `git checkout -b fix/<short-desc> dev`.
- Reference the GitHub issue in commit messages, e.g. `fix(sale): keep cart items in CartView (#42)`.
- After PR approval: merge `fix/*` → `dev`, then `dev` → `main`.
- Close the referenced issue after the change is on `main` (or with the closing keyword `Closes #N` / `Fixes #N` in the PR description).

## Project layout

```
lib/
  common/         shared widgets (gradient_header, glow_card, …)
  core/           DI, routing, theme, services
  features/       one folder per feature (auth, sale, opname, profile, settings, …)
    <feature>/
      bloc/       state management (Bloc / Cubit + Events + States)
      models/     data models
      service/    API / data layer
      view/       screens
      widgets/    feature-specific widgets
  generated/      codegen output (codegen_loader.g.dart)
  locale_keys.g.dart  generated keys for easy_localization
```

## Localization

- Source of truth: `assets/translations/{id,en}.json`.
- After editing those files, regenerate `lib/generated/codegen_loader.g.dart` and `lib/locale_keys.g.dart` (commands above).
- Use `LocaleKeys.<key>.tr()` in widgets for translated strings.

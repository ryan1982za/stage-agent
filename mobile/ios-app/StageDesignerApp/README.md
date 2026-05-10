# StageDesignerApp (iOS Shell)

This folder contains the first SwiftUI app shell for iPhone-first development.

## Current scope

- Stage list screen
- Stage detail screen navigation from stage list
- Create stage from title
- Rename stage metadata title
- Delete stage
- Add sample stage element via default built-in asset
- Add checklist items and run notes in stage detail
- Toggle checklist completion state in stage detail
- Export preview actions for JSON and CSV
- Export JSON and CSV files to temporary local storage
- Export PDF/PNG/JPEG stage visuals to temporary local storage
- Native share sheet for generated visual export files
- SQLite-first persistence wiring through AppContainer with in-memory fallback

## Persistence modes

- `AppContainer.makeDefault()` prefers SQLite persistence and falls back to in-memory repositories when schema discovery is unavailable.
- `AppContainer.makeSQLiteBacked(dbPath:schemaPath:)` uses SQLite stage and notes repositories.

## Product naming

- Runtime app name: Stage Agent

## Build and Run in Xcode

Use the generated Xcode project wrapper to run the app target on simulator.

```bash
cd mobile/ios-app/StageDesignerApp
bash ./scripts/bootstrap_xcode_project.sh
```

What this does:

- Installs `xcodegen` with Homebrew if needed.
- Generates `StageDesignerApp.xcodeproj` from `project.yml`.
- Opens the project in Xcode.

Then in Xcode:

1. Select an iPhone simulator.
2. Choose the `StageDesignerApp` scheme.
3. Press Run.

Note: `project.yml` is the source of truth for this wrapper project. Re-run the bootstrap script after changing source layout or project settings.

## Next implementation steps

1. Decide whether to commit generated `StageDesignerApp.xcodeproj` or keep `project.yml` + generation script as source of truth.
2. Expand stage detail/editor interactions beyond sample element insertion.
3. Add user-selectable output destination and export naming options.

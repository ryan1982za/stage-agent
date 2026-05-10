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

## CI Bundle Identifier

- The app wrapper bundle identifier is `com.stage.agent.mobile` (defined in `project.yml`).
- Keep GitHub Actions variable `IOS_BUNDLE_IDENTIFIER` set to `com.stage.agent.mobile` for App Store signing/export.
- If this variable and the provisioning profile target do not match, archive/export can fail with signing/profile mismatch errors.

## Apply Logo and App Icon Branding

Use the SVG logo at [docs/Stage Agent.svg](../../../docs/Stage%20Agent.svg) to generate iOS-ready app icon and in-app mark assets.

```bash
cd mobile/ios-app/StageDesignerApp
bash ./scripts/generate_brand_assets.sh
```

What this does:

- Converts the SVG into a 1024 master PNG.
- Generates iPhone app icon sizes into `App/Assets.xcassets/AppIcon.appiconset`.
- Generates `StageAgentMark` in-app image assets for UI branding.

Then regenerate/open the Xcode project:

```bash
bash ./scripts/bootstrap_xcode_project.sh
```

If your logo file is in a different path, pass it explicitly:

```bash
bash ./scripts/generate_brand_assets.sh "/absolute/path/to/Stage Agent.svg"
```

## Next implementation steps

1. Decide whether to commit generated `StageDesignerApp.xcodeproj` or keep `project.yml` + generation script as source of truth.
2. Expand stage detail/editor interactions beyond sample element insertion.
3. Add user-selectable output destination and export naming options.

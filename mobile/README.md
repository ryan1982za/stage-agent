# Mobile App Scaffold (iOS-First)

This directory is reserved for the native mobile implementation of Shooting Stage Designer.

## v1 Target

- iPhone-first native app.
- Local-only persistence with SQLite.
- 2D stage editor and asset placement.
- Checklist/run notes.
- Export-only outputs (PDF, PNG/JPEG, CSV).

## Planned Structure

- mobile/ios-app/
  - App/
  - Domain/
  - Application/
  - Infrastructure/
  - UI/
  - Tests/

## Current Implementation Status

- Created `mobile/ios-app/StageDesignerCore` Swift package with three modules:
  - `StageDesignerDomain`
  - `StageDesignerPersistence`
  - `StageDesignerApplication`
- Added first vertical slice use cases:
  - Create stage
  - List stages
  - Delete stage
- Added in-memory repository adapter for early integration/testing.
- Added export mapping layer:
  - Domain to v1 JSON export model
  - CSV export generation for stage elements
- Added SQLite foundation adapters:
  - `SQLiteDatabase` wrapper
  - `SQLiteStageRepository` CRUD for stage table
- Added iOS SwiftUI app shell with stage list/create/delete flow.
- Added export preview actions (JSON and CSV) in stage list shell.
- Seeded built-in asset catalog for v1 baseline export/editor flows.
- Added export file writing use case for JSON/CSV artifact output.
- Added stage metadata update and notes/checklist use cases.
- Added stage detail screen model and navigation wiring from stage list.
- Added SQLite notes repository and persistence tests.
- Added notes snapshot retrieval use case and empty-text validation for checklist/run notes.
- Added stage detail visual export files (PDF, PNG, JPEG) written to local temporary storage.
- Added native iOS share sheet integration for generated visual export files.

## Local Validation (macOS)

```bash
cd mobile/ios-app/StageDesignerCore
swift test
```

## CI Validation

- `.github/workflows/build-mobile-native.yml` runs iOS core validation with `swift test` on macOS.
- App Store upload remains available by manual dispatch when an Xcode project/workspace exists and signing secrets are configured.

## Implemented Core Files

- `Sources/StageDesignerApplication/UseCases/CreateStageUseCase.swift`
- `Sources/StageDesignerApplication/UseCases/ListStagesUseCase.swift`
- `Sources/StageDesignerApplication/Export/StageExportModels.swift`
- `Sources/StageDesignerApplication/Export/StageExportBuilder.swift`
- `Sources/StageDesignerPersistence/SQLite/SQLiteDatabase.swift`
- `Sources/StageDesignerPersistence/SQLite/Repositories/SQLiteStageRepository.swift`

## iOS App Shell

- `mobile/ios-app/StageDesignerApp/App/StageDesignerApp.swift`
- `mobile/ios-app/StageDesignerApp/Features/StageList/StageListView.swift`
- `mobile/ios-app/StageDesignerApp/Features/StageList/StageListViewModel.swift`
- `mobile/ios-app/StageDesignerApp/Features/StageDetail/StageDetailView.swift`
- `mobile/ios-app/StageDesignerApp/Features/StageDetail/StageDetailViewModel.swift`
- `mobile/ios-app/StageDesignerApp/Infrastructure/StageVisualExportService.swift`

## SQLite Wiring Notes

- `AppContainer.makeSQLiteBacked(dbPath:schemaPath:)` is available for enabling local SQLite persistence.
- `AppContainer.makeDefault()` now prefers SQLite storage and falls back to in-memory repositories when schema discovery is unavailable.

## Source Docs

- docs/specs/ios-stage-designer-v1.md
- docs/architecture/system-components.md
- docs/architecture/use-cases.md
- docs/architecture/class-diagrams.md
- docs/architecture/user-interface.md
- docs/contracts/sqlite-schema-v1.sql
- docs/contracts/stage-export-schema.v1.json
- docs/contracts/asset-catalog-v1.md

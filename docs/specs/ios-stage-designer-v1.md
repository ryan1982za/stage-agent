# iOS Stage Designer v1 Product Specification

## Document Control

| Field | Value |
|---|---|
| Product | Shooting Stage Designer |
| Status | Draft |
| Version | 0.1.0 |
| Owner | Product + Engineering |
| Last Updated | 2026-05-09 |
| Source of Truth | docs/shooting-stage-designer-brief.pdf |

## Purpose

Deliver an iPhone-first mobile app that helps sports shooters design and iterate stage setups locally on device.

## Scope

### In Scope

- iPhone-first UX and interaction model.
- Local-only data model and persistence using SQLite.
- 2D drag-and-drop stage editor.
- Full stage setup asset support in v1, including targets, barrels, and related setup objects.
- Stage creation/editing and organization.
- Target/prop library management.
- Simulation scope limited to checklist and run notes.
- Export-only outputs: PDF, PNG/JPEG, CSV.
- Share flow through iOS share sheet.

### Out of Scope

- Backend APIs and cloud sync.
- Authentication and user accounts.
- Import workflows from external files.
- Rules engine and formal discipline validation.
- iPad-specific optimization in v1.
- Advanced scoring analytics.

## Users

- Primary user: sports shooter designing practical stage setups.
- Secondary user: range organizer doing quick setup planning.

## Feature Requirements

### FR-01 Stage Management

- Create a stage with metadata: title, discipline label (free text), location (optional), notes.
- Duplicate, rename, archive, and delete stages.
- Persist stage edits automatically.

### FR-02 Canvas Editing

- Display a 2D stage canvas with configurable width/height.
- Add, move, rotate, resize, duplicate, delete objects.
- Support multi-select and layer ordering.
- Support snap-to-grid toggle and spacing guides.
- Undo/redo at interaction command level.

### FR-03 Asset Library

- Include baseline assets grouped by category:
  - Targets: paper target, steel target, mini target, no-shoot target.
  - Barriers and props: barrel, wall section, fault line, box marker, cone.
  - Environment markers: start point, shooting area, safety marker.
- Allow user-defined custom assets with name, category, dimensions, and notes.
- Search and filter assets by category and keyword.

### FR-04 Simulation Notes

- Add checklist items per stage.
- Track checklist completion state.
- Capture run notes with timestamp and free text.
- No scoring math, penalties, or match aggregation in v1.

### FR-05 Export and Share

- Export stage summary to PDF.
- Export canvas image to PNG and JPEG.
- Export structured stage data to CSV.
- Launch iOS share sheet from each export action.

## Non-Functional Requirements

- NFR-01: Works offline after first install.
- NFR-02: Save operations complete without user-visible blocking for common stage sizes (< 200 objects).
- NFR-03: Primary interactions remain responsive under 16 ms frame budget target on recent iPhones.
- NFR-04: Export actions must complete without app crash for standard stage payloads.
- NFR-05: Accessibility baseline includes Dynamic Type support, VoiceOver labels for core controls, and minimum tap target 44x44 points.

## Acceptance Criteria

### AC-01 Stage Lifecycle

- User can create a stage, add metadata, close app, reopen app, and see unchanged data.

### AC-02 Core Editing

- User can place at least 50 objects and perform move/rotate/resize/delete actions without data loss.

### AC-03 Library and Custom Assets

- User can add a custom asset and place it on canvas in same session and after restart.

### AC-04 Simulation Notes

- User can complete checklist items and append run notes with timestamp ordering.

### AC-05 Export

- User can export the same stage as PDF, PNG/JPEG, and CSV, then invoke share sheet each time.

### AC-06 Scope Guard

- No import, cloud, auth, or rules validation surface appears in v1 UI.

## Requirement Traceability

| Requirement | Planned Area |
|---|---|
| FR-01 | Stage domain + persistence + stage list/detail UI |
| FR-02 | Canvas engine + editor interactions + command stack |
| FR-03 | Asset repository + catalog UI + custom asset form |
| FR-04 | Notes/checklist module |
| FR-05 | Export pipeline + share adapters |
| NFR-01..05 | Persistence, rendering, accessibility, QA |

## Delivery Sequence

1. Product spec freeze.
2. Architecture freeze.
3. iOS foundation scaffold.
4. Editor vertical slice.
5. Asset catalog and custom assets.
6. Notes module.
7. Export and share.
8. QA and release checklist.

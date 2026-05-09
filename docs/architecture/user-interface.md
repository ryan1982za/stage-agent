# User Interface and Experience

## Document Control

| Field | Value |
|---|---|
| System Name | Shooting Stage Designer (iOS v1) |
| Status | Draft |
| Version | 0.1.0 |
| Owner | Product + UX + iOS Engineering |
| Last Updated | 2026-05-09 |
| Source of Truth | docs/specs/ios-stage-designer-v1.md |
| Related Docs | docs/architecture/system-components.md, docs/architecture/use-cases.md |

## 1. Purpose and Scope

Purpose: define iPhone-first UX baseline for v1.

In Scope:
- Stage list and stage detail.
- 2D editor canvas and asset insertion.
- Checklist/run notes screen.
- Export/share flow.

Out of Scope:
- iPad split layout.
- Collaborative interactions.
- Import UI.

## 2. Experience Vision

| Attribute | Target Direction | Notes |
|---|---|---|
| Visual Tone | Technical and practical | Utility-first, low visual noise |
| Interaction Pace | Deliberate but fast | Editing should feel precise |
| Information Density | Balanced | Keep controls available without crowding |
| Trust Signals | Clarity and persistence | Explicit saved state and undo/redo confidence |

Design principles:
- Keep editing controls predictable and muscle-memory friendly.
- Prioritize stage clarity over decoration.
- Surface reversible actions and quick recovery.

## 3. Screen Inventory

| Screen | Goal | Priority |
|---|---|---|
| Stage List | Create/open/manage stages | High |
| Stage Editor | Edit canvas with assets | High |
| Asset Library Sheet | Find and insert assets | High |
| Notes Screen | Checklist and run notes | Medium |
| Export Sheet | Pick format and share | High |

## 4. Key Flows

### FLOW-01 Create Stage

1. Open Stage List.
2. Tap New Stage.
3. Enter title and optional metadata.
4. Save and enter Stage Editor.

### FLOW-02 Edit Canvas

1. Open Asset Library.
2. Select asset.
3. Tap/drag to place on canvas.
4. Manipulate with handles/gestures.
5. Undo/redo as needed.

### FLOW-03 Export Stage

1. Tap Export in Stage Editor.
2. Select format (PDF, PNG/JPEG, CSV).
3. Generate output.
4. Open share sheet.

## 5. Layout and Interaction Rules

- Canvas occupies primary visual region in Stage Editor.
- Bottom tool rail provides common actions: add asset, select, transform, layer, delete, export.
- Asset Library opens as modal sheet with category tabs and search.
- Notes open from editor as a dedicated screen to avoid cramped overlays on iPhone.
- Touch targets minimum 44x44 points.

## 6. States and Feedback

| State | Expected UX |
|---|---|
| Loading | Lightweight skeleton in list/editor launch |
| Empty | Prompt to create first stage |
| Error | Inline message with retry where relevant |
| Success | Subtle confirmation after export generation |

## 7. Accessibility Baseline

- VoiceOver labels for all core controls and canvas object actions.
- Dynamic Type support for list/detail text surfaces.
- Clear focus order for sheets and modal flows.
- Avoid color-only signals for selection and errors.

## 8. Open UX Decisions for Engineering Kickoff

- Final gesture mapping for rotate/resize when one-hand usage is prioritized.
- Preferred pattern for multiselect on iPhone (long-press mode vs toolbar toggle).
- Export preview depth in v1 (thumbnail-only vs rich preview).

# Class Diagrams

## Document Control

| Field | Value |
|---|---|
| System Name | Shooting Stage Designer (iOS v1) |
| Status | Draft |
| Version | 0.1.0 |
| Owner | Architecture |
| Last Updated | 2026-05-09 |
| Source of Truth | docs/specs/ios-stage-designer-v1.md |
| Related Docs | docs/architecture/system-components.md, docs/architecture/use-cases.md, docs/contracts/stage-export-schema.v1.json |

## 1. Purpose and Scope

Purpose: define static domain and persistence model for iOS v1 with Android portability.

In Scope:
- Core domain entities and value objects.
- Repository interfaces and export DTOs.
- SQLite entity relationships.

Out of Scope:
- Network DTOs and remote API contracts.
- Rules engine scoring abstractions.

## 2. Structural Summary

| Topic | Summary |
|---|---|
| Primary Modules | Editor, Assets, Notes, Export, Persistence |
| Core Abstractions | Stage, StageElement, AssetDefinition, RunNote, ChecklistItem |
| Dominant Patterns | Layered architecture, repository pattern, command-based editing |

## 3. High-Level Class Diagram

```mermaid
classDiagram
    class Stage {
        +UUID id
        +String title
        +String disciplineLabel
        +String location
        +String notes
        +DateTime updatedAt
    }

    class StageElement {
        +UUID id
        +UUID stageId
        +UUID assetId
        +float x
        +float y
        +float width
        +float height
        +float rotationDeg
        +int zIndex
    }

    class AssetDefinition {
        +UUID id
        +String name
        +String category
        +bool isCustom
        +float defaultWidth
        +float defaultHeight
    }

    class ChecklistItem {
        +UUID id
        +UUID stageId
        +String text
        +bool isDone
        +DateTime updatedAt
    }

    class RunNote {
        +UUID id
        +UUID stageId
        +String text
        +DateTime createdAt
    }

    class ExportPackage {
        +StageExportDto toDto(Stage)
        +File renderPdf()
        +File renderImage()
        +File renderCsv()
    }

    Stage "1" --> "many" StageElement : contains
    Stage "1" --> "many" ChecklistItem : tracks
    Stage "1" --> "many" RunNote : logs
    StageElement --> AssetDefinition : references
    ExportPackage --> Stage : reads
```

## 4. Repository Contracts

| Type | Responsibility |
|---|---|
| StageRepository | CRUD for Stage and StageElement aggregates |
| AssetRepository | Built-in/custom asset retrieval and storage |
| NotesRepository | Checklist and run note persistence |
| ExportRepository | Optional record of generated export metadata |

## 5. ER Diagram

```mermaid
erDiagram
    STAGE ||--o{ STAGE_ELEMENT : has
    STAGE ||--o{ CHECKLIST_ITEM : has
    STAGE ||--o{ RUN_NOTE : has
    ASSET_DEFINITION ||--o{ STAGE_ELEMENT : referenced_by

    STAGE {
        string id PK
        string title
        string discipline_label
        string location
        string notes
        datetime updated_at
    }

    STAGE_ELEMENT {
        string id PK
        string stage_id FK
        string asset_id FK
        real x
        real y
        real width
        real height
        real rotation_deg
        integer z_index
    }

    ASSET_DEFINITION {
        string id PK
        string name
        string category
        integer is_custom
        real default_width
        real default_height
    }

    CHECKLIST_ITEM {
        string id PK
        string stage_id FK
        string text
        integer is_done
        datetime updated_at
    }

    RUN_NOTE {
        string id PK
        string stage_id FK
        string text
        datetime created_at
    }
```

## 6. Invariants

- Stage element dimensions must be positive values.
- zIndex values are unique per stage at persistence boundary.
- StageElement references must point to a valid AssetDefinition.
- Export DTO represents one immutable snapshot of Stage aggregate.

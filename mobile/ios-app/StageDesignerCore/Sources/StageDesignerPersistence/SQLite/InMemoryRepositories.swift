import Foundation
import StageDesignerDomain

public final class InMemoryStageRepository: StageRepository {
    private var stagesById: [UUID: Stage] = [:]

    public init(seedStages: [Stage] = []) {
        for stage in seedStages {
            stagesById[stage.id] = stage
        }
    }

    public func fetchAllStages() throws -> [Stage] {
        stagesById.values
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    public func fetchStage(id: UUID) throws -> Stage? {
        stagesById[id]
    }

    public func upsertStage(_ stage: Stage) throws {
        stagesById[stage.id] = stage
    }

    public func deleteStage(id: UUID) throws {
        stagesById.removeValue(forKey: id)
    }
}

public final class InMemoryAssetRepository: AssetRepository {
    private var assetsById: [UUID: AssetDefinition] = [:]

    public init(seedAssets: [AssetDefinition] = []) {
        for asset in seedAssets {
            assetsById[asset.id] = asset
        }
    }

    public func fetchBuiltInAssets() throws -> [AssetDefinition] {
        assetsById.values
            .filter { !$0.isCustom }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    public func fetchCustomAssets() throws -> [AssetDefinition] {
        assetsById.values
            .filter { $0.isCustom }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    public func upsertAsset(_ asset: AssetDefinition) throws {
        assetsById[asset.id] = asset
    }
}

public final class InMemoryNotesRepository: NotesRepository {
    private var checklistByStageId: [UUID: [ChecklistItem]] = [:]
    private var notesByStageId: [UUID: [RunNote]] = [:]

    public init() {}

    public func fetchChecklist(stageId: UUID) throws -> [ChecklistItem] {
        (checklistByStageId[stageId] ?? [])
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    public func fetchRunNotes(stageId: UUID) throws -> [RunNote] {
        (notesByStageId[stageId] ?? [])
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func upsertChecklistItem(_ item: ChecklistItem) throws {
        var items = checklistByStageId[item.stageId] ?? []
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
        checklistByStageId[item.stageId] = items
    }

    public func appendRunNote(_ note: RunNote) throws {
        var notes = notesByStageId[note.stageId] ?? []
        notes.append(note)
        notesByStageId[note.stageId] = notes
    }
}

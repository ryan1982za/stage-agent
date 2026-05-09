import Foundation
import StageDesignerDomain

public protocol StageRepository {
    func fetchAllStages() throws -> [Stage]
    func fetchStage(id: UUID) throws -> Stage?
    func upsertStage(_ stage: Stage) throws
    func deleteStage(id: UUID) throws
}

public protocol AssetRepository {
    func fetchBuiltInAssets() throws -> [AssetDefinition]
    func fetchCustomAssets() throws -> [AssetDefinition]
    func upsertAsset(_ asset: AssetDefinition) throws
}

public protocol NotesRepository {
    func fetchChecklist(stageId: UUID) throws -> [ChecklistItem]
    func fetchRunNotes(stageId: UUID) throws -> [RunNote]
    func upsertChecklistItem(_ item: ChecklistItem) throws
    func appendRunNote(_ note: RunNote) throws
}

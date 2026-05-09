import Foundation

public struct StageExportV1: Codable, Equatable {
    public let schemaVersion: String
    public let exportedAt: String
    public let stage: StageExportStage
    public let assets: [StageExportAsset]
    public let elements: [StageExportElement]
    public let checklist: [StageExportChecklistItem]
    public let runNotes: [StageExportRunNote]

    public init(
        schemaVersion: String = "1.0.0",
        exportedAt: String,
        stage: StageExportStage,
        assets: [StageExportAsset],
        elements: [StageExportElement],
        checklist: [StageExportChecklistItem],
        runNotes: [StageExportRunNote]
    ) {
        self.schemaVersion = schemaVersion
        self.exportedAt = exportedAt
        self.stage = stage
        self.assets = assets
        self.elements = elements
        self.checklist = checklist
        self.runNotes = runNotes
    }
}

public struct StageExportStage: Codable, Equatable {
    public let id: String
    public let title: String
    public let disciplineLabel: String
    public let location: String
    public let notes: String
    public let updatedAt: String
}

public struct StageExportAsset: Codable, Equatable {
    public let id: String
    public let name: String
    public let category: String
    public let isCustom: Bool
    public let defaultWidth: Double
    public let defaultHeight: Double
    public let notes: String
}

public struct StageExportElement: Codable, Equatable {
    public let id: String
    public let stageId: String
    public let assetId: String
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
    public let rotationDeg: Double
    public let zIndex: Int
}

public struct StageExportChecklistItem: Codable, Equatable {
    public let id: String
    public let stageId: String
    public let text: String
    public let isDone: Bool
    public let updatedAt: String
}

public struct StageExportRunNote: Codable, Equatable {
    public let id: String
    public let stageId: String
    public let text: String
    public let createdAt: String
}

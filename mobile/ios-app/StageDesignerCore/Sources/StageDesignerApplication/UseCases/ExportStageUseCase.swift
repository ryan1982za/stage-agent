import Foundation
import StageDesignerPersistence

public enum ExportStageUseCaseError: Error, Equatable {
    case stageNotFound(stageId: UUID)
}

public struct ExportStageResult {
    public let json: String
    public let csv: String

    public init(json: String, csv: String) {
        self.json = json
        self.csv = csv
    }
}

public final class ExportStageUseCase {
    private let stageRepository: StageRepository
    private let assetRepository: AssetRepository
    private let notesRepository: NotesRepository
    private let exportBuilder: StageExportBuilder

    public init(
        stageRepository: StageRepository,
        assetRepository: AssetRepository,
        notesRepository: NotesRepository,
        exportBuilder: StageExportBuilder = StageExportBuilder()
    ) {
        self.stageRepository = stageRepository
        self.assetRepository = assetRepository
        self.notesRepository = notesRepository
        self.exportBuilder = exportBuilder
    }

    public func execute(stageId: UUID, exportedAt: Date = Date()) throws -> ExportStageResult {
        guard var stage = try stageRepository.fetchStage(id: stageId) else {
            throw ExportStageUseCaseError.stageNotFound(stageId: stageId)
        }

        stage.checklist = try notesRepository.fetchChecklist(stageId: stageId)
        stage.runNotes = try notesRepository.fetchRunNotes(stageId: stageId)

        let assets = try assetRepository.fetchBuiltInAssets() + assetRepository.fetchCustomAssets()
        let exportModel = try exportBuilder.buildExport(stage: stage, allAssets: assets, exportedAt: exportedAt)

        return ExportStageResult(
            json: try exportBuilder.toPrettyJSON(exportModel),
            csv: try exportBuilder.toCSV(stage: stage, allAssets: assets)
        )
    }
}

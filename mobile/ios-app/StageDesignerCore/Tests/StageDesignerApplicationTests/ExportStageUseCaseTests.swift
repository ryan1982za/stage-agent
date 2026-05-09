import Foundation
import XCTest
@testable import StageDesignerApplication
import StageDesignerDomain
import StageDesignerPersistence

final class ExportStageUseCaseTests: XCTestCase {
    func testExecuteReturnsJsonAndCsvForExistingStage() throws {
        let stageId = UUID()
        let assetId = UUID()

        let stage = Stage(
            id: stageId,
            title: "Export Stage",
            elements: [
                StageElement(stageId: stageId, assetId: assetId, x: 1, y: 2, width: 3, height: 4, zIndex: 0)
            ]
        )

        let stageRepo = InMemoryStageRepository(seedStages: [stage])
        let assetRepo = InMemoryAssetRepository(seedAssets: [
            AssetDefinition(
                id: assetId,
                name: "Paper Target",
                category: "Target",
                isCustom: false,
                defaultWidth: 0.46,
                defaultHeight: 0.76
            )
        ])
        let notesRepo = InMemoryNotesRepository()
        try notesRepo.upsertChecklistItem(ChecklistItem(stageId: stageId, text: "Check start marker"))
        try notesRepo.appendRunNote(RunNote(stageId: stageId, text: "Warmup run"))

        let useCase = ExportStageUseCase(stageRepository: stageRepo, assetRepository: assetRepo, notesRepository: notesRepo)
        let result = try useCase.execute(stageId: stageId)

        XCTAssertTrue(result.json.contains("\"schemaVersion\""))
        XCTAssertTrue(result.json.contains(stageId.uuidString.lowercased()))
        XCTAssertTrue(result.json.contains("Check start marker"))
        XCTAssertTrue(result.json.contains("Warmup run"))
        XCTAssertTrue(result.csv.contains("element_id,stage_id,asset_id"))
    }

    func testExecuteThrowsForMissingStage() {
        let stageRepo = InMemoryStageRepository()
        let assetRepo = InMemoryAssetRepository()
        let notesRepo = InMemoryNotesRepository()
        let useCase = ExportStageUseCase(stageRepository: stageRepo, assetRepository: assetRepo, notesRepository: notesRepo)
        let missingId = UUID()

        XCTAssertThrowsError(try useCase.execute(stageId: missingId)) { error in
            XCTAssertEqual(error as? ExportStageUseCaseError, .stageNotFound(stageId: missingId))
        }
    }
}

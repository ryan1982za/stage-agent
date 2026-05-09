import Foundation
import XCTest
@testable import StageDesignerApplication
import StageDesignerDomain
import StageDesignerPersistence

final class WriteStageExportFilesUseCaseTests: XCTestCase {
    func testExecuteWritesJsonAndCsvFiles() throws {
        let stageId = UUID()
        let assetId = UUID()

        let stage = Stage(
            id: stageId,
            title: "File Export",
            elements: [
                StageElement(stageId: stageId, assetId: assetId, x: 1, y: 1, width: 2, height: 2, zIndex: 0)
            ]
        )

        let stageRepo = InMemoryStageRepository(seedStages: [stage])
        let assetRepo = InMemoryAssetRepository(seedAssets: [
            AssetDefinition(
                id: assetId,
                name: "Target",
                category: "Target",
                isCustom: false,
                defaultWidth: 0.46,
                defaultHeight: 0.76
            )
        ])
        let notesRepo = InMemoryNotesRepository()

        let exportUseCase = ExportStageUseCase(stageRepository: stageRepo, assetRepository: assetRepo, notesRepository: notesRepo)
        let writeUseCase = WriteStageExportFilesUseCase(exportStageUseCase: exportUseCase)

        let outputDir = FileManager.default.temporaryDirectory.appendingPathComponent("stage-export-\(UUID().uuidString)")
        let result = try writeUseCase.execute(stageId: stageId, outputDirectory: outputDir, baseFileName: "stage-v1")

        XCTAssertTrue(FileManager.default.fileExists(atPath: result.jsonURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: result.csvURL.path))

        let jsonContent = try String(contentsOf: result.jsonURL, encoding: .utf8)
        let csvContent = try String(contentsOf: result.csvURL, encoding: .utf8)

        XCTAssertTrue(jsonContent.contains("\"schemaVersion\""))
        XCTAssertTrue(csvContent.contains("element_id,stage_id,asset_id"))
    }
}

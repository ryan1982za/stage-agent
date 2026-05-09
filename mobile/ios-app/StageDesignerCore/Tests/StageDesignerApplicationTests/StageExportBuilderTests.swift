import Foundation
import XCTest
@testable import StageDesignerApplication
import StageDesignerDomain

final class StageExportBuilderTests: XCTestCase {
    func testBuildExportIncludesOnlyAssetsUsedByStageElements() throws {
        let builder = StageExportBuilder()
        let stageId = UUID()
        let usedAssetId = UUID()
        let unusedAssetId = UUID()

        let stage = Stage(
            id: stageId,
            title: "Stage A",
            elements: [
                StageElement(stageId: stageId, assetId: usedAssetId, x: 1, y: 2, width: 3, height: 4, zIndex: 0)
            ]
        )

        let usedAsset = AssetDefinition(
            id: usedAssetId,
            name: "Paper Target",
            category: "Target",
            isCustom: false,
            defaultWidth: 0.46,
            defaultHeight: 0.76
        )

        let unusedAsset = AssetDefinition(
            id: unusedAssetId,
            name: "Unused",
            category: "Prop",
            isCustom: false,
            defaultWidth: 1,
            defaultHeight: 1
        )

        let export = try builder.buildExport(stage: stage, allAssets: [usedAsset, unusedAsset])

        XCTAssertEqual(export.schemaVersion, "1.0.0")
        XCTAssertEqual(export.assets.count, 1)
        XCTAssertEqual(export.assets.first?.id, usedAssetId.uuidString.lowercased())
        XCTAssertEqual(export.elements.count, 1)
    }

    func testBuildExportThrowsWhenAssetDefinitionMissing() {
        let builder = StageExportBuilder()
        let stageId = UUID()
        let missingAssetId = UUID()

        let stage = Stage(
            id: stageId,
            title: "Stage B",
            elements: [
                StageElement(stageId: stageId, assetId: missingAssetId, x: 0, y: 0, width: 1, height: 1, zIndex: 0)
            ]
        )

        XCTAssertThrowsError(try builder.buildExport(stage: stage, allAssets: [])) { error in
            XCTAssertEqual(error as? StageExportBuilderError, .missingAssetDefinition(assetId: missingAssetId))
        }
    }

    func testToCSVIncludesHeaderAndRows() throws {
        let builder = StageExportBuilder()
        let stageId = UUID()
        let assetId = UUID()

        let stage = Stage(
            id: stageId,
            title: "Stage C",
            elements: [
                StageElement(stageId: stageId, assetId: assetId, x: 10, y: 20, width: 30, height: 40, zIndex: 1)
            ]
        )

        let asset = AssetDefinition(
            id: assetId,
            name: "Barrel, Blue",
            category: "Prop",
            isCustom: false,
            defaultWidth: 0.6,
            defaultHeight: 0.9
        )

        let csv = try builder.toCSV(stage: stage, allAssets: [asset])

        XCTAssertTrue(csv.contains("element_id,stage_id,asset_id"))
        XCTAssertTrue(csv.contains("\"Barrel, Blue\""))
    }
}

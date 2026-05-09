import XCTest
@testable import StageDesignerApplication
import StageDesignerDomain
import StageDesignerPersistence

final class AddStageElementUseCaseTests: XCTestCase {
    func testExecuteAddsElementWithAssetDefaultDimensions() throws {
        let stage = Stage(title: "Edit Stage")
        let asset = AssetDefinition(
            name: "Barrel",
            category: "Prop",
            isCustom: false,
            defaultWidth: 0.6,
            defaultHeight: 0.9
        )

        let stageRepo = InMemoryStageRepository(seedStages: [stage])
        let assetRepo = InMemoryAssetRepository(seedAssets: [asset])

        let useCase = AddStageElementUseCase(stageRepository: stageRepo, assetRepository: assetRepo)

        let updated = try useCase.execute(
            AddStageElementInput(stageId: stage.id, assetId: asset.id, x: 5, y: 7)
        )

        XCTAssertEqual(updated.elements.count, 1)
        XCTAssertEqual(updated.elements.first?.width, 0.6)
        XCTAssertEqual(updated.elements.first?.height, 0.9)
        XCTAssertEqual(updated.elements.first?.zIndex, 0)
    }

    func testExecuteThrowsWhenStageMissing() {
        let asset = AssetDefinition(
            name: "Target",
            category: "Target",
            isCustom: false,
            defaultWidth: 0.4,
            defaultHeight: 0.7
        )

        let stageRepo = InMemoryStageRepository()
        let assetRepo = InMemoryAssetRepository(seedAssets: [asset])
        let useCase = AddStageElementUseCase(stageRepository: stageRepo, assetRepository: assetRepo)
        let stageId = UUID()

        XCTAssertThrowsError(try useCase.execute(AddStageElementInput(stageId: stageId, assetId: asset.id, x: 0, y: 0))) { error in
            XCTAssertEqual(error as? AddStageElementUseCaseError, .stageNotFound(stageId: stageId))
        }
    }

    func testExecuteThrowsWhenAssetMissing() {
        let stage = Stage(title: "Edit Stage")
        let stageRepo = InMemoryStageRepository(seedStages: [stage])
        let assetRepo = InMemoryAssetRepository()
        let useCase = AddStageElementUseCase(stageRepository: stageRepo, assetRepository: assetRepo)
        let assetId = UUID()

        XCTAssertThrowsError(try useCase.execute(AddStageElementInput(stageId: stage.id, assetId: assetId, x: 1, y: 1))) { error in
            XCTAssertEqual(error as? AddStageElementUseCaseError, .assetNotFound(assetId: assetId))
        }
    }
}

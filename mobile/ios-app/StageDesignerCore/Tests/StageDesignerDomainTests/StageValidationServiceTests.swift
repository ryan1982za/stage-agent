import XCTest
@testable import StageDesignerDomain

final class StageValidationServiceTests: XCTestCase {
    func testValidateRejectsEmptyTitle() {
        let service = StageValidationService()
        let stage = Stage(title: "   ")

        XCTAssertThrowsError(try service.validate(stage)) { error in
            XCTAssertEqual(error as? StageValidationError, .emptyTitle)
        }
    }

    func testValidateRejectsNonPositiveDimensions() {
        let service = StageValidationService()
        let stageId = UUID()
        let stage = Stage(
            id: stageId,
            title: "Test Stage",
            elements: [
                StageElement(
                    stageId: stageId,
                    assetId: UUID(),
                    x: 10,
                    y: 20,
                    width: 0,
                    height: 1,
                    zIndex: 0
                )
            ]
        )

        XCTAssertThrowsError(try service.validate(stage))
    }

    func testValidateRejectsDuplicateZIndexes() {
        let service = StageValidationService()
        let stageId = UUID()

        let e1 = StageElement(stageId: stageId, assetId: UUID(), x: 0, y: 0, width: 1, height: 1, zIndex: 2)
        let e2 = StageElement(stageId: stageId, assetId: UUID(), x: 1, y: 1, width: 1, height: 1, zIndex: 2)
        let stage = Stage(id: stageId, title: "Stage", elements: [e1, e2])

        XCTAssertThrowsError(try service.validate(stage)) { error in
            XCTAssertEqual(error as? StageValidationError, .duplicateZIndex)
        }
    }

    func testValidatePassesForValidStage() throws {
        let service = StageValidationService()
        let stageId = UUID()

        let e1 = StageElement(stageId: stageId, assetId: UUID(), x: 0, y: 0, width: 1, height: 1, zIndex: 0)
        let e2 = StageElement(stageId: stageId, assetId: UUID(), x: 2, y: 2, width: 1, height: 1, zIndex: 1)
        let stage = Stage(id: stageId, title: "Stage", elements: [e1, e2])

        XCTAssertNoThrow(try service.validate(stage))
    }
}

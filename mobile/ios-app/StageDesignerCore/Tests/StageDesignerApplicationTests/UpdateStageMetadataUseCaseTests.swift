import XCTest
@testable import StageDesignerApplication
import StageDesignerDomain
import StageDesignerPersistence

final class UpdateStageMetadataUseCaseTests: XCTestCase {
    func testExecuteUpdatesMetadata() throws {
        let stage = Stage(title: "Original")
        let repo = InMemoryStageRepository(seedStages: [stage])
        let useCase = UpdateStageMetadataUseCase(stageRepository: repo)

        let updated = try useCase.execute(
            UpdateStageMetadataInput(
                stageId: stage.id,
                title: "Updated",
                disciplineLabel: "Practical",
                location: "Bay 2",
                notes: "Reworked"
            )
        )

        XCTAssertEqual(updated.title, "Updated")
        XCTAssertEqual(updated.disciplineLabel, "Practical")
        XCTAssertEqual(updated.location, "Bay 2")
        XCTAssertEqual(updated.notes, "Reworked")
    }

    func testExecuteThrowsForMissingStage() {
        let repo = InMemoryStageRepository()
        let useCase = UpdateStageMetadataUseCase(stageRepository: repo)
        let missingId = UUID()

        XCTAssertThrowsError(
            try useCase.execute(
                UpdateStageMetadataInput(
                    stageId: missingId,
                    title: "Updated",
                    disciplineLabel: "",
                    location: "",
                    notes: ""
                )
            )
        ) { error in
            XCTAssertEqual(error as? UpdateStageMetadataUseCaseError, .stageNotFound(stageId: missingId))
        }
    }
}

import Foundation
import XCTest
@testable import StageDesignerApplication
import StageDesignerDomain
import StageDesignerPersistence

final class CreateStageUseCaseTests: XCTestCase {
    func testExecuteCreatesStageAndPersistsIt() throws {
        let repo = InMemoryStageRepository()
        let useCase = CreateStageUseCase(stageRepository: repo)

        let created = try useCase.execute(
            CreateStageInput(
                title: "Club Practice Stage",
                disciplineLabel: "Practical",
                location: "Range Bay 2",
                notes: "Initial draft"
            )
        )

        XCTAssertEqual(created.title, "Club Practice Stage")
        XCTAssertEqual(created.disciplineLabel, "Practical")
        XCTAssertEqual(created.location, "Range Bay 2")

        let persisted = try repo.fetchStage(id: created.id)
        XCTAssertNotNil(persisted)
        XCTAssertEqual(persisted?.title, "Club Practice Stage")
    }

    func testExecuteRejectsEmptyTitle() {
        let repo = InMemoryStageRepository()
        let useCase = CreateStageUseCase(stageRepository: repo)

        XCTAssertThrowsError(try useCase.execute(CreateStageInput(title: "  "))) { error in
            XCTAssertEqual(error as? StageValidationError, .emptyTitle)
        }
    }
}

import XCTest
@testable import StageDesignerApplication
import StageDesignerDomain
import StageDesignerPersistence

final class ListStagesUseCaseTests: XCTestCase {
    func testExecuteReturnsStagesSortedByLastUpdatedDescending() throws {
        let now = Date()
        let older = Stage(title: "Older", updatedAt: now.addingTimeInterval(-3600))
        let newest = Stage(title: "Newest", updatedAt: now)

        let repo = InMemoryStageRepository(seedStages: [older, newest])
        let useCase = ListStagesUseCase(stageRepository: repo)

        let result = try useCase.execute()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.title, "Newest")
        XCTAssertEqual(result.last?.title, "Older")
    }

    func testDeleteRemovesStage() throws {
        let stage = Stage(title: "To Remove")
        let repo = InMemoryStageRepository(seedStages: [stage])
        let deleteUseCase = DeleteStageUseCase(stageRepository: repo)
        let listUseCase = ListStagesUseCase(stageRepository: repo)

        try deleteUseCase.execute(stageId: stage.id)
        let result = try listUseCase.execute()

        XCTAssertTrue(result.isEmpty)
    }
}

import XCTest
@testable import StageDesignerApplication
import StageDesignerDomain
import StageDesignerPersistence

final class GetStageNotesSnapshotUseCaseTests: XCTestCase {
    func testExecuteReturnsChecklistAndRunNotes() throws {
        let stage = Stage(title: "Snapshot Stage")
        let stageRepo = InMemoryStageRepository(seedStages: [stage])
        let notesRepo = InMemoryNotesRepository()

        try notesRepo.upsertChecklistItem(ChecklistItem(stageId: stage.id, text: "Confirm target positions", isDone: true))
        try notesRepo.appendRunNote(RunNote(stageId: stage.id, text: "Lane check complete"))

        let useCase = GetStageNotesSnapshotUseCase(stageRepository: stageRepo, notesRepository: notesRepo)
        let snapshot = try useCase.execute(stageId: stage.id)

        XCTAssertEqual(snapshot.checklist.count, 1)
        XCTAssertEqual(snapshot.runNotes.count, 1)
        XCTAssertEqual(snapshot.checklist.first?.text, "Confirm target positions")
        XCTAssertEqual(snapshot.runNotes.first?.text, "Lane check complete")
    }

    func testExecuteThrowsWhenStageMissing() {
        let stageRepo = InMemoryStageRepository()
        let notesRepo = InMemoryNotesRepository()
        let stageId = UUID()

        let useCase = GetStageNotesSnapshotUseCase(stageRepository: stageRepo, notesRepository: notesRepo)

        XCTAssertThrowsError(try useCase.execute(stageId: stageId)) { error in
            XCTAssertEqual(error as? StageNotesUseCaseError, .stageNotFound(stageId: stageId))
        }
    }
}

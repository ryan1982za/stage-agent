import XCTest
@testable import StageDesignerApplication
import StageDesignerDomain
import StageDesignerPersistence

final class StageNotesUseCasesTests: XCTestCase {
    func testChecklistAndRunNotesFlow() throws {
        let stage = Stage(title: "Notes Stage")
        let stageRepo = InMemoryStageRepository(seedStages: [stage])
        let notesRepo = InMemoryNotesRepository()

        let addChecklist = AddChecklistItemUseCase(stageRepository: stageRepo, notesRepository: notesRepo)
        let toggleChecklist = ToggleChecklistItemUseCase(stageRepository: stageRepo, notesRepository: notesRepo)
        let addRunNote = AddRunNoteUseCase(stageRepository: stageRepo, notesRepository: notesRepo)

        let item = try addChecklist.execute(stageId: stage.id, text: "Confirm start marker")
        XCTAssertFalse(item.isDone)

        let toggled = try toggleChecklist.execute(stageId: stage.id, itemId: item.id, isDone: true)
        XCTAssertTrue(toggled.isDone)

        let note = try addRunNote.execute(stageId: stage.id, text: "Timer check passed")
        XCTAssertEqual(note.stageId, stage.id)

        let checklist = try notesRepo.fetchChecklist(stageId: stage.id)
        XCTAssertEqual(checklist.count, 1)
        XCTAssertTrue(checklist[0].isDone)

        let runNotes = try notesRepo.fetchRunNotes(stageId: stage.id)
        XCTAssertEqual(runNotes.count, 1)
        XCTAssertEqual(runNotes[0].text, "Timer check passed")
    }

    func testUseCasesThrowWhenStageMissing() {
        let stageRepo = InMemoryStageRepository()
        let notesRepo = InMemoryNotesRepository()
        let missingId = UUID()

        let addChecklist = AddChecklistItemUseCase(stageRepository: stageRepo, notesRepository: notesRepo)
        XCTAssertThrowsError(try addChecklist.execute(stageId: missingId, text: "x"))

        let addRunNote = AddRunNoteUseCase(stageRepository: stageRepo, notesRepository: notesRepo)
        XCTAssertThrowsError(try addRunNote.execute(stageId: missingId, text: "x"))
    }

    func testUseCasesRejectEmptyText() {
        let stage = Stage(title: "Notes Stage")
        let stageRepo = InMemoryStageRepository(seedStages: [stage])
        let notesRepo = InMemoryNotesRepository()

        let addChecklist = AddChecklistItemUseCase(stageRepository: stageRepo, notesRepository: notesRepo)
        XCTAssertThrowsError(try addChecklist.execute(stageId: stage.id, text: "   ")) { error in
            XCTAssertEqual(error as? StageNotesUseCaseError, .emptyText)
        }

        let addRunNote = AddRunNoteUseCase(stageRepository: stageRepo, notesRepository: notesRepo)
        XCTAssertThrowsError(try addRunNote.execute(stageId: stage.id, text: "\n\t")) { error in
            XCTAssertEqual(error as? StageNotesUseCaseError, .emptyText)
        }
    }
}

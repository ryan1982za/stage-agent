import Foundation
import StageDesignerDomain
import StageDesignerPersistence

public struct StageNotesSnapshot {
    public let checklist: [ChecklistItem]
    public let runNotes: [RunNote]

    public init(checklist: [ChecklistItem], runNotes: [RunNote]) {
        self.checklist = checklist
        self.runNotes = runNotes
    }
}

public final class GetStageNotesSnapshotUseCase {
    private let stageRepository: StageRepository
    private let notesRepository: NotesRepository

    public init(stageRepository: StageRepository, notesRepository: NotesRepository) {
        self.stageRepository = stageRepository
        self.notesRepository = notesRepository
    }

    public func execute(stageId: UUID) throws -> StageNotesSnapshot {
        guard try stageRepository.fetchStage(id: stageId) != nil else {
            throw StageNotesUseCaseError.stageNotFound(stageId: stageId)
        }

        return StageNotesSnapshot(
            checklist: try notesRepository.fetchChecklist(stageId: stageId),
            runNotes: try notesRepository.fetchRunNotes(stageId: stageId)
        )
    }
}

import Foundation
import StageDesignerDomain
import StageDesignerPersistence

public enum StageNotesUseCaseError: Error, Equatable {
    case stageNotFound(stageId: UUID)
    case emptyText
}

public final class AddChecklistItemUseCase {
    private let stageRepository: StageRepository
    private let notesRepository: NotesRepository

    public init(stageRepository: StageRepository, notesRepository: NotesRepository) {
        self.stageRepository = stageRepository
        self.notesRepository = notesRepository
    }

    public func execute(stageId: UUID, text: String) throws -> ChecklistItem {
        guard try stageRepository.fetchStage(id: stageId) != nil else {
            throw StageNotesUseCaseError.stageNotFound(stageId: stageId)
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw StageNotesUseCaseError.emptyText
        }

        let item = ChecklistItem(stageId: stageId, text: trimmed, isDone: false, updatedAt: Date())
        try notesRepository.upsertChecklistItem(item)
        return item
    }
}

public final class ToggleChecklistItemUseCase {
    private let stageRepository: StageRepository
    private let notesRepository: NotesRepository

    public init(stageRepository: StageRepository, notesRepository: NotesRepository) {
        self.stageRepository = stageRepository
        self.notesRepository = notesRepository
    }

    public func execute(stageId: UUID, itemId: UUID, isDone: Bool) throws -> ChecklistItem {
        guard try stageRepository.fetchStage(id: stageId) != nil else {
            throw StageNotesUseCaseError.stageNotFound(stageId: stageId)
        }

        var items = try notesRepository.fetchChecklist(stageId: stageId)
        guard let index = items.firstIndex(where: { $0.id == itemId }) else {
            let newItem = ChecklistItem(id: itemId, stageId: stageId, text: "", isDone: isDone, updatedAt: Date())
            try notesRepository.upsertChecklistItem(newItem)
            return newItem
        }

        var item = items[index]
        item.isDone = isDone
        item.updatedAt = Date()
        try notesRepository.upsertChecklistItem(item)
        return item
    }
}

public final class AddRunNoteUseCase {
    private let stageRepository: StageRepository
    private let notesRepository: NotesRepository

    public init(stageRepository: StageRepository, notesRepository: NotesRepository) {
        self.stageRepository = stageRepository
        self.notesRepository = notesRepository
    }

    public func execute(stageId: UUID, text: String) throws -> RunNote {
        guard try stageRepository.fetchStage(id: stageId) != nil else {
            throw StageNotesUseCaseError.stageNotFound(stageId: stageId)
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw StageNotesUseCaseError.emptyText
        }

        let note = RunNote(stageId: stageId, text: trimmed, createdAt: Date())
        try notesRepository.appendRunNote(note)
        return note
    }
}

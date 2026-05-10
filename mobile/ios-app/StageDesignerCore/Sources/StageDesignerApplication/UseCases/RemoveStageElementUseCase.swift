import Foundation
import StageDesignerDomain

/// Use case for removing a stage element from a stage.
public final class RemoveStageElementUseCase {
    private let stageRepository: StageRepository

    public init(stageRepository: StageRepository) {
        self.stageRepository = stageRepository
    }

    public struct Input {
        let stageId: UUID
        let elementId: UUID

        public init(stageId: UUID, elementId: UUID) {
            self.stageId = stageId
            self.elementId = elementId
        }
    }

    public func execute(_ input: Input) throws {
        let stages = try stageRepository.fetchAllStages()
        guard let stage = stages.first(where: { $0.id == input.stageId }) else {
            throw NSError(domain: "RemoveStageElementUseCase", code: 1, userInfo: [NSLocalizedDescriptionKey: "Stage not found"])
        }

        let filteredElements = stage.elements.filter { $0.id != input.elementId }
        let updatedStage = Stage(
            id: stage.id,
            title: stage.title,
            disciplineLabel: stage.disciplineLabel,
            location: stage.location,
            notes: stage.notes,
            elements: filteredElements,
            checklist: stage.checklist,
            runNotes: stage.runNotes,
            updatedAt: Date()
        )

        try stageRepository.saveStage(updatedStage)
    }
}

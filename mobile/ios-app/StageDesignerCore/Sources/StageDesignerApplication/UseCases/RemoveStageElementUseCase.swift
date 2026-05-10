import Foundation
import StageDesignerDomain
import StageDesignerPersistence

/// Use case for removing a stage element from a stage.
public final class RemoveStageElementUseCase {
    private let stageRepository: StageRepository
    private let validationService: StageValidationService

    public init(
        stageRepository: StageRepository,
        validationService: StageValidationService = StageValidationService()
    ) {
        self.stageRepository = stageRepository
        self.validationService = validationService
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
        guard var stage = try stageRepository.fetchStage(id: input.stageId) else {
            throw NSError(domain: "RemoveStageElementUseCase", code: 1, userInfo: [NSLocalizedDescriptionKey: "Stage not found"])
        }

        stage.elements.removeAll(where: { $0.id == input.elementId })
        stage.updatedAt = Date()

        try validationService.validate(stage)
        try stageRepository.upsertStage(stage)
    }
}

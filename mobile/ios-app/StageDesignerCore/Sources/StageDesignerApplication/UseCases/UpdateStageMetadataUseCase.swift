import Foundation
import StageDesignerDomain
import StageDesignerPersistence

public enum UpdateStageMetadataUseCaseError: Error, Equatable {
    case stageNotFound(stageId: UUID)
}

public struct UpdateStageMetadataInput {
    public let stageId: UUID
    public let title: String
    public let disciplineLabel: String
    public let location: String
    public let notes: String

    public init(stageId: UUID, title: String, disciplineLabel: String, location: String, notes: String) {
        self.stageId = stageId
        self.title = title
        self.disciplineLabel = disciplineLabel
        self.location = location
        self.notes = notes
    }
}

public final class UpdateStageMetadataUseCase {
    private let stageRepository: StageRepository
    private let validationService: StageValidationService

    public init(stageRepository: StageRepository, validationService: StageValidationService = StageValidationService()) {
        self.stageRepository = stageRepository
        self.validationService = validationService
    }

    public func execute(_ input: UpdateStageMetadataInput) throws -> Stage {
        guard var stage = try stageRepository.fetchStage(id: input.stageId) else {
            throw UpdateStageMetadataUseCaseError.stageNotFound(stageId: input.stageId)
        }

        stage.title = input.title
        stage.disciplineLabel = input.disciplineLabel
        stage.location = input.location
        stage.notes = input.notes
        stage.updatedAt = Date()

        try validationService.validate(stage)
        try stageRepository.upsertStage(stage)

        return stage
    }
}

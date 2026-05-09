import Foundation
import StageDesignerDomain
import StageDesignerPersistence

public struct CreateStageInput {
    public let title: String
    public let disciplineLabel: String
    public let location: String
    public let notes: String

    public init(title: String, disciplineLabel: String = "", location: String = "", notes: String = "") {
        self.title = title
        self.disciplineLabel = disciplineLabel
        self.location = location
        self.notes = notes
    }
}

public final class CreateStageUseCase {
    private let stageRepository: StageRepository
    private let validationService: StageValidationService

    public init(stageRepository: StageRepository, validationService: StageValidationService = StageValidationService()) {
        self.stageRepository = stageRepository
        self.validationService = validationService
    }

    public func execute(_ input: CreateStageInput) throws -> Stage {
        let stage = Stage(
            title: input.title,
            disciplineLabel: input.disciplineLabel,
            location: input.location,
            notes: input.notes,
            updatedAt: Date()
        )

        try validationService.validate(stage)
        try stageRepository.upsertStage(stage)
        return stage
    }
}

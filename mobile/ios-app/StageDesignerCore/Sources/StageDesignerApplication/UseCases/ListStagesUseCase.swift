import Foundation
import StageDesignerDomain
import StageDesignerPersistence

public final class ListStagesUseCase {
    private let stageRepository: StageRepository

    public init(stageRepository: StageRepository) {
        self.stageRepository = stageRepository
    }

    public func execute() throws -> [Stage] {
        try stageRepository.fetchAllStages()
    }
}

public final class DeleteStageUseCase {
    private let stageRepository: StageRepository

    public init(stageRepository: StageRepository) {
        self.stageRepository = stageRepository
    }

    public func execute(stageId: UUID) throws {
        try stageRepository.deleteStage(id: stageId)
    }
}

import Foundation
import StageDesignerDomain
import StageDesignerPersistence

public enum AddStageElementUseCaseError: Error, Equatable {
    case stageNotFound(stageId: UUID)
    case assetNotFound(assetId: UUID)
}

public struct AddStageElementInput {
    public let stageId: UUID
    public let assetId: UUID
    public let x: Double
    public let y: Double

    public init(stageId: UUID, assetId: UUID, x: Double, y: Double) {
        self.stageId = stageId
        self.assetId = assetId
        self.x = x
        self.y = y
    }
}

public final class AddStageElementUseCase {
    private let stageRepository: StageRepository
    private let assetRepository: AssetRepository
    private let validationService: StageValidationService

    public init(
        stageRepository: StageRepository,
        assetRepository: AssetRepository,
        validationService: StageValidationService = StageValidationService()
    ) {
        self.stageRepository = stageRepository
        self.assetRepository = assetRepository
        self.validationService = validationService
    }

    public func execute(_ input: AddStageElementInput) throws -> Stage {
        guard var stage = try stageRepository.fetchStage(id: input.stageId) else {
            throw AddStageElementUseCaseError.stageNotFound(stageId: input.stageId)
        }

        let allAssets = try assetRepository.fetchBuiltInAssets() + assetRepository.fetchCustomAssets()
        guard let asset = allAssets.first(where: { $0.id == input.assetId }) else {
            throw AddStageElementUseCaseError.assetNotFound(assetId: input.assetId)
        }

        let nextZIndex = (stage.elements.map { $0.zIndex }.max() ?? -1) + 1

        let element = StageElement(
            stageId: stage.id,
            assetId: asset.id,
            x: input.x,
            y: input.y,
            width: asset.defaultWidth,
            height: asset.defaultHeight,
            zIndex: nextZIndex
        )

        stage.elements.append(element)
        stage.updatedAt = Date()

        try validationService.validate(stage)
        try stageRepository.upsertStage(stage)

        return stage
    }
}
